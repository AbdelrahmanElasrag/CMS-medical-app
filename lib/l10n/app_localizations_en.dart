// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Creative Mobadra';

  @override
  String get healthAssistantTitle => 'Health assistant';

  @override
  String get symptomCheckTab => 'Symptom check';

  @override
  String get commonQuestionsTab => 'Common questions';

  @override
  String get languageMenu => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get disclaimerTitle => 'Before you continue';

  @override
  String get disclaimerBody =>
      'This assistant uses a fixed questionnaire (rule-based choices only). It is not generative AI, not a diagnosis, and not a substitute for a licensed clinician. Answers stay on your device unless you choose to share them (for example in booking notes).\n\nIf you might be having an emergency—chest pain with shortness of breath, signs of stroke, severe bleeding, confusion, or you cannot breathe—call your local emergency number or go to the nearest emergency department.\n\nClinical teams should review assets/rule_based_triage.json before treating this flow as production-ready medical guidance.\n\nBy continuing, you confirm you understand these limits.';

  @override
  String get iUnderstandContinue => 'I understand — continue';

  @override
  String get loadingQuestionnaire => 'Loading questionnaire…';

  @override
  String get noSession => 'No session.';

  @override
  String get analyzing => 'Analyzing…';

  @override
  String get noResults => 'No results.';

  @override
  String get notADiagnosisBanner =>
      'This is not a diagnosis. If you feel seriously unwell, seek in-person care or emergency services.';

  @override
  String get whyNoCauseTitle => 'Why we do not name a cause here';

  @override
  String get whyNoCauseBody =>
      'This screen reflects how your tapped answers map to a general care level for planning. It does not identify what is causing your symptoms—many different conditions can produce similar patterns on a short questionnaire. Only an in-person clinician, with a full history and exam (and tests if needed), can narrow down causes.';

  @override
  String get aboutVisitTitle => 'About an in-person visit';

  @override
  String get visitGuidanceEmergency =>
      'For this level, many services would want you assessed urgently in person (for example emergency services or the nearest emergency department), especially if symptoms are severe, sudden, or worsening. A routine visit later is not a substitute when emergency patterns may apply.';

  @override
  String get visitGuidanceUrgent =>
      'For this level, same-day or urgent in-person care is often reasonable if symptoms are significant or you are unsure. You can still book a routine visit if that is what you have access to—but do not delay if you feel worse.';

  @override
  String get visitGuidanceGp =>
      'For this level, a routine or soon clinician visit is often appropriate if symptoms persist, keep coming back, or worry you. It is not mandatory for every person; use how you feel in real life as the final guide.';

  @override
  String get visitGuidanceSelfCare =>
      'For this level, many people start with self-care and monitoring, and book a visit if things change or worsen. A visit is not ruled out—book one whenever you want reassurance or symptoms drag on.';

  @override
  String get assistantLegalFooter =>
      'This assistant offers general education and care-planning suggestions only. It is not medical or legal advice for your specific situation; your clinician and local rules apply.';

  @override
  String additionalNotes(Object hint) {
    return 'Additional notes: $hint';
  }

  @override
  String get possibleConditionsRanked => 'Possible conditions (ranked)';

  @override
  String get bookVisitUrgent => 'Book a visit — urgent';

  @override
  String get bookVisit => 'Book a visit';

  @override
  String get stillBookVisit => 'Still book a visit';

  @override
  String get startOver => 'Start over';

  @override
  String get tryAgain => 'Try again';

  @override
  String get somethingWentWrong => 'Something went wrong.';

  @override
  String couldNotLoadQuestionnaire(Object error) {
    return 'Could not load questionnaire: $error';
  }

  @override
  String get headlineEmergency => 'Emergency-level concern possible';

  @override
  String get headlineUrgent => 'Urgent medical care may be appropriate';

  @override
  String get headlineGp => 'Consider booking a routine visit';

  @override
  String get headlineSelfCare =>
      'Lower acuity — self-care or routine follow-up';

  @override
  String get serviceBookVisit => 'Book visit';
}
