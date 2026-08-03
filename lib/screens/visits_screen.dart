import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:cms/services/api_service.dart';
import 'package:cms/theme/app_tokens.dart';
import 'package:cms/ui/mobadra_ui.dart';

class VisitsScreen extends StatefulWidget {
  const VisitsScreen({super.key});

  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _appointments = [];
  DateTime _focused = DateTime.now();
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    _selected = DateTime(_focused.year, _focused.month, _focused.day);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.instance.getJson('/mobile/appointments/my-appointments');
      final data = res['data'];
      final list = data != null && data['appointments'] != null
          ? List<Map<String, dynamic>>.from(
              (data['appointments'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
            )
          : <Map<String, dynamic>>[];
      if (mounted) {
        setState(() {
          _appointments = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _appointments = [];
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Set<DateTime> get _daysWithVisits {
    final set = <DateTime>{};
    for (final a in _appointments) {
      final d = a['scheduledDate'] != null ? DateTime.tryParse(a['scheduledDate'].toString()) : null;
      if (d != null) {
        set.add(DateTime(d.year, d.month, d.day));
      }
      final specs = a['appointmentSpecialities'];
      if (specs is List) {
        for (final s in specs) {
          if (s is Map && s['scheduledTime'] != null) {
            final t = DateTime.tryParse(s['scheduledTime'].toString());
            if (t != null) set.add(DateTime(t.year, t.month, t.day));
          }
        }
      }
    }
    return set;
  }

  List<Map<String, dynamic>> _forDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _appointments.where((a) {
      final d = a['scheduledDate'] != null ? DateTime.tryParse(a['scheduledDate'].toString()) : null;
      if (d != null && DateTime(d.year, d.month, d.day) == key) return true;
      final specs = a['appointmentSpecialities'];
      if (specs is List) {
        for (final s in specs) {
          if (s is Map && s['scheduledTime'] != null) {
            final t = DateTime.tryParse(s['scheduledTime'].toString());
            if (t != null && DateTime(t.year, t.month, t.day) == key) return true;
          }
        }
      }
      return false;
    }).toList();
  }

  static Color _statusColor(String? status) {
    final s = (status ?? '').toLowerCase();
    if (s.contains('confirm') || s.contains('complete') || s.contains('done')) {
      return const Color(0xFF0D9488);
    }
    if (s.contains('pend') || s.contains('wait')) return const Color(0xFFD97706);
    if (s.contains('cancel')) return const Color(0xFFDC2626);
    return AppColors.primary;
  }

  static IconData _statusIcon(String? status) {
    final s = (status ?? '').toLowerCase();
    if (s.contains('cancel')) return Icons.event_busy_rounded;
    if (s.contains('pend')) return Icons.schedule_rounded;
    return Icons.check_circle_outline_rounded;
  }

  void _showDetails(BuildContext context, Map<String, dynamic> a) {
    final scheduledDate = a['scheduledDate'] != null
        ? DateTime.tryParse(a['scheduledDate'].toString())
        : null;
    final hospital =
        a['hospital'] is Map ? (a['hospital'] as Map)['name']?.toString() ?? '—' : '—';
    final cs = Theme.of(context).colorScheme;
    final status = a['status']?.toString() ?? '—';
    showDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: Row(
          children: [
            Icon(Icons.event_note_rounded, color: cs.primary, size: 26),
            const SizedBox(width: 10),
            const Expanded(child: Text('Appointment')),
          ],
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(icon: Icons.local_hospital_rounded, label: 'Hospital', value: hospital),
              if (scheduledDate != null)
                _DetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: DateFormat.yMMMd().format(scheduledDate),
                ),
              _DetailRow(icon: Icons.medical_services_outlined, label: 'Speciality', value: '${a['speciality'] ?? '—'}'),
              _DetailRow(
                icon: _statusIcon(status),
                label: 'Status',
                value: status,
                valueColor: _statusColor(status),
              ),
              if (a['notes'] != null && a['notes'].toString().trim().isNotEmpty)
                _DetailRow(icon: Icons.notes_rounded, label: 'Notes', value: '${a['notes']}'),
              if (a['isMobileBooking'] == true)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.phone_android_rounded, size: 18, color: cs.primary),
                      const SizedBox(width: 8),
                      Text('Booked via app', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedDay = _selected ?? _focused;
    final dateLabel = DateFormat('EEEE, MMM d').format(selectedDay);

    return Scaffold(
      backgroundColor: AppColors.neutralSurface,
      appBar: MobadraAppBar(
        title: const Row(
          children: [
            Icon(Icons.calendar_month_rounded, size: 26),
            SizedBox(width: 10),
            Text('My visits'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text('Loading your visits…', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.red.withValues(alpha: 0.15), blurRadius: 16),
                            ],
                          ),
                          child: const Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFFDC2626)),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Couldn\'t load visits',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700, height: 1.35)),
                        const SizedBox(height: 24),
                        ShadButton(
                          onPressed: _load,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh_rounded, size: 20, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Try again'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 16, AppSpacing.md, 32),
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              AppColors.primaryContainer.withValues(alpha: 0.65),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
                        ),
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                        child: TableCalendar<void>(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2035, 12, 31),
                          focusedDay: _focused,
                          selectedDayPredicate: (d) => isSameDay(_selected, d),
                          eventLoader: (d) {
                            final k = DateTime(d.year, d.month, d.day);
                            return _daysWithVisits.contains(k) ? [null] : [];
                          },
                          calendarStyle: CalendarStyle(
                            outsideDaysVisible: false,
                            weekendTextStyle: TextStyle(color: Colors.grey.shade700),
                            todayDecoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.35),
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                            selectedDecoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, Color(0xFF0078D4)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                            markerDecoration: const BoxDecoration(
                              color: AppColors.tertiary,
                              shape: BoxShape.circle,
                            ),
                            defaultDecoration: const BoxDecoration(shape: BoxShape.circle),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12),
                            weekendStyle: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            leftChevronIcon: Icon(Icons.chevron_left_rounded, color: AppColors.primary, size: 28),
                            rightChevronIcon: Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 28),
                            titleTextStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                          ),
                          onDaySelected: (selected, focused) {
                            setState(() {
                              _selected = selected;
                              _focused = focused;
                            });
                          },
                          onPageChanged: (focused) => setState(() => _focused = focused),
                        ),
                      ).mobadraFadeSlide(),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.secondary.withValues(alpha: 0.35), AppColors.primary.withValues(alpha: 0.2)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.today_rounded, color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dateLabel,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                ),
                                Text(
                                  'Visits scheduled for this day',
                                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...(() {
                        final list = _forDay(selectedDay);
                        if (list.isEmpty) {
                          return [
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(AppRadii.lg),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.event_available_rounded, size: 44, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No visits on this day',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Pick another date or pull to refresh',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ];
                        }
                        return list
                            .map((a) => _VisitTileCard(
                                  appointment: a,
                                  onTap: () => _showDetails(context, a),
                                  statusColor: _statusColor,
                                  statusIcon: _statusIcon,
                                ))
                            .toList();
                      })(),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Icon(Icons.list_alt_rounded, color: AppColors.tertiary, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'All appointments',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_appointments.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryContainer.withValues(alpha: 0.5),
                                AppColors.secondaryContainer.withValues(alpha: 0.4),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 40, color: AppColors.primary.withValues(alpha: 0.65)),
                              const SizedBox(height: 12),
                              Text(
                                'No appointments yet',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.grey.shade800),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'When you book through Mobadra, they\'ll show up here.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade600, height: 1.35),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._appointments.map((a) => _VisitTileCard(
                              appointment: a,
                              onTap: () => _showDetails(context, a),
                              statusColor: _statusColor,
                              statusIcon: _statusIcon,
                              showDateInSubtitle: true,
                            )),
                    ],
                  ),
                ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary.withValues(alpha: 0.85)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey.shade600, letterSpacing: 0.3)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: valueColor ?? Colors.grey.shade900, height: 1.25)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitTileCard extends StatelessWidget {
  const _VisitTileCard({
    required this.appointment,
    required this.onTap,
    required this.statusColor,
    required this.statusIcon,
    this.showDateInSubtitle = false,
  });

  final Map<String, dynamic> appointment;
  final VoidCallback onTap;
  final Color Function(String?) statusColor;
  final IconData Function(String?) statusIcon;
  final bool showDateInSubtitle;

  @override
  Widget build(BuildContext context) {
    final hospital = appointment['hospital'] is Map
        ? (appointment['hospital'] as Map)['name']?.toString() ?? '—'
        : '—';
    final status = appointment['status']?.toString() ?? '—';
    final speciality = appointment['speciality']?.toString() ?? '—';
    final scheduledDate = appointment['scheduledDate'] != null
        ? DateTime.tryParse(appointment['scheduledDate'].toString())
        : null;
    final sc = statusColor(status);
    final mobile = appointment['isMobileBooking'] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              color: Colors.white,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 5,
                  constraints: const BoxConstraints(minHeight: 88),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppRadii.lg)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.local_hospital_rounded, color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hospital,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, height: 1.2),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.medical_information_outlined, size: 14, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          showDateInSubtitle && scheduledDate != null
                                              ? '${DateFormat.yMMMd().format(scheduledDate)} · $speciality'
                                              : speciality,
                                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: sc.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statusIcon(status), size: 14, color: sc),
                                  const SizedBox(width: 4),
                                  Text(
                                    status,
                                    style: TextStyle(color: sc, fontWeight: FontWeight.w700, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            if (mobile)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.phone_android_rounded, size: 14, color: AppColors.secondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'App booking',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
