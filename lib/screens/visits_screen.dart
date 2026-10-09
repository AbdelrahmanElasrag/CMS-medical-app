import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:cms/services/api_service.dart';
import 'package:cms/services/auth_service.dart';
import 'package:cms/theme/app_tokens.dart';
import 'package:cms/theme/concierge_theme.dart';
import 'package:cms/ui/booking_auth_prompt.dart';
import 'package:cms/ui/mobadra_ui.dart';

class VisitsScreen extends StatefulWidget {
  const VisitsScreen({super.key});

  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  bool _loading = true;
  String? _error;
  bool _signedIn = false;
  bool _authKnown = false;
  List<Map<String, dynamic>> _appointments = [];
  DateTime _focused = DateTime.now();
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    _selected = DateTime(_focused.year, _focused.month, _focused.day);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final signedIn = Provider.of<AuthService>(context).isLoggedIn;
    if (_authKnown && signedIn == _signedIn) return;
    _authKnown = true;
    _signedIn = signedIn;
    _load();
  }

  Future<void> _load() async {
    if (!_signedIn) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = null;
        _appointments = [];
      });
      return;
    }
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
          _error = _visitLoadMessage(e);
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
    return EditorialPalette.ivory;
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
      backgroundColor: Colors.transparent,
      appBar: MobadraAppBar(
        title: const Row(
          children: [
            Icon(Icons.calendar_month_rounded, size: 26),
            SizedBox(width: 10),
            Text('Appointments'),
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
      body: _loading && _signedIn
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(strokeWidth: 3, color: EditorialPalette.ivory),
                  ),
                  const SizedBox(height: 16),
                  const Text('Loading your visits…', style: TextStyle(color: EditorialPalette.muted, fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : RefreshIndicator(
                  color: EditorialPalette.ivory,
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 16, AppSpacing.md, 32),
                    children: [
                      if (!_signedIn)
                        _VisitNotice(
                          icon: Icons.lock_outline_rounded,
                          title: 'Sign in to see your appointments',
                          message: 'Your upcoming visits appear here after you sign in.',
                          actionLabel: 'Sign in',
                          onAction: () => showBookingAuthPrompt(context),
                        ),
                      if (_signedIn && _error != null)
                        _VisitNotice(
                          icon: Icons.cloud_off_rounded,
                          title: 'Visits are unavailable',
                          message: _error!,
                          actionLabel: 'Try again',
                          onAction: _load,
                        ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: EditorialPalette.card,
                          border: Border.all(color: const Color(0xFF2E2E30)),
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
                          calendarStyle: const CalendarStyle(
                            outsideDaysVisible: false,
                            defaultTextStyle: TextStyle(color: EditorialPalette.headline),
                            weekendTextStyle: TextStyle(color: EditorialPalette.muted),
                            todayDecoration: BoxDecoration(
                              color: EditorialPalette.cardInner,
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: TextStyle(fontWeight: FontWeight.w700, color: EditorialPalette.headline),
                            selectedDecoration: BoxDecoration(
                              color: EditorialPalette.ivory,
                              shape: BoxShape.circle,
                            ),
                            selectedTextStyle: TextStyle(color: EditorialPalette.ivoryInk, fontWeight: FontWeight.w700),
                            markerDecoration: BoxDecoration(
                              color: EditorialPalette.ivory,
                              shape: BoxShape.circle,
                            ),
                            defaultDecoration: BoxDecoration(shape: BoxShape.circle),
                          ),
                          daysOfWeekStyle: const DaysOfWeekStyle(
                            weekdayStyle: TextStyle(color: EditorialPalette.muted, fontWeight: FontWeight.w600, fontSize: 12),
                            weekendStyle: TextStyle(color: EditorialPalette.navMuted, fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: EditorialPalette.headline, size: 28),
                            rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: EditorialPalette.headline, size: 28),
                            titleTextStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: EditorialPalette.headline,
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
                              color: EditorialPalette.cardInner,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.today_rounded, color: EditorialPalette.headline, size: 22),
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
                                        color: EditorialPalette.ivory,
                                      ),
                                ),
                                const Text(
                                  'Visits scheduled for this day',
                                  style: TextStyle(fontSize: 12.5, color: EditorialPalette.muted, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).mobadraFadeSlide(delayMs: 70),
                      const SizedBox(height: 14),
                      ...(() {
                        final list = _forDay(selectedDay);
                        if (list.isEmpty) {
                          return [
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                              decoration: BoxDecoration(
                                color: EditorialPalette.card,
                                borderRadius: BorderRadius.circular(AppRadii.lg),
                                border: Border.all(color: const Color(0xFF2E2E30)),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.event_available_rounded, size: 44, color: EditorialPalette.navMuted),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No visits on this day',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: EditorialPalette.muted,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Pick another date or pull to refresh',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: EditorialPalette.navMuted, fontSize: 13),
                                  ),
                                ],
                              ),
                            ).mobadraFadeSlide(delayMs: 90),
                          ];
                        }
                        return [
                          for (var i = 0; i < list.length; i++)
                            _VisitTileCard(
                              appointment: list[i],
                              onTap: () => _showDetails(context, list[i]),
                              statusColor: _statusColor,
                              statusIcon: _statusIcon,
                            ).mobadraFadeSlide(delayMs: 50 * i),
                        ];
                      })(),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          const Icon(Icons.list_alt_rounded, color: EditorialPalette.headline, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'All appointments',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: EditorialPalette.ivory,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_signedIn && _error == null && _appointments.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                EditorialPalette.card,
                                EditorialPalette.cardInner,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 40, color: EditorialPalette.ivory.withValues(alpha: 0.65)),
                              const SizedBox(height: 12),
                              const Text(
                                'No appointments yet',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: EditorialPalette.headline),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'When you book through Mobadra, they\'ll show up here.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: EditorialPalette.muted, height: 1.35),
                              ),
                            ],
                          ),
                        )
                      else
                        ...[
                          for (var i = 0; i < _appointments.length; i++)
                            _VisitTileCard(
                              appointment: _appointments[i],
                              onTap: () => _showDetails(context, _appointments[i]),
                              statusColor: _statusColor,
                              statusIcon: _statusIcon,
                              showDateInSubtitle: true,
                            ).mobadraFadeSlide(delayMs: 40 * i),
                        ],
                    ],
                  ),
                ),
    );
  }
}

String _visitLoadMessage(Object error) {
  if (error is ApiException && error.statusCode == 401) {
    return 'Sign in again to see your appointments.';
  }
  final raw = error.toString();
  if (raw.contains('Failed to fetch') || raw.contains('Network error') || raw.contains('ClientException')) {
    return 'The care service isn’t reachable right now. You can still browse the calendar, then try again.';
  }
  return 'Visits could not be loaded. Try again in a moment.';
}

class _VisitNotice extends StatelessWidget {
  const _VisitNotice({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        decoration: BoxDecoration(
          color: EditorialPalette.card,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: const Color(0xFF2E2E30)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: EditorialPalette.headline),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: EditorialPalette.headline),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: EditorialPalette.muted, height: 1.35),
            ),
            const SizedBox(height: 12),
            ShadButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    ).mobadraFadeSlide();
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
          Icon(icon, size: 20, color: EditorialPalette.ivory.withValues(alpha: 0.85)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: EditorialPalette.muted, letterSpacing: 0.3)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: valueColor ?? EditorialPalette.headline, height: 1.25)),
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
              color: EditorialPalette.card,
              border: Border.all(color: EditorialPalette.ivory.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: EditorialPalette.ivory.withValues(alpha: 0.06),
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
                      colors: [EditorialPalette.ivory, EditorialPalette.portrait],
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
                                color: EditorialPalette.cardInner,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.local_hospital_rounded, color: EditorialPalette.ivory, size: 22),
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
                                      const Icon(Icons.medical_information_outlined, size: 14, color: EditorialPalette.muted),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          showDateInSubtitle && scheduledDate != null
                                              ? '${DateFormat.yMMMd().format(scheduledDate)} · $speciality'
                                              : speciality,
                                          style: TextStyle(color: EditorialPalette.muted, fontSize: 13),
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
                                        color: EditorialPalette.ivory,
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
                  child: const Icon(Icons.chevron_right_rounded, color: EditorialPalette.navMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
