/// Conservative offline hints when the EndlessMedical API is unreachable.
/// Does not diagnose; only nudges the user toward emergency care when selected
/// feature *names* match high-risk patterns.
class OfflineTriageHeuristics {
  static bool suggestPossibleEmergency(Iterable<String> featureNames) {
    const patterns = [
      'ChestPain',
      'Hemoptysis',
      'Syncope',
      'Stroke',
      'CVA',
      'Sepsis',
      'Meningitis',
      'Anaphylaxis',
      'Airway',
      'Stridor',
      'Paralysis',
      'Hemiparesis',
      'Aphasia',
      'PulmonaryEmbolism',
      'PEYes',
      'Tamponade',
      'Aortic',
      'Dissection',
    ];
    for (final name in featureNames) {
      final n = name.toUpperCase();
      for (final p in patterns) {
        if (n.contains(p.toUpperCase())) return true;
      }
    }
    return false;
  }
}
