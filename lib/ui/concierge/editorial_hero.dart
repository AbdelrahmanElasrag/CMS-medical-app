import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:cms/theme/concierge_theme.dart';

/// Looping hero film behind the editorial headline.
///
/// A dark wash sits on top of the picture so the type stays readable.
/// The painted wash shows until the video is ready, and if playback cannot start.
class EditorialHero extends StatefulWidget {
  const EditorialHero({super.key, this.playing = true});

  /// False while Home is not the visible tab.
  final bool playing;

  @override
  State<EditorialHero> createState() => _EditorialHeroState();
}

class _EditorialHeroState extends State<EditorialHero> with WidgetsBindingObserver {
  static const _asset = 'assets/hero_background.webm';

  VideoPlayerController? _controller;
  bool _ready = false;
  bool _appResumed = true;
  bool _routeVisible = true;
  bool _motionOk = true;
  bool _rewinding = false;

  bool get _isWidgetTest => WidgetsBinding.instance.runtimeType.toString().contains('Test');

  bool get _shouldPlay => widget.playing && _appResumed && _routeVisible && _motionOk;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_isWidgetTest) return;
    _start();
  }

  Future<void> _start() async {
    final controller = VideoPlayerController.asset(
      _asset,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _controller = controller;
    controller.addListener(_keepLooping);
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      if (!mounted) return;
      setState(() => _ready = true);
      _sync();
    } catch (_) {
      controller.removeListener(_keepLooping);
      await controller.dispose();
      if (_controller == controller) _controller = null;
    }
  }

  void _keepLooping() {
    final controller = _controller;
    if (_rewinding || controller == null || !controller.value.isInitialized || !_shouldPlay) return;
    final value = controller.value;
    if (value.isPlaying || value.duration == Duration.zero) return;
    if (value.position < value.duration - const Duration(milliseconds: 180)) return;
    _rewinding = true;
    controller.seekTo(Duration.zero).whenComplete(() {
      _rewinding = false;
      if (_shouldPlay && _controller == controller) controller.play();
    });
  }

  void _sync() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (_shouldPlay) {
      controller.play();
    } else {
      controller.pause();
    }
  }

  @override
  void didUpdateWidget(EditorialHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playing != widget.playing) _sync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = ModalRoute.of(context)?.isCurrent ?? true;
    final motionOk = !MediaQuery.disableAnimationsOf(context);
    if (visible == _routeVisible && motionOk == _motionOk) return;
    _routeVisible = visible;
    _motionOk = motionOk;
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final resumed = state == AppLifecycleState.resumed;
    if (resumed == _appResumed) return;
    _appResumed = resumed;
    _sync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final controller = _controller;
    _controller = null;
    controller?.removeListener(_keepLooping);
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final size = controller?.value.size ?? Size.zero;
    final showVideo = _ready &&
        _motionOk &&
        controller != null &&
        controller.value.isInitialized &&
        size.width > 0 &&
        size.height > 0;
    return RepaintBoundary(
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Color(0xFF14110E)),
            if (!showVideo) const CustomPaint(painter: _EditorialHeroPainter(), child: SizedBox.expand()),
            if (showVideo)
              FittedBox(
                fit: BoxFit.cover,
                alignment: Alignment.center,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
            const IgnorePointer(child: _HeroScrim()),
          ],
        ),
      ),
    );
  }
}

/// Keeps the headline readable without covering the picture on the right.
class _HeroScrim extends StatelessWidget {
  const _HeroScrim();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x99000000),
            Color(0x22000000),
            Color(0x00000000),
            Color(0x00000000),
            EditorialPalette.canvas,
          ],
          stops: [0, 0.14, 0.28, 0.5, 1],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xC4100E0C),
              Color(0x73100E0C),
              Color(0x00100E0C),
            ],
            stops: [0, 0.34, 0.68],
          ),
        ),
        child: SizedBox.expand(),
      ),
    );
  }
}

class _EditorialHeroPainter extends CustomPainter {
  const _EditorialHeroPainter();

  void _glow(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = const Color(0xFF14110E));

    _glow(canvas, Offset(size.width * 0.82, size.height * 0.18), size.width * 0.95, const Color(0xFFE7D3BE));
    _glow(canvas, Offset(size.width * 0.64, size.height * 0.42), size.width * 0.62, const Color(0xFFC9A27C));
    _glow(canvas, Offset(size.width * 0.94, size.height * 0.58), size.width * 0.42, const Color(0xFFF3E6D8));

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xE6100E0C),
            Color(0x66100E0C),
            Color(0x00100E0C),
          ],
          stops: [0, 0.46, 0.82],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
