import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:cms/content/health_faq.dart';
import 'package:cms/l10n/app_localizations.dart';
import 'package:cms/screens/service_screen.dart';
import 'package:cms/services/auth_service.dart';
import 'package:cms/services/health_assessment_controller.dart';
import 'package:cms/services/locale_controller.dart';
import 'package:cms/services/triage_from_analysis.dart';
import 'package:cms/theme/app_tokens.dart';
import 'package:cms/ui/mobadra_ui.dart';

/// Symptom triage (rule-based chat) + static FAQ. Prefer [createRoute] so [HealthAssessmentController] is provided.
class HealthAssistantScreen extends StatefulWidget {
  const HealthAssistantScreen({super.key, this.bookingUsername});

  /// Passed from [MobadraHomeTab] for booking; falls back to [AuthService.currentPatient].
  final String? bookingUsername;

  static Route<void> createRoute({String? bookingUsername}) {
    return MaterialPageRoute<void>(
      builder: (context) => ChangeNotifierProvider(
        create: (_) => HealthAssessmentController(),
        child: HealthAssistantScreen(bookingUsername: bookingUsername),
      ),
    );
  }

  @override
  State<HealthAssistantScreen> createState() => _HealthAssistantScreenState();
}

class _HealthAssistantScreenState extends State<HealthAssistantScreen> {
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final baseTheme = Theme.of(context);
    final textTheme = baseTheme.textTheme.apply(
      fontFamilyFallback: const ['Noto Sans Arabic', 'Noto Sans', 'sans-serif'],
    );

    return Theme(
      data: baseTheme.copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: AppColors.neutralSurface,
        appBar: MobadraAppBar(
          title: Text(l10n.healthAssistantTitle),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.language_outlined),
              tooltip: l10n.languageMenu,
              onSelected: (code) async {
                final loc = code == 'ar' ? const Locale('ar') : const Locale('en', 'US');
                await context.read<LocaleController>().setLocale(loc);
                if (!context.mounted) return;
                try {
                  context.read<HealthAssessmentController>().restartAssessment();
                } catch (_) {}
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'en', child: Text(l10n.languageEnglish)),
                PopupMenuItem(value: 'ar', child: Text(l10n.languageArabic)),
              ],
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 8),
              child: SegmentedButton<int>(
                segments: [
                  ButtonSegment<int>(
                    value: 0,
                    label: Text(l10n.symptomCheckTab),
                    icon: const Icon(Icons.healing_outlined, size: 18),
                  ),
                  ButtonSegment<int>(
                    value: 1,
                    label: Text(l10n.commonQuestionsTab),
                    icon: const Icon(Icons.quiz_outlined, size: 18),
                  ),
                ],
                selected: <int>{_segment},
                onSelectionChanged: (s) => setState(() => _segment = s.first),
              ),
            ),
            Expanded(
              child: _segment == 0
                  ? _SymptomCheckPanel(bookingUsername: widget.bookingUsername)
                  : const _FaqPanel(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqPanel extends StatelessWidget {
  const _FaqPanel();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
      itemCount: kHealthFaqEntries.length,
      itemBuilder: (context, i) {
        final e = kHealthFaqEntries[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ShadCard(
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                childrenPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 14),
                title: Text(e.question, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(e.answer, style: TextStyle(color: Colors.grey[800], height: 1.45)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SymptomCheckPanel extends StatefulWidget {
  const _SymptomCheckPanel({this.bookingUsername});
  final String? bookingUsername;

  @override
  State<_SymptomCheckPanel> createState() => _SymptomCheckPanelState();
}

class _SymptomCheckPanelState extends State<_SymptomCheckPanel> {
  String? _lastLanguageCode;

  @override
  Widget build(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    if (_lastLanguageCode != null && _lastLanguageCode != code) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          context.read<HealthAssessmentController>().restartAssessment();
        } catch (_) {}
      });
    }
    _lastLanguageCode = code;

    return Consumer<HealthAssessmentController>(
      builder: (context, c, _) {
        switch (c.step) {
          case HealthAssessmentStep.disclaimer:
            return _DisclaimerBody(
              onAccept: () {
                c.acceptDisclaimer(Localizations.localeOf(context));
              },
            );
          case HealthAssessmentStep.chatTriage:
            return _ChatTriageBody(controller: c);
          case HealthAssessmentStep.analyzing:
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.analyzing),
                ],
              ),
            );
          case HealthAssessmentStep.results:
            return _ResultsBody(controller: c, bookingUsername: widget.bookingUsername);
          case HealthAssessmentStep.error:
            return _ErrorBody(controller: c);
        }
      },
    );
  }
}

class _DisclaimerBody extends StatelessWidget {
  const _DisclaimerBody({required this.onAccept});
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset('assets/ai-assistant.gif', height: 100, fit: BoxFit.contain),
          const SizedBox(height: 16),
          Text(
            l10n.disclaimerTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.disclaimerBody,
            textAlign: TextAlign.start,
            style: TextStyle(color: Colors.grey[800], height: 1.45),
          ),
          const SizedBox(height: 24),
          ShadButton(
            onPressed: onAccept,
            child: Text(l10n.iUnderstandContinue),
          ),
        ],
      ),
    );
  }
}

class _ChatTriageBody extends StatefulWidget {
  const _ChatTriageBody({required this.controller});
  final HealthAssessmentController controller;

  @override
  State<_ChatTriageBody> createState() => _ChatTriageBodyState();
}

class _ChatTriageBodyState extends State<_ChatTriageBody> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = widget.controller;
    final s = c.session;
    if (c.busy && s == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.loadingQuestionnaire),
          ],
        ),
      );
    }
    if (s == null) {
      return Center(child: Text(l10n.noSession));
    }

    _scrollBottom();

    final lines = s.transcript;
    final typing = s.assistantTyping;
    final opts = s.awaitingChoice ? s.currentOptions : const <Map<String, dynamic>>[];
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final choiceCount = opts.length;
    final typingSlots = typing ? 1 : 0;
    final itemCount = lines.length + typingSlots + choiceCount;

    return ListView.builder(
      controller: _scroll,
      padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 20 + bottomInset + 8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < lines.length) {
          final line = lines[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _ChatFadeIn(
              listIndex: index,
              child: line.isUser
                  ? _AdaUserAnswer(text: line.text)
                  : _AdaAssistantQuestion(text: line.text),
            ),
          );
        }
        if (typing && index == lines.length) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: _WhatsAppTypingBubble(),
          );
        }
        final oi = index - lines.length - typingSlots;
        final o = opts[oi];
        final id = o['id']?.toString() ?? '';
        final label = o['label']?.toString() ?? id;
        final isLastChoice = oi == choiceCount - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLastChoice ? 8 : 10, top: oi == 0 ? 4 : 0),
          child: _ChatFadeIn(
            listIndex: lines.length + typingSlots + oi,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: _AdaOutlineChoiceButton(
                key: ValueKey<String>('opt|$id'),
                label: label,
                id: id,
                enabled: s.awaitingChoice && !c.busy,
                onPressed: (!s.awaitingChoice || c.busy) ? null : (sel) => c.selectChatOption(sel),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Directionally aligned “…” typing row while the next assistant line is delayed.
class _WhatsAppTypingBubble extends StatefulWidget {
  const _WhatsAppTypingBubble();

  @override
  State<_WhatsAppTypingBubble> createState() => _WhatsAppTypingBubbleState();
}

class _WhatsAppTypingBubbleState extends State<_WhatsAppTypingBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color.alphaBlend(base.withValues(alpha: 0.92), Theme.of(context).colorScheme.surface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade400.withValues(alpha: 0.35)),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 18, vertical: 13),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              return Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: TextDirection.ltr,
                children: [
                  for (var i = 0; i < 3; i++)
                    Padding(
                      padding: EdgeInsetsDirectional.only(end: i < 2 ? 6 : 0),
                      child: _TypingDot(phase: (t + i * 0.21) % 1.0),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TypingDot extends StatelessWidget {
  const _TypingDot({required this.phase});
  final double phase;

  @override
  Widget build(BuildContext context) {
    final wave = (1 + math.sin(phase * math.pi * 2)) / 2;
    final opacity = 0.35 + 0.55 * wave;
    final scale = 0.82 + 0.18 * wave;
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.chatAssistantText.withValues(alpha: 0.55),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// Fade + slight vertical slide so new transcript lines and choices feel continuous.
class _ChatFadeIn extends StatelessWidget {
  const _ChatFadeIn({required this.listIndex, required this.child});

  final int listIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ms = (260 + (listIndex * 28).clamp(0, 120)).clamp(260, 400);
    return TweenAnimationBuilder<double>(
      key: ValueKey<int>(listIndex),
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: ms),
      curve: Curves.easeOutCubic,
      builder: (context, t, c) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 10),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}

/// Assistant copy aligned to the start edge in reading direction.
class _AdaAssistantQuestion extends StatelessWidget {
  const _AdaAssistantQuestion({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.92),
        child: Text(
          text,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: AppColors.chatAssistantText,
            height: 1.38,
            fontSize: 17,
            fontWeight: FontWeight.w500,
            fontFamily: 'serif',
            fontFamilyFallback: const ['Georgia', 'Noto Serif', 'Noto Sans Arabic', 'Roboto'],
          ),
        ),
      ),
    );
  }
}

/// Past user answers: compact pill on the end edge.
class _AdaUserAnswer extends StatelessWidget {
  const _AdaUserAnswer({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.88),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.55), width: 1.2),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              text,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                height: 1.3,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdaOutlineChoiceButton extends StatelessWidget {
  const _AdaOutlineChoiceButton({
    super.key,
    required this.label,
    required this.id,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final String id;
  final bool enabled;
  final void Function(String id)? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled && onPressed != null ? () => onPressed!(id) : null,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.65), width: 1.25),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              label,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: AppColors.primary.withValues(alpha: enabled ? 1 : 0.45),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultsBody extends StatelessWidget {
  const _ResultsBody({required this.controller, this.bookingUsername});
  final HealthAssessmentController controller;
  final String? bookingUsername;

  String _headline(AppLocalizations l10n, TriageBucket b) {
    switch (b) {
      case TriageBucket.emergency:
        return l10n.headlineEmergency;
      case TriageBucket.urgent:
        return l10n.headlineUrgent;
      case TriageBucket.gp:
        return l10n.headlineGp;
      case TriageBucket.selfCare:
        return l10n.headlineSelfCare;
    }
  }

  Color _accent(TriageBucket b, ColorScheme cs) {
    switch (b) {
      case TriageBucket.emergency:
        return Colors.red.shade700;
      case TriageBucket.urgent:
        return Colors.deepOrange.shade700;
      case TriageBucket.gp:
        return cs.primary;
      case TriageBucket.selfCare:
        return Colors.teal.shade700;
    }
  }

  String _visitGuidance(AppLocalizations l10n, TriageBucket b) {
    switch (b) {
      case TriageBucket.emergency:
        return l10n.visitGuidanceEmergency;
      case TriageBucket.urgent:
        return l10n.visitGuidanceUrgent;
      case TriageBucket.gp:
        return l10n.visitGuidanceGp;
      case TriageBucket.selfCare:
        return l10n.visitGuidanceSelfCare;
    }
  }

  void _book(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = Provider.of<AuthService>(context, listen: false);
    final name = (bookingUsername?.trim().isNotEmpty == true)
        ? bookingUsername!.trim()
        : (auth.currentPatient?.displayName ?? 'Patient');
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ServiceScreen(
          service: l10n.serviceBookVisit,
          username: name,
          initialNotes: controller.bookingNotesSummary(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = controller.triage;
    final cs = Theme.of(context).colorScheme;
    if (t == null) {
      return Center(child: Text(l10n.noResults));
    }
    final accent = _accent(t.bucket, cs);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShadCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    textDirection: Directionality.of(context),
                    children: [
                      Icon(Icons.medical_information_outlined, color: accent, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _headline(l10n, t.bucket),
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: accent),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.notADiagnosisBanner,
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.grey[800], height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.whyNoCauseTitle,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[900],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.whyNoCauseBody,
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.grey[800], height: 1.45),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.aboutVisitTitle,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[900],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _visitGuidance(l10n, t.bucket),
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.grey[800], height: 1.45),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.assistantLegalFooter,
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.grey[700], height: 1.4, fontSize: 13),
                  ),
                  if (controller.errorMessage != null && controller.errorMessage!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      controller.errorMessage!,
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.orange.shade900, height: 1.35),
                    ),
                  ],
                  if (t.careSummary != null && t.careSummary!.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      t.careSummary!.trim(),
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.grey[900], height: 1.45),
                    ),
                  ],
                  if (t.apiTriageHint != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.additionalNotes(t.apiTriageHint!),
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (t.diseases.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              l10n.possibleConditionsRanked,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ...t.diseases.map(
              (d) => ShadCard(
                child: ListTile(
                  title: Text(d.name, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.start),
                  trailing: Text('${(d.probability * 100).clamp(0, 100).toStringAsFixed(0)}%'),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (t.bucket == TriageBucket.emergency || t.bucket == TriageBucket.urgent)
            ShadButton(
              onPressed: () => _book(context),
              child: Text(l10n.bookVisitUrgent),
            )
          else if (t.bucket == TriageBucket.gp)
            ShadButton(
              onPressed: () => _book(context),
              child: Text(l10n.bookVisit),
            )
          else ...[
            ShadButton.outline(
              onPressed: () => _book(context),
              child: Text(l10n.stillBookVisit),
            ),
          ],
          const SizedBox(height: 10),
          ShadButton.outline(
            onPressed: controller.restartAssessment,
            child: Text(l10n.startOver),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.controller});
  final HealthAssessmentController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final message = controller.loadError != null
        ? l10n.couldNotLoadQuestionnaire(controller.loadError!)
        : (controller.errorMessage ?? l10n.somethingWentWrong);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_outlined, size: 56, color: Colors.grey[500]),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[800]),
          ),
          const SizedBox(height: 24),
          ShadButton(
            onPressed: controller.retryAfterError,
            child: Text(l10n.tryAgain),
          ),
          const SizedBox(height: 8),
          ShadButton.outline(
            onPressed: controller.restartAssessment,
            child: Text(l10n.startOver),
          ),
        ],
      ),
    );
  }
}
