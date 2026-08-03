// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'كرييتف مبادرة';

  @override
  String get healthAssistantTitle => 'المساعد الصحي';

  @override
  String get symptomCheckTab => 'فحص الأعراض';

  @override
  String get commonQuestionsTab => 'أسئلة شائعة';

  @override
  String get languageMenu => 'اللغة';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get disclaimerTitle => 'قبل المتابعة';

  @override
  String get disclaimerBody =>
      'يستخدم هذا المساعد استبيانًا ثابتًا (خيارات مبنية على قواعد فقط). ليس ذكاءً اصطناعيًا توليديًا، وليس تشخيصًا، وليس بديلاً عن طبيب مرخّص. تبقى إجاباتك على جهازك ما لم تختر مشاركتها (مثلًا في ملاحظات الحجز).\n\nإذا كنت تعتقد أن لديك حالة طارئة—ألم في الصدر مع ضيق نفس، أو علامات سكتة دماغية، أو نزيف شديد، أو ارتباك، أو لا تستطيع التنفس—اتصل برقم الطوارئ المحلي أو اذهب لأقرب قسم طوارئ.\n\nيجب على الفريق السريري مراجعة assets/rule_based_triage.json قبل اعتبار هذا المسار إرشادًا طبيًا جاهزًا للإنتاج.\n\nبالمتابعة، تؤكد أنك تفهم هذه الحدود.';

  @override
  String get iUnderstandContinue => 'أفهم — متابعة';

  @override
  String get loadingQuestionnaire => 'جارٍ تحميل الاستبيان…';

  @override
  String get noSession => 'لا توجد جلسة.';

  @override
  String get analyzing => 'جارٍ التحليل…';

  @override
  String get noResults => 'لا توجد نتائج.';

  @override
  String get notADiagnosisBanner =>
      'هذا ليس تشخيصًا. إذا شعرت بتوعك شديد، اطلب رعاية شخصية أو خدمات الطوارئ.';

  @override
  String get whyNoCauseTitle => 'لماذا لا نذكر سببًا هنا';

  @override
  String get whyNoCauseBody =>
      'يعكس هذا الشاشة كيف تربط إجاباتك المختارة مستوى رعاية عامًا للتخطيط. لا يحدد ما يسبب أعراضك—قد تنتج حالات مختلفة أنماطًا متشابهة في استبيان قصير. الطبيب الحاضر فقط، مع التاريخ الكامل والفحص (والتحاليل عند الحاجة)، يمكنه تضييق الأسباب.';

  @override
  String get aboutVisitTitle => 'حول زيارة شخصية';

  @override
  String get visitGuidanceEmergency =>
      'في هذا المستوى، تريد معظم الخدمات تقييمك بشكل عاجل شخصيًا (مثلًا خدمات الطوارئ أو أقرب قسم طوارئ)، خاصة إذا كانت الأعراض شديدة أو مفاجئة أو تتفاقم. زيارة روتينية لاحقًا لا تحل محل ذلك عندما قد تنطبق أنماط طوارئ.';

  @override
  String get visitGuidanceUrgent =>
      'في هذا المستوى، غالبًا ما تكون الرعاية الشخصية في نفس اليوم أو العاجلة مناسبة إذا كانت الأعراض ملحّة أو لست متأكدًا. يمكنك حجز زيارة روتينية إن كان ذلك متاحًا—لكن لا تؤجل إذا ساءت حالتك.';

  @override
  String get visitGuidanceGp =>
      'في هذا المستوى، غالبًا ما تكون زيارة طبيب قريبًا أو روتينية مناسبة إذا استمرت الأعراض أو تكررت أو أقلقتك. ليست إلزامية للجميع؛ استخدم شعورك الواقعي كدليل نهائي.';

  @override
  String get visitGuidanceSelfCare =>
      'في هذا المستوى، يبدأ كثيرون بالعناية الذاتية والمراقبة، ويحجزون زيارة إذا تغيّر شيء أو تفاقم. الزيارة غير مستبعدة—احجز متى أردت طمأنينة أو طالت الأعراض.';

  @override
  String get assistantLegalFooter =>
      'يقدّم هذا المساعد معلومات عامة واقتراحات تخطيط للرعاية فقط. ليس نصيحة طبية أو قانونية لحالتك؛ يطبق طبيبك والقواعد المحلية.';

  @override
  String additionalNotes(Object hint) {
    return 'ملاحظات إضافية: $hint';
  }

  @override
  String get possibleConditionsRanked => 'حالات محتملة (مرتبة)';

  @override
  String get bookVisitUrgent => 'احجز زيارة — عاجل';

  @override
  String get bookVisit => 'احجز زيارة';

  @override
  String get stillBookVisit => 'احجز زيارة على أي حال';

  @override
  String get startOver => 'ابدأ من جديد';

  @override
  String get tryAgain => 'إعادة المحاولة';

  @override
  String get somethingWentWrong => 'حدث خطأ ما.';

  @override
  String couldNotLoadQuestionnaire(Object error) {
    return 'تعذّر تحميل الاستبيان: $error';
  }

  @override
  String get headlineEmergency => 'احتمال قلق على مستوى الطوارئ';

  @override
  String get headlineUrgent => 'قد تكون الرعاية الطبية العاجلة مناسبة';

  @override
  String get headlineGp => 'فكّر بحجز زيارة روتينية';

  @override
  String get headlineSelfCare => 'خطورة أقل — عناية ذاتية أو متابعة روتينية';

  @override
  String get serviceBookVisit => 'حجز زيارة';
}
