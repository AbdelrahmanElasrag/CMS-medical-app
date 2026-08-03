import 'package:cms/services/rule_triage_engine.dart';
import 'package:cms/services/triage_from_analysis.dart';
import 'package:flutter_test/flutter_test.dart';

const String _minimalFlow = '''
{
  "version": 1,
  "startId": "n0",
  "nodes": {
    "n0": {
      "assistantText": "Pick one",
      "options": [
        {"id": "to_em", "label": "Emergency path", "nextId": "t_em", "tagsAdd": ["cx_sob_yes"], "forceEmergency": true},
        {"id": "to_ok", "label": "OK path", "nextId": "t_ok", "tagsAdd": ["smoker_no"]}
      ]
    },
    "t_em": {
      "terminal": true,
      "triageBucket": "emergency",
      "careSummary": "Emergency copy",
      "hintBullets": ["A", "B"]
    },
    "t_ok": {
      "terminal": true,
      "computeFromTags": true,
      "careSummary": "Fallback",
      "hintBullets": ["X"]
    }
  }
}
''';

void main() {
  test('parseJson validates graph', () {
    final flow = RuleTriageFlow.parseJson(_minimalFlow);
    expect(flow.startId, 'n0');
    expect(flow.nodes.length, 3);
  });

  test('forceEmergency path reaches explicit terminal', () {
    final flow = RuleTriageFlow.parseJson(_minimalFlow);
    final s = RuleTriageSession(flow)..start();
    expect(s.awaitingChoice, isTrue);
    s.selectOption('to_em');
    expect(s.finished, isTrue);
    final o = s.buildOutcome();
    expect(o.bucket, TriageBucket.emergency);
    expect(o.careSummary, contains('Emergency'));
  });

  test('computed terminal uses tag scoring for mild path', () {
    final flow = RuleTriageFlow.parseJson(_minimalFlow);
    final s = RuleTriageSession(flow)..start();
    s.selectOption('to_ok');
    expect(s.finished, isTrue);
    final o = s.buildOutcome();
    expect(o.bucket, TriageBucket.selfCare);
    final ta = o.toTriageAssessment();
    expect(ta.triageSource, 'rule_based');
  });

  test('computed terminal: neuro tag narrative triggers red-flag emergency', () {
    const neuroFlow = '''
{
  "version": 1,
  "startId": "n0",
  "nodes": {
    "n0": {
      "assistantText": "Pick",
      "options": [
        {"id": "neuro", "label": "Neuro", "nextId": "t1", "tagsAdd": ["chief_neuro"]}
      ]
    },
    "t1": {
      "terminal": true,
      "computeFromTags": true,
      "careSummary": "Fallback",
      "hintBullets": []
    }
  }
}
''';
    final flow = RuleTriageFlow.parseJson(neuroFlow);
    final s = RuleTriageSession(flow)..start();
    s.selectOption('neuro');
    final o = s.buildOutcome();
    expect(o.bucket, TriageBucket.emergency);
    expect(o.redFlagCodes, isNotEmpty);
  });
}
