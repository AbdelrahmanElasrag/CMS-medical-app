import 'package:flutter/material.dart';

import 'package:cms/services/admin_appointments_service.dart';
import 'package:cms/services/api_service.dart';
import 'package:cms/services/employee_auth_service.dart';
import 'package:cms/ui/mobadra_ui.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  List<AdminAppointment> _appointments = const <AdminAppointment>[];
  String? _token;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final token = await EmployeeAuthService.instance.getToken();
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      setState(() {
        _error = 'Admin session expired. Please sign in again.';
        _loading = false;
      });
      return;
    }
    _token = token;
    await _fetch();
  }

  Future<void> _fetch() async {
    final token = _token;
    if (token == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await AdminAppointmentsService.instance.listAppointments(token: token);
      if (!mounted) return;
      setState(() {
        _appointments = page.items.where((a) => a.isMobileBooking).toList();
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _fmtDateTime(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    final d = '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
    final t = '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return '$d  $t';
  }

  Future<void> _openRescheduleDialog(AdminAppointment appointment) async {
    final token = _token;
    if (token == null || _saving) return;
    final specialities = appointment.appointmentSpecialities;
    AdminAppointmentSpeciality? selectedSpec = specialities.isEmpty ? null : specialities.first;
    var chosen = selectedSpec?.scheduledTime?.toLocal() ?? appointment.scheduledDate?.toLocal() ?? DateTime.now().add(const Duration(hours: 1));
    String? dialogError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocalState) {
            return AlertDialog(
              title: const Text('Set hospital-confirmed schedule'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      appointment.patientName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.hospitalName,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 14),
                    if (specialities.length > 1) ...[
                      DropdownButtonFormField<String>(
                        value: selectedSpec?.id,
                        items: specialities
                            .map(
                              (s) => DropdownMenuItem<String>(
                                value: s.id,
                                child: Text(s.specialityName),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          final found = specialities.firstWhere((s) => s.id == v);
                          setLocalState(() {
                            selectedSpec = found;
                            chosen = found.scheduledTime?.toLocal() ?? chosen;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Speciality',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: dialogContext,
                          initialDate: chosen,
                          firstDate: DateTime.now().subtract(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                        );
                        if (date == null) return;
                        setLocalState(() {
                          chosen = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            chosen.hour,
                            chosen.minute,
                          );
                        });
                      },
                      icon: const Icon(Icons.calendar_today_rounded),
                      label: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Date: ${_fmtDateTime(chosen).split('  ').first}'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: dialogContext,
                          initialTime: TimeOfDay.fromDateTime(chosen),
                        );
                        if (picked == null) return;
                        setLocalState(() {
                          chosen = DateTime(
                            chosen.year,
                            chosen.month,
                            chosen.day,
                            picked.hour,
                            picked.minute,
                          );
                        });
                      },
                      icon: const Icon(Icons.access_time_rounded),
                      label: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Time: ${chosen.hour.toString().padLeft(2, '0')}:${chosen.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                    if (dialogError != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        dialogError!,
                        style: TextStyle(color: Theme.of(dialogContext).colorScheme.error),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _saving ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          setLocalState(() => dialogError = null);
                          setState(() => _saving = true);
                          try {
                            await AdminAppointmentsService.instance.updateAppointmentDate(
                              token: token,
                              appointmentId: appointment.id,
                              scheduledDateTime: chosen.toUtc(),
                            );
                            if (selectedSpec != null && selectedSpec!.doctorId.isNotEmpty) {
                              await AdminAppointmentsService.instance.updateAppointmentSpecialityTime(
                                token: token,
                                appointmentId: appointment.id,
                                appointmentSpecialityId: selectedSpec!.id,
                                doctorId: selectedSpec!.doctorId,
                                scheduledTime: chosen.toUtc(),
                              );
                            }
                            if (!mounted) return;
                            Navigator.pop(dialogContext);
                            await _fetch();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Booking schedule updated')),
                            );
                          } on ApiException catch (e) {
                            setLocalState(() => dialogError = e.message);
                          } catch (e) {
                            setLocalState(() => dialogError = e.toString());
                          } finally {
                            if (mounted) setState(() => _saving = false);
                          }
                        },
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBookingCard(AdminAppointment a) {
    final speciality = a.appointmentSpecialities.isEmpty ? null : a.appointmentSpecialities.first;
    final confirmedTime = speciality?.scheduledTime;
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    a.patientName,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ),
                Chip(
                  label: Text(a.status),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${a.hospitalName} • ${speciality?.specialityName ?? 'General'}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            if (a.patientPhone.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                a.patientPhone,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
            const Divider(height: 18),
            Text(
              'Requested date/time: ${_fmtDateTime(a.scheduledDate)}',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'Hospital-confirmed date/time: ${_fmtDateTime(confirmedTime)}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            if (a.notes.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                a.notes.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => _openRescheduleDialog(a),
                icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                label: const Text('Edit date/time'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MobadraAppBar(
        title: const Row(
          children: [
            Icon(Icons.calendar_month_rounded, size: 22),
            SizedBox(width: 8),
            Text('Admin Bookings'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade300),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _fetch,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: _appointments.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 140),
                            Center(
                              child: Text(
                                'No mobile bookings found.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          itemCount: _appointments.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => _buildBookingCard(_appointments[i]),
                        ),
                ),
    );
  }
}
