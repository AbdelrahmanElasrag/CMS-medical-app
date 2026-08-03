import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Creative Mobadra'**
  String get appTitle;

  /// No description provided for @healthAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Health assistant'**
  String get healthAssistantTitle;

  /// No description provided for @symptomCheckTab.
  ///
  /// In en, this message translates to:
  /// **'Symptom check'**
  String get symptomCheckTab;

  /// No description provided for @commonQuestionsTab.
  ///
  /// In en, this message translates to:
  /// **'Common questions'**
  String get commonQuestionsTab;

  /// No description provided for @languageMenu.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageMenu;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @disclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Before you continue'**
  String get disclaimerTitle;

  /// No description provided for @disclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'This assistant uses a fixed questionnaire (rule-based choices only). It is not generative AI, not a diagnosis, and not a substitute for a licensed clinician. Answers stay on your device unless you choose to share them (for example in booking notes).\n\nIf you might be having an emergency—chest pain with shortness of breath, signs of stroke, severe bleeding, confusion, or you cannot breathe—call your local emergency number or go to the nearest emergency department.\n\nClinical teams should review assets/rule_based_triage.json before treating this flow as production-ready medical guidance.\n\nBy continuing, you confirm you understand these limits.'**
  String get disclaimerBody;

  /// No description provided for @iUnderstandContinue.
  ///
  /// In en, this message translates to:
  /// **'I understand — continue'**
  String get iUnderstandContinue;

  /// No description provided for @loadingQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'Loading questionnaire…'**
  String get loadingQuestionnaire;

  /// No description provided for @noSession.
  ///
  /// In en, this message translates to:
  /// **'No session.'**
  String get noSession;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing…'**
  String get analyzing;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results.'**
  String get noResults;

  /// No description provided for @notADiagnosisBanner.
  ///
  /// In en, this message translates to:
  /// **'This is not a diagnosis. If you feel seriously unwell, seek in-person care or emergency services.'**
  String get notADiagnosisBanner;

  /// No description provided for @whyNoCauseTitle.
  ///
  /// In en, this message translates to:
  /// **'Why we do not name a cause here'**
  String get whyNoCauseTitle;

  /// No description provided for @whyNoCauseBody.
  ///
  /// In en, this message translates to:
  /// **'This screen reflects how your tapped answers map to a general care level for planning. It does not identify what is causing your symptoms—many different conditions can produce similar patterns on a short questionnaire. Only an in-person clinician, with a full history and exam (and tests if needed), can narrow down causes.'**
  String get whyNoCauseBody;

  /// No description provided for @aboutVisitTitle.
  ///
  /// In en, this message translates to:
  /// **'About an in-person visit'**
  String get aboutVisitTitle;

  /// No description provided for @visitGuidanceEmergency.
  ///
  /// In en, this message translates to:
  /// **'For this level, many services would want you assessed urgently in person (for example emergency services or the nearest emergency department), especially if symptoms are severe, sudden, or worsening. A routine visit later is not a substitute when emergency patterns may apply.'**
  String get visitGuidanceEmergency;

  /// No description provided for @visitGuidanceUrgent.
  ///
  /// In en, this message translates to:
  /// **'For this level, same-day or urgent in-person care is often reasonable if symptoms are significant or you are unsure. You can still book a routine visit if that is what you have access to—but do not delay if you feel worse.'**
  String get visitGuidanceUrgent;

  /// No description provided for @visitGuidanceGp.
  ///
  /// In en, this message translates to:
  /// **'For this level, a routine or soon clinician visit is often appropriate if symptoms persist, keep coming back, or worry you. It is not mandatory for every person; use how you feel in real life as the final guide.'**
  String get visitGuidanceGp;

  /// No description provided for @visitGuidanceSelfCare.
  ///
  /// In en, this message translates to:
  /// **'For this level, many people start with self-care and monitoring, and book a visit if things change or worsen. A visit is not ruled out—book one whenever you want reassurance or symptoms drag on.'**
  String get visitGuidanceSelfCare;

  /// No description provided for @assistantLegalFooter.
  ///
  /// In en, this message translates to:
  /// **'This assistant offers general education and care-planning suggestions only. It is not medical or legal advice for your specific situation; your clinician and local rules apply.'**
  String get assistantLegalFooter;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional notes: {hint}'**
  String additionalNotes(Object hint);

  /// No description provided for @possibleConditionsRanked.
  ///
  /// In en, this message translates to:
  /// **'Possible conditions (ranked)'**
  String get possibleConditionsRanked;

  /// No description provided for @bookVisitUrgent.
  ///
  /// In en, this message translates to:
  /// **'Book a visit — urgent'**
  String get bookVisitUrgent;

  /// No description provided for @bookVisit.
  ///
  /// In en, this message translates to:
  /// **'Book a visit'**
  String get bookVisit;

  /// No description provided for @stillBookVisit.
  ///
  /// In en, this message translates to:
  /// **'Still book a visit'**
  String get stillBookVisit;

  /// No description provided for @startOver.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get startOver;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get somethingWentWrong;

  /// No description provided for @couldNotLoadQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'Could not load questionnaire: {error}'**
  String couldNotLoadQuestionnaire(Object error);

  /// No description provided for @headlineEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency-level concern possible'**
  String get headlineEmergency;

  /// No description provided for @headlineUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent medical care may be appropriate'**
  String get headlineUrgent;

  /// No description provided for @headlineGp.
  ///
  /// In en, this message translates to:
  /// **'Consider booking a routine visit'**
  String get headlineGp;

  /// No description provided for @headlineSelfCare.
  ///
  /// In en, this message translates to:
  /// **'Lower acuity — self-care or routine follow-up'**
  String get headlineSelfCare;

  /// No description provided for @serviceBookVisit.
  ///
  /// In en, this message translates to:
  /// **'Book visit'**
  String get serviceBookVisit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
