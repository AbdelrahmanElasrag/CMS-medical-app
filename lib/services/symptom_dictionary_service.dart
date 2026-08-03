import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'package:cms/models/symptom_feature_def.dart';

/// Loads EndlessMedical feature definitions from bundled JSON (patient-provided subset).
class SymptomDictionaryService {
  SymptomDictionaryService._();
  static final SymptomDictionaryService instance = SymptomDictionaryService._();

  List<SymptomFeatureDef>? _all;
  List<SymptomFeatureDef>? _patientProvided;

  bool get dictionaryReady => _patientProvided != null;

  Future<void> ensureLoaded() async {
    if (_all != null) return;
    final raw = await rootBundle.loadString('assets/symptoms_dictionary.json');
    final list = json.decode(raw) as List<dynamic>;
    _all = list
        .map((e) => SymptomFeatureDef.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((f) => f.name.isNotEmpty)
        .toList();
    _patientProvided = _all!.where((f) => f.isPatientProvided).toList();
  }

  List<SymptomFeatureDef> get patientProvidedFeatures {
    assert(_patientProvided != null, 'Call ensureLoaded() first');
    return _patientProvided!;
  }

  SymptomFeatureDef? byName(String name) {
    final all = _all;
    if (all == null) return null;
    for (final f in all) {
      if (f.name == name) return f;
    }
    return null;
  }

  /// Case-insensitive search on name, laytext, alias.
  List<SymptomFeatureDef> searchPatientProvided(String query, {int limit = 40}) {
    final pp = _patientProvided;
    if (pp == null) return [];
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    final out = <SymptomFeatureDef>[];
    for (final f in pp) {
      if (f.name.toLowerCase().contains(q) ||
          f.laytext.toLowerCase().contains(q) ||
          f.text.toLowerCase().contains(q)) {
        out.add(f);
        if (out.length >= limit) break;
      }
    }
    return out;
  }
}
