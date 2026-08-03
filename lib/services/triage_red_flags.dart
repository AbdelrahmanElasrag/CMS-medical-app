/// Conservative red-flag text scan (ported from cms-backend symptomTriageGuardrails).
/// Used with a short narrative built from triage tags for extra safety beyond explicit JSON `forceEmergency`.

typedef _Rule = ({String code, List<RegExp> patterns});

final List<_Rule> kTriageRedFlagRules = [
  (
    code: 'chest_pain_pressure',
    patterns: [
      RegExp(r'chest\s*pain', caseSensitive: false),
      RegExp(r'chest\s*pressure', caseSensitive: false),
      RegExp(r'crushing\s*chest', caseSensitive: false),
      RegExp(r'pain\s*in\s*chest', caseSensitive: false),
    ],
  ),
  (
    code: 'stroke_like',
    patterns: [
      RegExp(r'\bface\s*droop', caseSensitive: false),
      RegExp(r'\barm\s*weak', caseSensitive: false),
      RegExp(r'\bspeech\s*trouble', caseSensitive: false),
      RegExp(r'\bslurred\s*speech', caseSensitive: false),
      RegExp(r'sudden\s*weakness\s*on\s*one\s*side', caseSensitive: false),
      RegExp(r'\bstroke\b', caseSensitive: false),
    ],
  ),
  (
    code: 'severe_bleeding',
    patterns: [
      RegExp(r'severe\s*bleed', caseSensitive: false),
      RegExp(r'heavy\s*bleed', caseSensitive: false),
      RegExp(r'vomit(?:ing)?\s*blood', caseSensitive: false),
      RegExp(r'cough(?:ing)?\s*blood', caseSensitive: false),
      RegExp(r'black\s*stool', caseSensitive: false),
    ],
  ),
  (
    code: 'breathing_distress',
    patterns: [
      RegExp(r"can'?t\s*breathe", caseSensitive: false),
      RegExp(r'cannot\s*breathe', caseSensitive: false),
      RegExp(r'trouble\s*breath', caseSensitive: false),
      RegExp(r'short\s*of\s*breath', caseSensitive: false),
      RegExp(r'severe\s*wheez', caseSensitive: false),
      RegExp(r'chok(?:e|ing)', caseSensitive: false),
      RegExp(r'turning\s*blue', caseSensitive: false),
      RegExp(r'cyanos', caseSensitive: false),
    ],
  ),
  (
    code: 'altered_mental_severe',
    patterns: [
      RegExp(r'confus(?:ed|ion)', caseSensitive: false),
      RegExp(r'unresponsive', caseSensitive: false),
      RegExp(r'loss\s*of\s*consciousness', caseSensitive: false),
      RegExp(r'faint(?:ed|ing)?', caseSensitive: false),
      RegExp(r'seizure', caseSensitive: false),
    ],
  ),
  (
    code: 'severe_abdominal_emergency',
    patterns: [
      RegExp(r'severe\s*abdominal\s*pain', caseSensitive: false),
      RegExp(r'rigid\s*abdomen', caseSensitive: false),
    ],
  ),
];

/// Returns matching red-flag codes when [narrative] (built from tags + user-visible path) hits a rule.
List<String> evaluateRedFlagCodes(String narrative) {
  final text = narrative.toLowerCase();
  final out = <String>[];
  for (final r in kTriageRedFlagRules) {
    if (r.patterns.any((p) => p.hasMatch(text))) {
      out.add(r.code);
    }
  }
  return out;
}
