import 'package:flutter/material.dart';

import 'package:cms/screens/admin_bookings_screen.dart';
import 'package:cms/screens/admin_partners_screen.dart';
import 'package:cms/services/api_service.dart';
import 'package:cms/services/employee_auth_service.dart';
import 'package:cms/screens/staff_login_screen.dart';
import 'package:cms/theme/app_tokens.dart';
import 'package:cms/ui/mobadra_ui.dart';

// ── Data models ──────────────────────────────────────────────────────────────

class _DayStat {
  final String date;
  final int count;
  const _DayStat({required this.date, required this.count});

  factory _DayStat.fromJson(Map<String, dynamic> j) => _DayStat(
        date: j['date']?.toString() ?? '',
        count: (j['count'] as num?)?.toInt() ?? 0,
      );
}

class _CoordinatorInfo {
  final String id;
  final String name;
  final String phone;
  final int totalScans;
  final int todayScans;

  const _CoordinatorInfo({
    required this.id,
    required this.name,
    required this.phone,
    required this.totalScans,
    required this.todayScans,
  });

  factory _CoordinatorInfo.fromJson(Map<String, dynamic> j) {
    return _CoordinatorInfo(
      id: j['id']?.toString() ?? j['_id']?.toString() ?? '',
      name: j['name']?.toString() ??
          j['nameEnglish']?.toString() ??
          j['fullName']?.toString() ??
          'Unknown',
      phone: j['phone']?.toString() ??
          j['phoneNumber']?.toString() ??
          '',
      totalScans: (j['totalScans'] as num?)?.toInt() ??
          (j['scanCount'] as num?)?.toInt() ??
          0,
      todayScans: (j['todayScans'] as num?)?.toInt() ?? 0,
    );
  }
}

class _ScanRecord {
  final String patientName;
  final String timestamp;
  final int? pointsAwarded;

  const _ScanRecord({
    required this.patientName,
    required this.timestamp,
    this.pointsAwarded,
  });

  factory _ScanRecord.fromJson(Map<String, dynamic> j) {
    return _ScanRecord(
      patientName: j['patientName']?.toString() ??
          j['displayName']?.toString() ??
          j['name']?.toString() ??
          'Unknown patient',
      timestamp: j['timestamp']?.toString() ??
          j['createdAt']?.toString() ??
          j['scannedAt']?.toString() ??
          '',
      pointsAwarded: (j['pointsAwarded'] as num?)?.toInt() ??
          (j['points'] as num?)?.toInt(),
    );
  }
}

// ── Admin Dashboard ──────────────────────────────────────────────────────────

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<_CoordinatorInfo> _coordinators = [];
  List<_DayStat> _overview = [];
  int _todayTotal = 0;
  bool _loading = true;
  String? _error;
  String? _token;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _token = await EmployeeAuthService.instance.getToken();
    await Future.wait([_fetchCoordinators(), _fetchOverview()]);
  }

  Future<void> _fetchOverview() async {
    if (_token == null) return;
    try {
      final res = await ApiService.instance
          .getJsonWithBearer('/employee/scan-overview', _token!);
      final data = res['data'] as Map<String, dynamic>?;
      if (data == null) return;
      final raw = data['last7Days'];
      final List<dynamic> list = raw is List ? raw : [];
      if (mounted) {
        setState(() {
          _overview = list
              .whereType<Map<String, dynamic>>()
              .map(_DayStat.fromJson)
              .toList();
          _todayTotal = (data['todayTotal'] as num?)?.toInt() ?? 0;
        });
      }
    } catch (_) {
      // Overview is non-critical; ignore errors silently.
    }
  }

  Future<void> _fetchCoordinators() async {
    if (_token == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.instance
          .getJsonWithBearer('/employee/role/coordinator', _token!);
      final raw = res['data'];
      final List<dynamic> list = raw is List ? raw : [];
      setState(() {
        _coordinators = list
            .whereType<Map<String, dynamic>>()
            .map(_CoordinatorInfo.fromJson)
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

  Future<void> _refresh() async {
    await Future.wait([_fetchCoordinators(), _fetchOverview()]);
  }

  Future<void> _deleteCoordinator(_CoordinatorInfo c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove coordinator'),
        content: Text(
            'Remove ${c.name} from coordinators? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ApiService.instance
          .deleteJsonWithBearer('/employee/${c.id}', _token!);
      setState(() => _coordinators.removeWhere((x) => x.id == c.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${c.name} removed')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    }
  }

  Future<void> _showAddCoordinatorDialog() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool submitting = false;
    String? dialogError;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Add coordinator'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  if (dialogError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      dialogError!,
                      style: TextStyle(
                          color: Theme.of(ctx).colorScheme.error,
                          fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: submitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setLocal(() {
                        submitting = true;
                        dialogError = null;
                      });
                      try {
                        await ApiService.instance.postJsonWithBearer(
                          '/employee',
                          {
                            'employee': {
                              'name': nameCtrl.text.trim(),
                              'phone': phoneCtrl.text.trim(),
                              'password': passCtrl.text,
                            },
                            'roles': ['coordinator'],
                          },
                          _token!,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        await _fetchCoordinators();
                      } on ApiException catch (e) {
                        setLocal(() {
                          dialogError = e.message;
                          submitting = false;
                        });
                      } catch (e) {
                        setLocal(() {
                          dialogError = e.toString();
                          submitting = false;
                        });
                      }
                    },
              child: submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add'),
            ),
          ],
        ),
      ),
    );

    nameCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
  }

  Future<void> _showHistory(_CoordinatorInfo c) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _CoordinatorHistoryScreen(
          coordinator: c,
          token: _token!,
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MobadraAppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_rounded, size: 22),
            SizedBox(width: 8),
            Text('Admin Dashboard'),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCoordinatorDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add coordinator',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(error: _error!, onRetry: _refresh)
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    children: [
                      if (_overview.isNotEmpty) ...[
                        _ScanOverviewCard(
                          todayTotal: _todayTotal,
                          days: _overview,
                        ),
                        const SizedBox(height: 12),
                      ],
                      _NavCard(
                        icon: Icons.calendar_month_rounded,
                        title: 'Bookings',
                        subtitle: 'View mobile bookings and set confirmed schedules',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AdminBookingsScreen()),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _NavCard(
                        icon: Icons.handshake_outlined,
                        title: 'Partners & Offers',
                        subtitle: 'Manage hospitals, clinics and their offers',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AdminPartnersScreen()),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _SectionHeader(
                          label: 'Coordinators (${_coordinators.length})'),
                      const SizedBox(height: 10),
                      if (_coordinators.isEmpty)
                        _EmptyView(onAdd: _showAddCoordinatorDialog)
                      else
                        ..._coordinators.map(
                          (c) => _CoordinatorCard(
                            coordinator: c,
                            onDelete: () => _deleteCoordinator(c),
                            onHistory: () => _showHistory(c),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}

// ── Coordinator history screen ───────────────────────────────────────────────

class _CoordinatorHistoryScreen extends StatefulWidget {
  final _CoordinatorInfo coordinator;
  final String token;

  const _CoordinatorHistoryScreen({
    required this.coordinator,
    required this.token,
  });

  @override
  State<_CoordinatorHistoryScreen> createState() =>
      _CoordinatorHistoryScreenState();
}

class _CoordinatorHistoryScreenState
    extends State<_CoordinatorHistoryScreen> {
  List<_ScanRecord> _scans = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.instance.getJsonWithBearer(
        '/employee/${widget.coordinator.id}/scan-history',
        widget.token,
      );
      // Response: { success, data: { scans: [...], total, todayCount } }
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

  String _formatTimestamp(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.coordinator;
    return Scaffold(
      appBar: MobadraAppBar(
        title: Text('${c.name} — scans'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(error: _error!, onRetry: _fetch)
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: _scans.isEmpty
                      ? const Center(
                          child: Text('No scans recorded yet.',
                              style: TextStyle(color: Colors.grey)),
                        )
                      : Column(
                          children: [
                            _StatsBanner(
                              totalScans: c.totalScans,
                              todayScans: c.todayScans,
                            ),
                            Expanded(
                              child: ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: _scans.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (_, i) {
                                  final s = _scans[i];
                                  return ShadCard(
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppColors.primaryContainer,
                                        child: Icon(Icons.qr_code_scanner,
                                            color: AppColors.primary, size: 20),
                                      ),
                                      title: Text(s.patientName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700)),
                                      subtitle: Text(
                                          _formatTimestamp(s.timestamp),
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12)),
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
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: AppColors.primary.withValues(alpha: 0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.primary.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanOverviewCard extends StatelessWidget {
  final int todayTotal;
  final List<_DayStat> days;

  const _ScanOverviewCard({required this.todayTotal, required this.days});

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
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month]} ${dt.day}';
    } catch (_) {
      return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxCount = days.map((d) => d.count).fold(0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
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
                child: Icon(Icons.bar_chart_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan Overview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                  ),
                  Text(
                    'Today: $todayTotal scans across all coordinators',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),
          for (int i = 0; i < days.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 72,
                  child: Text(
                    _formatDate(days[i].date),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          i == 0 ? FontWeight.w800 : FontWeight.w500,
                      color: i == 0 ? AppColors.primary : Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: maxCount > 0
                          ? (days[i].count / maxCount).clamp(0.0, 1.0)
                          : 0.0,
                      minHeight: 7,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        i == 0
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 24,
                  child: Text(
                    '${days[i].count}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: i == 0 ? AppColors.primary : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary),
    );
  }
}

class _CoordinatorCard extends StatelessWidget {
  final _CoordinatorInfo coordinator;
  final VoidCallback onDelete;
  final VoidCallback onHistory;

  const _CoordinatorCard({
    required this.coordinator,
    required this.onDelete,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    final c = coordinator;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ShadCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      c.phone,
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _StatPill(
                            icon: Icons.qr_code_scanner,
                            label: '${c.totalScans} total'),
                        const SizedBox(width: 6),
                        if (c.todayScans > 0)
                          _StatPill(
                              icon: Icons.today_rounded,
                              label: '${c.todayScans} today'),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Scan history',
                    icon: const Icon(Icons.history_rounded),
                    color: AppColors.primary,
                    onPressed: onHistory,
                  ),
                  IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: Colors.red.shade400,
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _StatsBanner extends StatelessWidget {
  final int totalScans;
  final int todayScans;
  const _StatsBanner({required this.totalScans, required this.todayScans});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _BannerStat(value: '$totalScans', label: 'Total scans'),
          Container(width: 1, height: 32, color: AppColors.primary.withValues(alpha: 0.2)),
          _BannerStat(value: '$todayScans', label: 'Today'),
        ],
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  final String value;
  final String label;
  const _BannerStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.primary)),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No coordinators yet',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Tap the button below to add your first coordinator.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.person_add_rounded),
            label: const Text('Add coordinator'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

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
