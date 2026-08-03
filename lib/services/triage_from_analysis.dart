import 'dart:convert';

/// UX triage bucket derived from [Analyze] JSON (fields differ by API version).
enum TriageBucket { emergency, urgent, gp, selfCare }

class DiseaseRanking {
  DiseaseRanking({required this.name, required this.probability});
  final String name;
  final double probability;
}

class TriageAssessment {
  TriageAssessment({
    required this.bucket,
    required this.diseases,
    required this.rawJsonSnippet,
    this.apiTriageHint,
    this.emergencyPhrasesFound = const [],
    this.careSummary,
    this.triageSource,
  });

  final TriageBucket bucket;
  final List<DiseaseRanking> diseases;
  final String rawJsonSnippet;
  final String? apiTriageHint;
  final List<String> emergencyPhrasesFound;
  /// Short user-facing summary when triage comes from backend LLM gateway.
  final String? careSummary;
  /// e.g. `llm` | `guardrail_override` from CMS symptom-triage API.
  final String? triageSource;
}

const _emergencyPhrases = [
  'life-threatening',
  'life threatening',
  'high risk',
  'high-risk',
];

TriageAssessment assessFromAnalyzeMap(Map<String, dynamic> data) {
  final diseases = _parseDiseases(data['Diseases']);
  diseases.sort((a, b) => b.probability.compareTo(a.probability));

  final flat = jsonEncode(data).toLowerCase();
  final found = <String>[];
  for (final p in _emergencyPhrases) {
    if (flat.contains(p)) found.add(p);
  }

  for (final d in diseases.take(5)) {
    final n = d.name.toLowerCase();
    if (n.contains('septic') ||
        n.contains('shock') ||
        n.contains('myocardial') ||
        n.contains('stroke') ||
        n.contains('pulmonary embolism') ||
        n.contains('aortic dissection')) {
      found.add('disease:$d.name');
    }
  }

  final apiHint = _pickStringField(data, const [
    'triage_level',
    'TriageLevel',
    'CareLevel',
    'care_level',
    'Acuity',
    'acuity',
  ]);

  final topP = diseases.isEmpty ? 0.0 : diseases.first.probability;

  late final TriageBucket bucket;
  if (found.isNotEmpty) {
    bucket = TriageBucket.emergency;
  } else if (apiHint != null) {
    final h = apiHint.toLowerCase();
    if (h.contains('emergency') || h.contains('er')) {
      bucket = TriageBucket.emergency;
    } else if (h.contains('urgent')) {
      bucket = TriageBucket.urgent;
    } else if (h.contains('self')) {
      bucket = TriageBucket.selfCare;
    } else {
      bucket = TriageBucket.gp;
    }
  } else if (topP >= 0.45) {
    bucket = TriageBucket.urgent;
  } else if (topP >= 0.2) {
    bucket = TriageBucket.gp;
  } else {
    bucket = TriageBucket.selfCare;
  }

  final snippet = flat.length > 600 ? '${flat.substring(0, 600)}…' : flat;

  return TriageAssessment(
    bucket: bucket,
    diseases: diseases.take(8).toList(),
    rawJsonSnippet: snippet,
    apiTriageHint: apiHint,
    emergencyPhrasesFound: found,
  );
}

String? _pickStringField(Map<String, dynamic> data, List<String> keys) {
  for (final k in keys) {
    final v = data[k];
    if (v != null && v.toString().isNotEmpty) return v.toString();
  }
  return null;
}

List<DiseaseRanking> _parseDiseases(dynamic raw) {
  if (raw is! List<dynamic>) return [];
  final out = <DiseaseRanking>[];
  for (final item in raw) {
    if (item is Map) {
      final m = Map<String, dynamic>.from(item);
      if (m.length == 1) {
        final e = m.entries.first;
        final prob = double.tryParse(e.value.toString()) ?? 0.0;
        out.add(DiseaseRanking(name: e.key.toString(), probability: prob));
      } else {
        final name = m['Name'] ?? m['name'] ?? m['Disease'] ?? m['disease'];
        final p = m['Probability'] ?? m['probability'] ?? m['p'];
        if (name != null) {
          final prob = p != null ? (double.tryParse(p.toString()) ?? 0.0) : 0.0;
          out.add(DiseaseRanking(name: name.toString(), probability: prob));
        }
      }
    }
  }
  return out;
}
