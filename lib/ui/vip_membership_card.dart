import 'package:cms/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class VipMembershipCard extends StatelessWidget {
  final String titleName;
  final String tierLabel;
  final int points;
  final String? subtitle;
  final String? qrData;
  final bool isLoadingQr;
  final String? qrErrorMessage;
  final VoidCallback? onRetryQr;
  final Widget? leading;
  final VoidCallback? onTap;
  final bool showChip;
  final String? brandLabel;

  const VipMembershipCard({
    required this.titleName,
    required this.tierLabel,
    required this.points,
    required this.qrData,
    this.subtitle,
    this.isLoadingQr = false,
    this.qrErrorMessage,
    this.onRetryQr,
    this.leading,
    this.onTap,
    this.showChip = false,
    this.brandLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final cardW = maxW;
        const aspect = 1.63; // feels like a real membership/credit card
        final cardH = _clampDouble(cardW / aspect, 186, 246);
        final qrSize = _clampDouble(cardH * 0.62, 112, 156);
        final qrPanelW = qrSize + 16;

        return SizedBox(
          width: cardW,
          height: cardH,
          child: PhysicalModel(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            elevation: 10,
            shadowColor: Colors.black.withValues(alpha: 0.28),
            clipBehavior: Clip.antiAlias,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppRadii.xl),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 0.55, 1.0],
                      colors: [
                        Color(0xFFFFF2C6),
                        Color(0xFFE0B358),
                        Color(0xFFB8842E),
                      ],
                    ),
                    // No border stroke — seamless edges.
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                    // SaveLayer removes the “halo”/edge artifacts on gradients.
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _LeftContent(
                              brandLabel: brandLabel,
                              titleName: titleName,
                              tierLabel: tierLabel,
                              points: points,
                              subtitle: subtitle,
                              leading: leading,
                              showChip: showChip,
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: qrPanelW,
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: _QrPanel(
                                size: qrSize,
                                theme: theme,
                                qrData: qrData,
                                isLoadingQr: isLoadingQr,
                                qrErrorMessage: qrErrorMessage,
                                onRetryQr: onRetryQr,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LeftContent extends StatelessWidget {
  final String? brandLabel;
  final String titleName;
  final String tierLabel;
  final int points;
  final String? subtitle;
  final Widget? leading;
  final bool showChip;

  const _LeftContent({
    required this.brandLabel,
    required this.titleName,
    required this.tierLabel,
    required this.points,
    required this.subtitle,
    required this.leading,
    required this.showChip,
  });

  @override
  Widget build(BuildContext context) {
    final onGold = const Color(0xFF1B1407);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              (brandLabel == null || brandLabel!.trim().isEmpty)
                  ? 'Mobadra VIP'
                  : brandLabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
                color: onGold.withValues(alpha: 0.85),
              ),
            ),
            const Spacer(),
            if (showChip) IgnorePointer(child: _ChipDecoration()),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                titleName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                  height: 1.06,
                  color: onGold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _TierPill(label: tierLabel),
            _PointsPill(points: points),
          ],
        ),
        const Spacer(),
        if (subtitle != null && subtitle!.trim().isNotEmpty)
          Text(
            subtitle!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: onGold.withValues(alpha: 0.78),
              height: 1.18,
            ),
          ),
      ],
    );
  }
}

class _TierPill extends StatelessWidget {
  final String label;
  const _TierPill({required this.label});

  @override
  Widget build(BuildContext context) {
    const onGold = Color(0xFF1B1407);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        color: Colors.white.withValues(alpha: 0.35),
        border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded,
              size: 14, color: onGold.withValues(alpha: 0.86)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
              color: onGold,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsPill extends StatelessWidget {
  final int points;
  const _PointsPill({required this.points});

  @override
  Widget build(BuildContext context) {
    const onGold = Color(0xFF1B1407);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        color: Colors.white.withValues(alpha: 0.35),
        border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded,
              size: 14, color: onGold.withValues(alpha: 0.86)),
          const SizedBox(width: 6),
          Text(
            'Points: $points',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
              color: onGold,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _QrPanel extends StatelessWidget {
  final double size;
  final ThemeData theme;
  final String? qrData;
  final bool isLoadingQr;
  final String? qrErrorMessage;
  final VoidCallback? onRetryQr;

  const _QrPanel({
    required this.size,
    required this.theme,
    required this.qrData,
    required this.isLoadingQr,
    required this.qrErrorMessage,
    required this.onRetryQr,
  });

  @override
  Widget build(BuildContext context) {
    final onGold = const Color(0xFF1B1407);

    return Container(
      width: size + 16,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: isLoadingQr
              ? _QrLoading(key: const ValueKey('loading'))
              : (qrData == null || (qrErrorMessage != null))
                  ? _QrError(
                      key: const ValueKey('error'),
                      message: qrErrorMessage ?? 'Could not load QR code',
                      onRetry: onRetryQr,
                      onGold: onGold,
                    )
                  : QrImageView(
                      key: const ValueKey('qr'),
                      data: qrData!,
                      version: QrVersions.auto,
                      size: size,
                      backgroundColor: Colors.transparent,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF1B1407),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF1B1407),
                      ),
                      errorStateBuilder: (cxt, err) => _QrError(
                        message: 'QR render error',
                        onRetry: onRetryQr,
                        onGold: onGold,
                      ),
                    ),
        ),
      ),
    );
  }
}

class _QrLoading extends StatelessWidget {
  const _QrLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.6),
      ),
    );
  }
}

class _QrError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final Color onGold;

  const _QrError({
    required this.message,
    required this.onRetry,
    required this.onGold,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final canRetry = onRetry != null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_2_rounded,
              color: onGold.withValues(alpha: 0.55),
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: onGold.withValues(alpha: 0.72),
                fontWeight: FontWeight.w700,
                height: 1.15,
                fontSize: 12.5,
              ),
            ),
            if (canRetry) ...[
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: onGold.withValues(alpha: 0.28)),
                  foregroundColor: onGold.withValues(alpha: 0.88),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChipDecoration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 24,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.32),
              Colors.white.withValues(alpha: 0.06),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: CustomPaint(painter: _ChipLinesPainter()),
      ),
    );
  }
}

class _ChipLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF1B1407).withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    const pad = 6.0;
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(pad, pad, size.width - pad * 2, size.height - pad * 2),
      const Radius.circular(7),
    );
    canvas.drawRRect(r, p);

    for (final x in [size.width * 0.45, size.width * 0.62]) {
      canvas.drawLine(Offset(x, pad + 2), Offset(x, size.height - pad - 2), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

double _clampDouble(double v, double min, double max) =>
    v < min ? min : (v > max ? max : v);
