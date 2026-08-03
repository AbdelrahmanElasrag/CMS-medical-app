import 'package:flutter/material.dart';
import 'package:cms/services/api_service.dart';
import 'package:cms/theme/app_tokens.dart';
import 'package:cms/ui/mobadra_ui.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  String _searchQuery = '';
  bool _loading = true;
  List<Map<String, dynamic>> _appointments = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.instance.getJson('/mobile/appointments/my-appointments');
      final data = res['data'];
      final list = data != null && data['appointments'] != null
          ? List<Map<String, dynamic>>.from(
              (data['appointments'] as List).map((e) => Map<String, dynamic>.from(e as Map)))
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

  List<Map<String, dynamic>> get _filtered {
    if (_searchQuery.isEmpty) return _appointments;
    final q = _searchQuery.toLowerCase();
    return _appointments.where((a) {
      final hospital = (a['hospital'] is Map ? (a['hospital'] as Map)['name'] : null)?.toString() ?? '';
      final speciality = a['speciality']?.toString() ?? '';
      return hospital.toLowerCase().contains(q) || speciality.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MobadraAppBar(
        title: const Text('Booking History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loading ? null : _loadAppointments,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by hospital or speciality',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Error: $_error', textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadAppointments,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _filtered.isEmpty
                        ? const Center(child: Text('No appointments found'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              final a = _filtered[index];
                              final scheduledDate = a['scheduledDate'] != null
                                  ? DateTime.tryParse(a['scheduledDate'].toString())
                                  : null;
                              final hospital = a['hospital'] is Map
                                  ? (a['hospital'] as Map)['name']?.toString() ?? '—'
                                  : '—';
                              final status = a['status']?.toString() ?? '—';
                              final speciality = a['speciality']?.toString() ?? '—';
                              final isMobile = a['isMobileBooking'] == true;
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: AppColors.primaryContainer.withValues(alpha: 0.9),
                                child: ListTile(
                                  title: Text(
                                    hospital,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (scheduledDate != null)
                                        Text(
                                          'Date: ${scheduledDate.toIso8601String().split('T')[0]}',
                                        ),
                                      Text('Speciality: $speciality'),
                                      Text('Status: $status'),
                                      if (isMobile)
                                        const Text(
                                          'Booked via app',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                  onTap: () => _showDetails(context, a),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context, Map<String, dynamic> a) {
    final scheduledDate = a['scheduledDate'] != null
        ? DateTime.tryParse(a['scheduledDate'].toString())
        : null;
    final hospital = a['hospital'] is Map
        ? (a['hospital'] as Map)['name']?.toString() ?? '—'
        : '—';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appointment Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hospital: $hospital'),
              if (scheduledDate != null)
                Text('Date: ${scheduledDate.toIso8601String().split('T')[0]}'),
              Text('Speciality: ${a['speciality'] ?? '—'}'),
              Text('Status: ${a['status'] ?? '—'}'),
              if (a['notes'] != null && a['notes'].toString().trim().isNotEmpty)
                Text('Notes: ${a['notes']}'),
              if (a['isMobileBooking'] == true)
                const Text('Booked via mobile app', style: TextStyle(color: AppColors.primary)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
