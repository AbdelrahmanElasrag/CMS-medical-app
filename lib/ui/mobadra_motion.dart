import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Calm entrances and tab changes. Curves stay soft; nothing bounces hard.
extension MobadraMotion on Widget {
  Widget mobadraFadeSlide({int delayMs = 0}) {
    return animate(delay: delayMs.ms)
        .fadeIn(duration: 460.ms, curve: Curves.easeOutCubic)
        .slideY(
          begin: 0.08,
          end: 0,
          duration: 520.ms,
          curve: Curves.easeOutCubic,
        );
  }

  /// Fade, rise, and a soft scale. Used for cards and rows.
  Widget mobadraCardIn({int delayMs = 0}) {
    return animate(delay: delayMs.ms)
        .fadeIn(duration: 520.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.14, end: 0, duration: 560.ms, curve: Curves.easeOutCubic)
        .scale(
          begin: const Offset(0.94, 0.94),
          end: const Offset(1, 1),
          duration: 560.ms,
          curve: Curves.easeOutCubic,
        );
  }

  /// Fade, rise, and a small settle. Used for the primary action.
  Widget mobadraPop({int delayMs = 0}) {
    return animate(delay: delayMs.ms)
        .fadeIn(duration: 420.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.16, end: 0, duration: 500.ms, curve: Curves.easeOutCubic)
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
          duration: 520.ms,
          curve: Curves.easeOutBack,
        );
  }

}

/// Slow vertical drift for decorative marks.
class MobadraDrift extends StatefulWidget {
  const MobadraDrift({super.key, required this.child});

  final Widget child;

  @override
  State<MobadraDrift> createState() => _MobadraDriftState();
}

class _MobadraDriftState extends State<MobadraDrift> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Transform.translate(
          offset: Offset(0, -10 * t),
          child: Transform.rotate(angle: (t - 0.5) * 0.12, child: child),
        );
      },
      child: widget.child,
    );
  }
}

Widget mobadraStagger(int index, Widget child) => child.mobadraFadeSlide(delayMs: 55 * index);

/// Keeps visited tabs alive and fades between them.
class MobadraTabHost extends StatefulWidget {
  const MobadraTabHost({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  State<MobadraTabHost> createState() => _MobadraTabHostState();
}

class _MobadraTabHostState extends State<MobadraTabHost> {
  final Set<int> _built = <int>{};

  @override
  Widget build(BuildContext context) {
    _built.add(widget.index);
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        for (final i in _built)
          Positioned.fill(
            child: _TabPane(
              active: widget.index == i,
              reduceMotion: reduce,
              child: widget.children[i],
            ),
          ),
      ],
    );
  }
}

class _TabPane extends StatefulWidget {
  const _TabPane({
    required this.active,
    required this.reduceMotion,
    required this.child,
  });

  final bool active;
  final bool reduceMotion;
  final Widget child;

  @override
  State<_TabPane> createState() => _TabPaneState();
}

class _TabPaneState extends State<_TabPane> {
  late bool _visible = widget.active;

  @override
  void didUpdateWidget(_TabPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      setState(() => _visible = widget.active);
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.reduceMotion ? Duration.zero : const Duration(milliseconds: 340);
    return IgnorePointer(
      ignoring: !widget.active,
      child: ExcludeSemantics(
        excluding: !widget.active,
        child: AnimatedSlide(
          offset: _visible ? Offset.zero : const Offset(0, 0.025),
          duration: duration,
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: duration,
            curve: Curves.easeOutCubic,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
