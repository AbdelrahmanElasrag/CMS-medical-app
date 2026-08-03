import 'package:flutter/material.dart';

import 'package:cms/screens/coordinator_scan_screen.dart';
import 'package:cms/screens/staff_login_screen.dart';
import 'package:cms/services/api_service.dart';
import 'package:cms/services/employee_auth_service.dart';
import 'package:cms/theme/app_tokens.dart';
import 'package:cms/ui/mobadra_ui.dart';

// ── Data model ───────────────────────────────────────────────────────────────

class _ScanRecord {
  final String patientName;
  final DateTime timestamp;
  final int? pointsAwarded;

  const _ScanRecord({
    required this.patientName,
    required this.timestamp,
    this.pointsAwarded,
  });

  factory _ScanRecord.fromJson(Map<String, dynamic> j) {
    final rawTs = j['timestamp']?.toString() ??
        j['createdAt']?.toString() ??
        j['scannedAt']?.toString() ??
        '';
    DateTime ts;
    try {
      ts = DateTime.parse(rawTs).toLocal();
    } catch (_) {
      ts = DateTime.now();
    }
    return _ScanRecord(
      patientName: j['patientName']?.toString() ??
          j['displayName']?.toString() ??
          j['name']?.toString() ??
          'Unknown patient',
      timestamp: ts,
      pointsAwarded: (j['pointsAwarded'] as num?)?.toInt() ??
          (j['points'] as num?)?.toInt(),
    );
  }

  String get dateKey =>
      '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
}

// ── Dashboard ─────────────────────────────────────────────────────────────────

class CoordinatorDashboardScreen extends StatefulWidget {
  const CoordinatorDashboardScreen({super.key});

  @override
  State<CoordinatorDashboardScreen> createState() =>
      _CoordinatorDashboardScreenState();
}

class _CoordinatorDashboardScreenState
    extends State<CoordinatorDashboardScreen> {
  String? _token;
  String? _userId;
  String _name = '';

  List<_ScanRecord> _scans = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _token = await EmployeeAuthService.instance.getToken();
    _userId = await EmployeeAuthService.instance.getUserId();
    _name = await EmployeeAuthService.instance.getName() ?? '';
    await _fetchScans();
  }

  Future<void> _fetchScans() async {
    if (_token == null || _userId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.instance.getJsonWithBearer(
        '/employee/$_userId/scan-history?limit=200',
        _token!,
      );
      final raw = res['data'];
      List<dynamic> list;
      if (raw is Map) {
        list = (raw['scans'] ?? []) as List;
      } else if (raw is List) {
        list = raw;
      } else {
        list = [];
      }
      setState(() {
        _scans = list
            .whereType<Map<String, dynamic>>()
            .map(_ScanRecord.fromJson)
            .toList();
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // Group scans by calendar date; returns entries sorted newest-first.
  List<MapEntry<String, int>> _dailyCounts() {
    final map = <String, int>{};
    for (final s in _scans) {
      map[s.dateKey] = (map[s.dateKey] ?? 0) + 1;
    }
    final entries = map.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return entries.take(7).toList();
  }

  int get _todayCount {
    final today =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
    return _scans.where((s) => s.dateKey == today).length;
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatDate(String key) {
    try {
      final parts = key.split('-');
      final dt = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      if (dt == today) return 'Today';
      if (dt == yesterday) return 'Yesterday';
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[dt.month]} ${dt.day}';
    } catch (_) {
      return key;
    }
  }

  Future<void> _logout() async {
    await EmployeeAuthService.instance.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const StaffLoginScreen()),
      (_) => false,
    );
  }

  void _goScan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CoordinatorScanScreen()),
    );
  }

  void _goHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _CoordinatorOwnHistoryScreen(
          scans: _scans,
          name: _name,
          onRefresh: _fetchScans,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: MobadraAppBar(
        title: const Row(
          children: [
            Icon(Icons.dashboard_rounded, size: 20),
            SizedBox(width: 8),
            Text('My Dashboard'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _logout,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Sign out',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorRetry(error: _error!, onRetry: _fetchScans)
              : RefreshIndicator(
                  onRefresh: _fetchScans,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                    children: [
                      _GreetingCard(
                        greeting: _greeting(),
                        name: _name,
                        todayCount: _todayCount,
                        totalCount: _scans.length,
                      ),
                      const SizedBox(height: 20),
                      _QuickActions(onScan: _goScan, onHistory: _goHistory),
                      const SizedBox(height: 20),
                      _DailyBreakdown(
                        dailyCounts: _dailyCounts(),
                        formatDate: _formatDate,
                      ),
                    ],
                  ),
                ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _GreetingCard extends StatelessWidget {
  final String greeting;
  final String name;
  final int todayCount;
  final int totalCount;

  const _GreetingCard({
    required this.greeting,
    required this.name,
    required this.todayCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting${name.isNotEmpty ? ', ${name.split(' ').first}' : ''}!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Here's your scan activity.",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatBox(
                label: "Today's scans",
                value: '$todayCount',
                icon: Icons.today_rounded,
              ),
              const SizedBox(width: 12),
              _StatBox(
                label: 'Total scans',
                value: '$totalCount',
                icon: Icons.qr_code_scanner_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onScan;
  final VoidCallback onHistory;

  const _QuickActions({required this.onScan, required this.onHistory});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.qr_code_scanner_rounded,
                label: 'Scan QR Code',
                subtitle: 'Check in a patient',
                color: AppColors.primary,
                onTap: onScan,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.history_rounded,
                label: 'View History',
                subtitle: 'All scan records',
                color: const Color(0xFF2E7D32),
                onTap: onHistory,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: color.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyBreakdown extends StatelessWidget {
  final List<MapEntry<String, int>> dailyCounts;
  final String Function(String) formatDate;

  const _DailyBreakdown({
    required this.dailyCounts,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxCount = dailyCounts.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < dailyCounts.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Colors.grey.shade100,
                  ),
                _DayRow(
                  label: formatDate(dailyCounts[i].key),
                  count: dailyCounts[i].value,
                  maxCount: maxCount,
                  isToday: i == 0,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  final String label;
  final int count;
  final int maxCount;
  final bool isToday;

  const _DayRow({
    required this.label,
    required this.count,
    required this.maxCount,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final frac = maxCount > 0 ? count / maxCount : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                fontSize: 13,
                color: isToday ? AppColors.primary : Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: frac.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isToday
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 28,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isToday ? AppColors.primary : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorRetry({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(error,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Own history screen ────────────────────────────────────────────────────────

class _CoordinatorOwnHistoryScreen extends StatefulWidget {
  final List<_ScanRecord> scans;
  final String name;
  final Future<void> Function() onRefresh;

  const _CoordinatorOwnHistoryScreen({
    required this.scans,
    required this.name,
    required this.onRefresh,
  });

  @override
  State<_CoordinatorOwnHistoryScreen> createState() =>
      _CoordinatorOwnHistoryScreenState();
}

class _CoordinatorOwnHistoryScreenState
    extends State<_CoordinatorOwnHistoryScreen> {
  late List<_ScanRecord> _scans;

  @override
  void initState() {
    super.initState();
    _scans = widget.scans;
  }

  // Group scans by date, newest first.
  Map<String, List<_ScanRecord>> _grouped() {
    final map = <String, List<_ScanRecord>>{};
    for (final s in _scans) {
      (map[s.dateKey] ??= []).add(s);
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
  }

  String _formatDateHeader(String key) {
    try {
      final parts = key.split('-');
      final dt = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      if (dt == today) return 'Today';
      if (dt == yesterday) return 'Yesterday';
      const months = [
        '',
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      return '${months[dt.month]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return key;
    }
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _refresh() async {
    await widget.onRefresh();
    if (mounted) {
      setState(() {
        _scans = widget.scans;
      });
    }
  }

  int get _todayCount {
    final today =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
    return _scans.where((s) => s.dateKey == today).length;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped();

    return Scaffold(
      appBar: MobadraAppBar(
        title: Text('${widget.name.isNotEmpty ? widget.name.split(' ').first : 'My'} — Scan History'),
      ),
      body: _scans.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner_rounded,
                      size: 64, color: Color(0xFFCCCCCC)),
                  SizedBox(height: 16),
                  Text('No scans yet',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF999999))),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _HistoryStat(
                              value: '${_scans.length}', label: 'Total scans'),
                          Container(
                              width: 1,
                              height: 32,
                              color: AppColors.primary
                                  .withValues(alpha: 0.2)),
                          _HistoryStat(
                              value: '$_todayCount', label: 'Today'),
                          Container(
                              width: 1,
                              height: 32,
                              color: AppColors.primary
                                  .withValues(alpha: 0.2)),
                          _HistoryStat(
                              value: '${grouped.length}', label: 'Active days'),
                        ],
                      ),
                    ),
                  ),
                  for (final entry in grouped.entries) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                        child: Row(
                          children: [
                            Text(
                              _formatDateHeader(entry.key),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${entry.value.length} scans',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) {
                          final s = entry.value[i];
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: ShadCard(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primaryContainer,
                                  child: Icon(
                                    Icons.qr_code_scanner_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  s.patientName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                                subtitle: Text(
                                  _formatTime(s.timestamp),
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 12),
                                ),
                                trailing: s.pointsAwarded != null
                                    ? Chip(
                                        label: Text(
                                          '+${s.pointsAwarded} pts',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        backgroundColor:
                                            AppColors.primaryContainer,
                                        side: BorderSide.none,
                                        padding: EdgeInsets.zero,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        },
                        childCount: entry.value.length,
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _HistoryStat extends StatelessWidget {
  final String value;
  final String label;

  const _HistoryStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
