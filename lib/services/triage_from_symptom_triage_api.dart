import 'dart:convert';

import 'package:cms/services/triage_from_analysis.dart';

/// Maps CMS `POST /health/symptom-triage` JSON to [TriageAssessment] for existing UI.
TriageAssessment triageFromSymptomTriageResponse(Map<String, dynamic> json) {
  final data = (json['data'] is Map<String, dynamic>) ? json['data'] as Map<String, dynamic> : json;

  final urgency = data['urgency']?.toString() ?? 'self_care';
  final TriageBucket bucket;
  switch (urgency) {
    case 'emergency':
      bucket = TriageBucket.emergency;
      break;
    case 'urgent_care':
      bucket = TriageBucket.urgent;
      break;
    case 'routine':
      bucket = TriageBucket.gp;
      break;
    case 'self_care':
    default:
      bucket = TriageBucket.selfCare;
      break;
  }

  final flags = data['redFlagsTriggered'];
  final emergencyPhrasesFound = <String>[
    if (flags is List) ...flags.map((e) => e.toString()),
  ];

  final conds = data['possibleConditions'];
  final diseases = <DiseaseRanking>[];
  if (conds is List) {
    for (final c in conds) {
      if (c is! Map) continue;
      final m = Map<String, dynamic>.from(c);
      final name = m['name']?.toString() ?? '';
      if (name.isEmpty) continue;
      final p = m['probability'];
      final prob = p is num ? p.toDouble().clamp(0.0, 1.0) : 0.28;
      diseases.add(DiseaseRanking(name: name, probability: prob));
    }
  }
  diseases.sort((a, b) => b.probability.compareTo(a.probability));

  final summary = data['summary']?.toString() ?? '';
  final steps = data['suggestedNextSteps'];
  final hint = steps is List && steps.isNotEmpty ? steps.map((e) => e.toString()).take(3).join(' • ') : null;

  final snippet = jsonEncode(data);
  final raw = snippet.length > 800 ? '${snippet.substring(0, 800)}…' : snippet;

  return TriageAssessment(
    bucket: bucket,
    diseases: diseases.take(8).toList(),
    rawJsonSnippet: raw,
    apiTriageHint: hint,
    emergencyPhrasesFound: emergencyPhrasesFound,
    careSummary: summary.isNotEmpty ? summary : null,
    triageSource: data['triageSource']?.toString(),
  );
}
