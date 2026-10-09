import 'package:flutter/material.dart';

import 'package:cms/services/api_service.dart';
import 'package:cms/theme/app_tokens.dart';
import 'package:cms/theme/concierge_theme.dart';
import 'package:cms/ui/concierge/skeleton_box.dart';

/// Signed-in visit state: loading, none upcoming, or the next appointment.
class NextVisitStrip extends StatefulWidget {
  const NextVisitStrip({
    super.key,
    required this.onOpenVisits,
  });

  final VoidCallback onOpenVisits;

  @override
  State<NextVisitStrip> createState() => _NextVisitStripState();
}

class _NextVisitStripState extends State<NextVisitStrip> {
  bool _loading = true;
  bool _failed = false;
  _VisitPreview? _next;

  @override
  void initState() {
    super.initState();
    _load();
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
      final hospital = item['hospital'] is Map ? (item['hospital'] as Map)['name']?.toString() : null;
      final preview = _VisitPreview(date: date, hospital: hospital);
      if (best == null || preview.date.isBefore(best.date)) best = preview;
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final muted = ConciergePalette.muted(context);
    final ink = ConciergePalette.ink(context);
    if (_loading) {
      return const SkeletonBox(height: 18, radius: 6);
    }
    if (_failed) {
      return Row(
        children: [
          Expanded(
            child: Text('Visits could not be loaded.', style: ConciergeType.caption(muted)),
          ),
          TextButton(
            onPressed: _load,
            style: TextButton.styleFrom(
              foregroundColor: ConciergePalette.emerald(context),
              minimumSize: const Size(44, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Retry'),
          ),
        ],
      );
    }
    if (_next == null) {
      return Row(
        children: [
          Icon(Icons.event_available_outlined, size: 16, color: muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text('No upcoming visits', style: ConciergeType.caption(muted)),
          ),
        ],
      );
    }

    final visit = _next!;
    final place = (visit.hospital == null || visit.hospital!.trim().isEmpty) ? 'Partner hospital' : visit.hospital!;
    return InkWell(
      onTap: widget.onOpenVisits,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Icon(Icons.event_available_outlined, size: 16, color: ConciergePalette.emerald(context)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$place  ·  ${_formatDate(visit.date)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ConciergeType.caption(ink).copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: muted),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }
}

class _VisitPreview {
  const _VisitPreview({required this.date, this.hospital});

  final DateTime date;
  final String? hospital;
}
