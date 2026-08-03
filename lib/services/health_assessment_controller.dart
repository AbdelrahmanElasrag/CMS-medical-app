import 'dart:math';

import 'package:flutter/foundation.dart';
import 'dart:ui' show Locale;
import 'package:flutter/services.dart' show rootBundle;

import 'package:cms/services/rule_triage_engine.dart';
import 'package:cms/services/triage_from_analysis.dart';

enum HealthAssessmentStep {
  disclaimer,
  chatTriage,
  analyzing,
  results,
  error,
}

/// Rule-based chat triage (no EndlessMedical, no LLM). Content from [assets/rule_based_triage.json].
class HealthAssessmentController extends ChangeNotifier {
  HealthAssessmentController() : _rand = Random();

  final Random _rand;
  RuleTriageFlow? _flow;
  RuleTriageSession? _session;
  String? _loadError;

  HealthAssessmentStep _step = HealthAssessmentStep.disclaimer;
  TriageAssessment? _triage;
  String? _errorMessage;
  bool _busy = false;

  HealthAssessmentStep get step => _step;
  TriageAssessment? get triage => _triage;
  String? get errorMessage => _errorMessage;
  bool get busy => _busy;

  RuleTriageSession? get session => _session;
  String? get loadError => _loadError;

  Future<void> acceptDisclaimer(Locale locale) async {
    if (_step != HealthAssessmentStep.disclaimer) return;
    _busy = true;
    _errorMessage = null;
    _loadError = null;
    notifyListeners();
    try {
      final path = locale.languageCode == 'ar'
          ? 'assets/rule_based_triage_ar.json'
          : 'assets/rule_based_triage.json';
      final raw = await rootBundle.loadString(path);
      _flow = RuleTriageFlow.parseJson(raw);
      _session = RuleTriageSession(_flow!);
      _session!.start();
      _step = HealthAssessmentStep.chatTriage;
    } catch (e) {
      _loadError = e.toString();
      _step = HealthAssessmentStep.error;
      _errorMessage = 'Could not load questionnaire: $e';
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> selectChatOption(String optionId) async {
    final s = _session;
    if (s == null || _step != HealthAssessmentStep.chatTriage) return;
    if (!s.awaitingChoice) return;

    s.stageChoice(optionId);
    notifyListeners();

    // 1–2 s pause with typing indicator (WhatsApp-style) before the next assistant line appears.
    final pauseMs = 1000 + _rand.nextInt(1001);
    await Future<void>.delayed(Duration(milliseconds: pauseMs));
    if (_session != s || _step != HealthAssessmentStep.chatTriage) return;

    s.commitStagedChoice();
    notifyListeners();

    if (s.finished) {
      _step = HealthAssessmentStep.analyzing;
      _errorMessage = null;
      notifyListeners();
      await Future<void>.delayed(const Duration(milliseconds: 450));
      try {
        final outcome = s.buildOutcome();
        _triage = outcome.toTriageAssessment();
        _step = HealthAssessmentStep.results;
      } catch (e) {
        _step = HealthAssessmentStep.error;
        _errorMessage = e.toString();
      }
      notifyListeners();
    }
  }

  Future<void> restartAssessment() async {
    _flow = null;
    _session = null;
    _triage = null;
    _errorMessage = null;
    _loadError = null;
    _step = HealthAssessmentStep.disclaimer;
    notifyListeners();
  }

  Future<void> retryAfterError() async {
    _errorMessage = null;
    _loadError = null;
    _step = HealthAssessmentStep.disclaimer;
    notifyListeners();
  }

  String bookingNotesSummary() {
    final buf = StringBuffer('Health assistant (rule-based questionnaire)\n');
    final s = _session;
    if (s != null) {
      buf.writeln('Tags: ${s.tags.join(', ')}');
      if (s.transcript.isNotEmpty) {
        buf.writeln('Last exchange: ${s.transcript.last.text}');
      }
    }
    if (_triage != null) {
      buf.writeln('Triage: ${_triage!.bucket.name}');
      if (_triage!.triageSource != null) buf.writeln('Source: ${_triage!.triageSource}');
      if (_triage!.careSummary != null && _triage!.careSummary!.trim().isNotEmpty) {
        buf.writeln('Summary: ${_triage!.careSummary!.trim()}');
      }
    }
    return buf.toString();
  }
}
