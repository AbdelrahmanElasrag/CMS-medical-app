import 'dart:convert';

import 'package:cms/services/triage_from_analysis.dart';
import 'package:cms/services/triage_red_flags.dart';

/// One line in the chat transcript.
class TriageChatLine {
  TriageChatLine({required this.isUser, required this.text});
  final bool isUser;
  final String text;
}

class RuleTriageFlow {
  RuleTriageFlow({required this.version, required this.startId, required this.nodes});

  final int version;
  final String startId;
  final Map<String, Map<String, dynamic>> nodes;

  static RuleTriageFlow parseJson(String jsonStr) {
    final decoded = jsonDecode(jsonStr);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Root must be an object');
    }
    final v = decoded['version'];
    final start = decoded['startId']?.toString();
    final rawNodes = decoded['nodes'];
    if (start == null || start.isEmpty || rawNodes is! Map) {
      throw FormatException('Missing startId or nodes');
    }
    final nodes = <String, Map<String, dynamic>>{};
    for (final e in rawNodes.entries) {
      if (e.value is Map<String, dynamic>) {
        nodes[e.key.toString()] = Map<String, dynamic>.from(e.value as Map);
      }
    }
    if (!nodes.containsKey(start)) {
      throw FormatException('startId not found in nodes');
    }
    for (final id in nodes.keys) {
      _validateNode(id, nodes[id]!, nodes);
    }
    return RuleTriageFlow(
      version: v is int ? v : int.tryParse('$v') ?? 1,
      startId: start,
      nodes: nodes,
    );
  }

  static void _validateNode(String id, Map<String, dynamic> n, Map<String, Map<String, dynamic>> all) {
    final terminal = n['terminal'] == true;
    if (terminal) {
      if (n['computeFromTags'] == true) return;
      final b = n['triageBucket']?.toString();
      if (b == null || b.isEmpty) {
        throw FormatException('Terminal $id missing triageBucket');
      }
      return;
    }
    final opts = n['options'];
    if (opts is! List || opts.isEmpty) {
      throw FormatException('Node $id needs non-empty options');
    }
    for (final o in opts) {
      if (o is! Map) continue;
      final m = Map<String, dynamic>.from(o);
      final next = m['nextId']?.toString();
      if (next == null || !all.containsKey(next)) {
        throw FormatException('Node $id option missing valid nextId');
      }
    }
  }
}

class RuleTriageOutcome {
  RuleTriageOutcome({
    required this.bucket,
    required this.careSummary,
    required this.hintBullets,
    required this.rawSnippet,
    required this.redFlagCodes,
    required this.tags,
  });

  final TriageBucket bucket;
  final String careSummary;
  final List<String> hintBullets;
  final String rawSnippet;
  final List<String> redFlagCodes;
  final Set<String> tags;

  TriageAssessment toTriageAssessment() {
    final hint = hintBullets.isNotEmpty ? hintBullets.take(4).join(' • ') : null;
    return TriageAssessment(
      bucket: bucket,
      diseases: const [],
      rawJsonSnippet: rawSnippet,
      apiTriageHint: hint,
      emergencyPhrasesFound: redFlagCodes,
      careSummary: careSummary,
      triageSource: 'rule_based',
    );
  }
}

/// Mutable session: chat lines, tags, navigation.
class RuleTriageSession {
  RuleTriageSession(this.flow)
      : currentId = flow.startId,
        _forceEmergency = false;

  final RuleTriageFlow flow;
  String currentId;
  final List<TriageChatLine> transcript = <TriageChatLine>[];
  final Set<String> tags = <String>{};
  bool _forceEmergency;
  bool _finished = false;

  /// After [stageChoice], true until [commitStagedChoice] runs (UI: typing indicator).
  bool _awaitingCommit = false;
  Map<String, dynamic>? _pendingChosen;
  String? _pendingNextId;

  bool get finished => _finished;
  bool get assistantTyping => _awaitingCommit;
  bool get awaitingChoice =>
      !_finished && !(currentNode['terminal'] == true) && !_awaitingCommit;

  Map<String, dynamic> get currentNode {
    final n = flow.nodes[currentId];
    if (n == null) throw StateError('Missing node $currentId');
    return n;
  }

  List<Map<String, dynamic>> get currentOptions {
    final o = currentNode['options'];
    if (o is! List) return const [];
    return o.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  void start() {
    transcript.clear();
    tags.clear();
    _forceEmergency = false;
    _finished = false;
    _awaitingCommit = false;
    _pendingChosen = null;
    _pendingNextId = null;
    currentId = flow.startId;
    _pushAssistantNode(flow.nodes[currentId]!);
  }

  void _pushAssistantNode(Map<String, dynamic> node) {
    final text = (node['assistantText']?.toString() ?? '').trim();
    if (text.isEmpty) return;
    transcript.add(TriageChatLine(isUser: false, text: text));
  }

  /// Records the user tap and shows their line; call [commitStagedChoice] after a delay for “typing” UX.
  void stageChoice(String optionId) {
    if (_finished) return;
    if (currentNode['terminal'] == true) return;
    if (_awaitingCommit) return;

    final opts = currentOptions;
    Map<String, dynamic>? chosen;
    for (final o in opts) {
      if (o['id']?.toString() == optionId) {
        chosen = o;
        break;
      }
    }
    if (chosen == null) return;

    final nextId = chosen['nextId']?.toString();
    if (nextId == null || !flow.nodes.containsKey(nextId)) {
      throw StateError('Invalid nextId from $optionId');
    }

    final label = chosen['label']?.toString() ?? optionId;
    transcript.add(TriageChatLine(isUser: true, text: label));
    _pendingChosen = chosen;
    _pendingNextId = nextId;
    _awaitingCommit = true;
  }

  /// Applies tags, navigates, and pushes the next assistant message (or finishes at terminal).
  void commitStagedChoice() {
    if (!_awaitingCommit || _pendingChosen == null || _pendingNextId == null) return;

    final chosen = _pendingChosen!;
    final nextId = _pendingNextId!;
    _pendingChosen = null;
    _pendingNextId = null;
    _awaitingCommit = false;

    final add = chosen['tagsAdd'];
    if (add is List) {
      for (final t in add) {
        tags.add(t.toString());
      }
    }
    if (chosen['forceEmergency'] == true) {
      _forceEmergency = true;
    }

    currentId = nextId;
    final next = flow.nodes[currentId]!;
    if (next['terminal'] == true) {
      _finished = true;
      return;
    }
    _pushAssistantNode(next);
  }

  /// Immediate advance (tests / callers that skip typing delay).
  void selectOption(String optionId) {
    stageChoice(optionId);
    commitStagedChoice();
  }

  RuleTriageOutcome buildOutcome() {
    final node = flow.nodes[currentId]!;
    if (node['terminal'] != true) {
      throw StateError('Not at terminal');
    }

    if (node['computeFromTags'] == true) {
      return _outcomeFromTags(node);
    }

    final bucket = _parseBucket(node['triageBucket']?.toString());
    final summary = node['careSummary']?.toString() ?? '';
    final bullets = _parseBullets(node['hintBullets']);
    final red = <String>{..._redCodesForTags()};
    if (_forceEmergency) red.add('forced_emergency_path');
    final redList = red.toList()..sort();
    final raw = jsonEncode({
      'terminalId': currentId,
      'tags': tags.toList()..sort(),
      'redFlags': redList,
      'bucket': bucket.name,
    });
    return RuleTriageOutcome(
      bucket: bucket,
      careSummary: summary,
      hintBullets: bullets,
      rawSnippet: raw.length > 500 ? '${raw.substring(0, 500)}…' : raw,
      redFlagCodes: redList,
      tags: Set<String>.from(tags),
    );
  }

  RuleTriageOutcome _outcomeFromTags(Map<String, dynamic> terminalNode) {
    final narrative = _tagsToNarrative(tags);
    var red = evaluateRedFlagCodes(narrative);
    if (_forceEmergency) {
      red = [...red, 'forced_emergency_path'];
    }
    if (red.isNotEmpty) {
      final summary =
          'Your answers match patterns that need urgent in-person assessment. If you feel you may be having an emergency, call your local emergency number or go to the nearest emergency department.';
      final raw = jsonEncode({'tags': tags.toList()..sort(), 'redFlags': red, 'bucket': 'emergency'});
      return RuleTriageOutcome(
        bucket: TriageBucket.emergency,
        careSummary: summary,
        hintBullets: const [
          'This is not a diagnosis.',
          'Seek emergency care for severe, sudden, or worsening symptoms.',
        ],
        rawSnippet: raw,
        redFlagCodes: red,
        tags: Set<String>.from(tags),
      );
    }

    final bucket = _computeBucketFromTags();
    final summary = _summaryForBucket(bucket, terminalNode['careSummary']?.toString() ?? '');
    final bullets = _parseBullets(terminalNode['hintBullets']);
    final raw = jsonEncode({'tags': tags.toList()..sort(), 'bucket': bucket.name});
    return RuleTriageOutcome(
      bucket: bucket,
      careSummary: summary,
      hintBullets: bullets,
      rawSnippet: raw.length > 500 ? '${raw.substring(0, 500)}…' : raw,
      redFlagCodes: red,
      tags: Set<String>.from(tags),
    );
  }

  static TriageBucket _parseBucket(String? s) {
    switch (s) {
      case 'emergency':
        return TriageBucket.emergency;
      case 'urgent':
      case 'urgent_care':
        return TriageBucket.urgent;
      case 'gp':
      case 'routine':
        return TriageBucket.gp;
      case 'self_care':
      case 'selfCare':
        return TriageBucket.selfCare;
      default:
        return TriageBucket.gp;
    }
  }

  static List<String> _parseBullets(dynamic v) {
    if (v is! List) return const [];
    return v.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
  }

  List<String> _redCodesForTags() {
    final narrative = _tagsToNarrative(tags);
    return evaluateRedFlagCodes(narrative);
  }

  static String _tagsToNarrative(Set<String> tags) {
    const map = <String, String>{
      'chief_chest': 'chest pain',
      'cx_sob_yes': 'short of breath',
      'cx_sob_no': '',
      'cx_rad_yes': 'pain in chest radiating to arm',
      'cx_exert_yes': 'chest pressure with exertion',
      'chief_fever': 'fever',
      'feb_high_yes': 'high fever',
      'chief_resp': 'trouble breathing',
      'br_severe_yes': 'cannot breathe',
      'cold_sob_yes': 'short of breath',
      'chief_neuro': 'stroke',
      'st_face_yes': 'face droop',
      'st_arm_yes': 'arm weakness',
      'gi_blood_yes': 'vomiting blood',
      'gi_severe_yes': 'severe abdominal pain rigid abdomen',
      'gi_dehydr_yes': 'cannot keep fluids down',
      'chief_headache': 'severe headache',
      'head_red_yes': 'sudden worst headache',
      'inj_major_yes': 'loss of consciousness',
      'skin_bad_yes': 'rapidly spreading rash with fever',
      'chief_uri': 'burning urine',
      'chief_cold': 'flu-like illness',
      'chief_skin': 'rash',
      'chief_mh': 'anxiety',
    };
    final parts = <String>[];
    for (final t in tags) {
      final p = map[t];
      if (p != null && p.isNotEmpty) parts.add(p);
    }
    return parts.join('\n');
  }

  TriageBucket _computeBucketFromTags() {
    if (_forceEmergency) return TriageBucket.emergency;
    if (tags.contains('cx_rad_yes') || tags.contains('cx_sob_yes')) return TriageBucket.emergency;
    if (tags.contains('feb_high_yes') && tags.contains('feb_dur_short')) {
      return TriageBucket.urgent;
    }
    if (tags.contains('chief_gi')) {
      if (tags.contains('gi_dehydr_yes')) return TriageBucket.urgent;
      if (tags.contains('preg_yes')) return TriageBucket.urgent;
      if (tags.contains('gi_severe_no')) return TriageBucket.gp;
      return TriageBucket.urgent;
    }
    if (tags.contains('chief_fever')) {
      if (tags.contains('immunocomp_yes')) return TriageBucket.urgent;
      if (tags.contains('preg_yes')) return TriageBucket.urgent;
      if (tags.contains('feb_dur_long')) return TriageBucket.gp;
      if (tags.contains('onset_long')) return TriageBucket.gp;
      return TriageBucket.urgent;
    }
    if (tags.contains('chief_uri')) {
      if (tags.contains('preg_yes')) return TriageBucket.urgent;
      if (tags.contains('uri_complex_yes')) return TriageBucket.urgent;
      return TriageBucket.gp;
    }
    if (tags.contains('chief_cold')) {
      if (tags.contains('cold_systemic_yes')) return TriageBucket.urgent;
      return TriageBucket.gp;
    }
    if (tags.contains('chief_skin')) {
      if (tags.contains('skin_face_yes')) return TriageBucket.urgent;
      return TriageBucket.gp;
    }
    if (tags.contains('chief_mh')) {
      return TriageBucket.gp;
    }
    if (tags.contains('chief_chest')) {
      return TriageBucket.urgent;
    }
    if (tags.contains('chief_resp')) {
      if (tags.contains('br_severe_no') && tags.contains('br_dur_long')) return TriageBucket.gp;
      return TriageBucket.urgent;
    }
    if (tags.contains('chief_neuro')) return TriageBucket.urgent;
    if (tags.contains('chief_injury') && tags.contains('inj_major_no')) return TriageBucket.gp;
    if (tags.contains('chief_headache') && tags.contains('head_red_no')) return TriageBucket.gp;
    if (tags.contains('alcohol_high')) return TriageBucket.gp;
    if (tags.contains('chief_other')) return TriageBucket.gp;
    return TriageBucket.selfCare;
  }

  String _summaryForBucket(TriageBucket b, String fallback) {
    switch (b) {
      case TriageBucket.emergency:
        return fallback;
      case TriageBucket.urgent:
        return 'Your answers suggest same-day or urgent in-person care may be appropriate. If you worsen, use emergency services.';
      case TriageBucket.gp:
        return 'Your answers suggest a routine or soon visit with a clinician is reasonable. Monitor symptoms and seek care if they worsen.';
      case TriageBucket.selfCare:
        return 'Your answers suggest lower-acuity self-care and routine follow-up may be enough. If anything feels off or worsens, book a visit.';
    }
  }
}
