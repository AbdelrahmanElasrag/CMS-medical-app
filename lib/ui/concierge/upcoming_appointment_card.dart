import 'package:flutter/material.dart';

import 'package:cms/services/api_service.dart';
import 'package:cms/theme/concierge_theme.dart';

/// The single upcoming-visit card on the editorial home.
class UpcomingAppointmentCard extends StatefulWidget {
  const UpcomingAppointmentCard({
    super.key,
    required this.signedIn,
    required this.onOpen,
  });

  final bool signedIn;
  final VoidCallback onOpen;

  @override
  State<UpcomingAppointmentCard> createState() => _UpcomingAppointmentCardState();
}

class _UpcomingAppointmentCardState extends State<UpcomingAppointmentCard> {
  bool _loading = true;
  bool _failed = false;
  _VisitPreview? _next;

  @override
  void initState() {
    super.initState();
    if (widget.signedIn) {
      _load();
    } else {
      _loading = false;
    }
  }

  @override
  void didUpdateWidget(UpcomingAppointmentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.signedIn && widget.signedIn) _load();
    if (oldWidget.signedIn && !widget.signedIn) {
      setState(() {
        _loading = false;
        _failed = false;
        _next = null;
      });
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final res = await ApiService.instance.getJson('/mobile/appointments/my-appointments');
      final data = res['data'];
      final list = data != null && data['appointments'] != null
          ? List<Map<String, dynamic>>.from(
              (data['appointments'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
            )
          : <Map<String, dynamic>>[];
      if (!mounted) return;
      setState(() {
        _next = _soonest(list);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  _VisitPreview? _soonest(List<Map<String, dynamic>> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _VisitPreview? best;
    for (final item in items) {
      final status = (item['status']?.toString() ?? '').toLowerCase();
      if (status.contains('cancel')) continue;
      final raw = item['scheduledDate']?.toString();
      final date = raw == null ? null : DateTime.tryParse(raw);
      if (date == null) continue;
      final day = DateTime(date.year, date.month, date.day);
      if (day.isBefore(today)) continue;
      final preview = _VisitPreview.fromJson(item, date);
      if (best == null || preview.date.isBefore(best.date)) best = preview;
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return AnimatedSwitcher(
      duration: reduce ? Duration.zero : const Duration(milliseconds: 380),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: KeyedSubtree(
        key: ValueKey(_loading
            ? 'loading'
            : _failed
                ? 'failed'
                : _next == null
                    ? 'empty'
                    : 'visit-${_next!.date.toIso8601String()}'),
        child: _body(),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return _EditorialVisitFrame(
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(color: EditorialPalette.portrait, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: 140,
                    decoration: BoxDecoration(
                      color: EditorialPalette.portrait,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 96,
                    decoration: BoxDecoration(
                      color: EditorialPalette.portrait,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_failed) {
      return _EditorialVisitFrame(
        child: Row(
          children: [
            Expanded(
              child: Text('Visits could not be loaded.', style: EditorialType.cardMeta()),
            ),
            TextButton(
              onPressed: _load,
              style: TextButton.styleFrom(
                foregroundColor: EditorialPalette.headline,
                minimumSize: const Size(44, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('Retry', style: EditorialType.cardTitle()),
            ),
          ],
        ),
      );
    }

    final visit = _next;
    if (visit == null) {
      return _AppointmentRow(
        title: 'No upcoming visits',
        subtitle: 'When you book, your visit will appear here.',
        meta: null,
        monogram: null,
        onTap: widget.onOpen,
      );
    }

    return _AppointmentRow(
      title: visit.title,
      subtitle: visit.subtitle,
      meta: visit.whenLabel,
      monogram: _monogram(visit.title),
      onTap: widget.onOpen,
    );
  }
}

String _monogram(String title) {
  final words = title
      .replaceAll('.', ' ')
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty && word.toLowerCase() != 'dr')
      .take(2)
      .map((word) => word[0].toUpperCase())
      .join();
  return words.isEmpty ? 'C' : words;
}

class _EditorialVisitFrame extends StatelessWidget {
  const _EditorialVisitFrame({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(26));
    return Material(
      color: EditorialPalette.card,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: EditorialPalette.cardInner,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  const _AppointmentRow({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.monogram,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String? meta;
  final String? monogram;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _EditorialVisitFrame(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: EditorialPalette.portrait,
            child: monogram == null
                ? const Icon(Icons.person_outline_rounded, size: 20, color: EditorialPalette.headline)
                : Text(monogram!, style: EditorialType.monogram()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: EditorialType.cardTitle(),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: EditorialType.cardMeta(),
                ),
                if (meta != null) ...[
                  const SizedBox(height: 2),
                  Text(meta!, style: EditorialType.cardMeta()),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 22, color: EditorialPalette.navMuted),
        ],
      ),
    );
  }
}

class _VisitPreview {
  const _VisitPreview({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.whenLabel,
  });

  final DateTime date;
  final String title;
  final String subtitle;
  final String whenLabel;

  factory _VisitPreview.fromJson(Map<String, dynamic> item, DateTime date) {
    final hospital = item['hospital'] is Map ? (item['hospital'] as Map)['name']?.toString() : null;
    final speciality = _firstNonEmpty([
      item['speciality']?.toString(),
      item['specialty']?.toString(),
    ]);
    final doctor = _doctorName(item);
    final place = (hospital == null || hospital.trim().isEmpty) ? 'Partner hospital' : hospital.trim();
    final focus = (speciality == null || speciality.trim().isEmpty) ? 'Visit' : speciality.trim();
    return _VisitPreview(
      date: date,
      title: doctor ?? place,
      subtitle: doctor == null ? focus : (focus == 'Visit' ? place : focus),
      whenLabel: _formatWhen(date),
    );
  }

  static String? _doctorName(Map<String, dynamic> item) {
    final direct = _clean(item['doctorName']?.toString());
    if (direct != null) return direct;
    final doctor = item['doctor'];
    if (doctor is Map) {
      final name = _clean(doctor['name']?.toString());
      if (name != null) return name;
    }
    final specs = item['appointmentSpecialities'];
    if (specs is List) {
      for (final spec in specs) {
        if (spec is! Map) continue;
        final nested = spec['doctor'];
        if (nested is Map) {
          final name = _clean(nested['name']?.toString());
          if (name != null) return name;
        }
        final named = _clean(spec['doctorName']?.toString());
        if (named != null) return named;
      }
    }
    return null;
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final cleaned = _clean(value);
      if (cleaned != null) return cleaned;
    }
    return null;
  }

  static String? _clean(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == '—') return null;
    return trimmed;
  }

  static String _formatWhen(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final local = date.toLocal();
    final day = '${weekdays[local.weekday - 1]}, ${months[local.month - 1]} ${local.day}';
    final hour = local.hour;
    final minute = local.minute;
    if (hour == 0 && minute == 0) return day;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    final mm = minute.toString().padLeft(2, '0');
    return '$day • $h12:$mm $suffix';
  }
}
