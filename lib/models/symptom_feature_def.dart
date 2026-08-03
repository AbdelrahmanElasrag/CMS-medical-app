// Parsed row from EndlessMedical SymptomsOutput.json

class SymptomFeatureChoice {
  final String laytext;
  final int value;

  SymptomFeatureChoice({required this.laytext, required this.value});

  factory SymptomFeatureChoice.fromJson(Map<String, dynamic> json) {
    return SymptomFeatureChoice(
      laytext: json['laytext'] as String? ?? json['text'] as String? ?? '',
      value: (json['value'] as num?)?.toInt() ?? 0,
    );
  }
}

class SymptomFeatureDef {
  final String name;
  final String laytext;
  final String text;
  final String type;
  final bool isPatientProvided;
  final double? min;
  final double? max;
  final double? defaultValue;
  final List<SymptomFeatureChoice> choices;

  SymptomFeatureDef({
    required this.name,
    required this.laytext,
    required this.text,
    required this.type,
    required this.isPatientProvided,
    this.min,
    this.max,
    this.defaultValue,
    this.choices = const [],
  });

  factory SymptomFeatureDef.fromJson(Map<String, dynamic> json) {
    final choicesJson = json['choices'] as List<dynamic>?;
    return SymptomFeatureDef(
      name: json['name'] as String? ?? '',
      laytext: json['laytext'] as String? ?? '',
      text: json['text'] as String? ?? '',
      type: json['type'] as String? ?? '',
      isPatientProvided: json['IsPatientProvided'] as bool? ?? false,
      min: (json['min'] as num?)?.toDouble(),
      max: (json['max'] as num?)?.toDouble(),
      defaultValue: (json['default'] as num?)?.toDouble(),
      choices: choicesJson
              ?.map((e) => SymptomFeatureChoice.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );
  }
}
