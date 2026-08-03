import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'family_member.dart';
import 'family_provider.dart';
import 'package:cms/services/auth_service.dart';
import 'package:cms/services/api_service.dart';
import 'package:cms/theme/app_tokens.dart';
import 'package:cms/ui/booking_auth_prompt.dart';
import 'package:cms/ui/mobadra_ui.dart';

class ServiceScreen extends StatefulWidget {
  final String service;
  final String username;
  final String? initialNotes;

  const ServiceScreen({
    super.key,
    required this.service,
    required this.username,
    this.initialNotes,
  });

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _referralController = TextEditingController();
  final _locationController = TextEditingController();

  List<Map<String, dynamic>> _hospitals = [];
  List<Map<String, dynamic>> _specialities = [];
  String? _hospitalId;
  String? _specialityId;
  DateTime? _preferredDate;
  TimeOfDay? _preferredTime;
  bool _loadingMeta = true;
  bool _submitting = false;
  String? _loadError;
  bool _transportNeeded = false;

  static InputDecoration _fieldDeco(String label, {String? hint, Widget? prefix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = Provider.of<AuthService>(context, listen: false);
      if (!auth.isLoggedIn) {
        final nav = Navigator.of(context);
        nav.pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final c = nav.context;
          if (c.mounted) showBookingAuthPrompt(c);
        });
        return;
      }
      _loadMeta();
      final n = widget.initialNotes;
      if (n != null && n.trim().isNotEmpty) {
        _notesController.text = n.trim();
      }
    });
  }

  Future<void> _loadMeta() async {
    setState(() {
      _loadingMeta = true;
      _loadError = null;
    });
    try {
      final h = await ApiService.instance.getJson('/mobile/appointments/hospitals');
      final s = await ApiService.instance.getJson('/mobile/appointments/specialities');
      final hl = h['data']?['hospitals'] as List? ?? [];
      final sl = s['data']?['specialities'] as List? ?? [];
      if (!mounted) return;
      setState(() {
        _hospitals = hl.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _specialities = sl.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _loadingMeta = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e.toString();
          _loadingMeta = false;
        });
      }
    }
  }

  IconData _relationshipIcon(String relationship) {
    switch (relationship.toLowerCase()) {
      case 'mother':
      case 'wife':
        return Icons.female;
      case 'father':
      case 'husband':
        return Icons.male;
      case 'daughter':
        return Icons.girl;
      case 'son':
        return Icons.boy;
      default:
        return Icons.person;
    }
  }

  Future<void> _pickDate() async {
    final cs = Theme.of(context).colorScheme;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: cs.primary,
              onPrimary: cs.onPrimary,
              onSurface: cs.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _preferredDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _preferredTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _preferredTime = picked);
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay t) {
    return t.format(context);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_hospitalId == null || _specialityId == null || _preferredDate == null || _preferredTime == null) {
      mobadraToast(context, 'Select hospital, speciality, preferred date, and preferred time', error: true);
      return;
    }

    final auth = Provider.of<AuthService>(context, listen: false);
    if (!auth.isLoggedIn) {
      mobadraToast(context, 'Please sign in to book', error: true);
      return;
    }

    if (_transportNeeded && _locationController.text.trim().isEmpty) {
      mobadraToast(context, 'Enter your pickup location for transportation', error: true);
      return;
    }

    final familyProvider = Provider.of<FamilyProvider>(context, listen: false);
    final fmId = familyProvider.selectedMember?.id;

    setState(() => _submitting = true);
    try {
      final body = <String, dynamic>{
        'hospitalId': _hospitalId,
        'specialityId': _specialityId,
        'preferredDate': _preferredDate!.toIso8601String(),
        'preferredTime':
            '${_preferredTime!.hour.toString().padLeft(2, '0')}:${_preferredTime!.minute.toString().padLeft(2, '0')}',
        if (_notesController.text.trim().isNotEmpty) 'notes': _notesController.text.trim(),
        if (fmId != null) 'familyMemberId': fmId,
        if (_referralController.text.trim().isNotEmpty)
          'salesReferralCode': _referralController.text.trim(),
        'transportationNeeded': _transportNeeded,
        if (_transportNeeded) 'pickupLocation': _locationController.text.trim(),
      };

      final res = await ApiService.instance.postJson('/mobile/appointments', body);
      final bonus = res['data']?['appointment']?['referralBonusPoints'] ?? 0;
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => ShadDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 28),
              const SizedBox(width: 10),
              const Expanded(child: Text('Booking submitted')),
            ],
          ),
          description: Text(
            bonus > 0
                ? 'Your appointment request was sent. You earned $bonus bonus points from your sales code.'
                : 'Your appointment request was sent. Our team will follow up.',
          ),
          actions: [
            ShadButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        mobadraToast(context, 'Booking failed: $e', error: true);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _referralController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final familyProvider = Provider.of<FamilyProvider>(context);
    final scheme = ShadTheme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.neutralSurface,
      appBar: MobadraAppBar(
        title: Row(
          children: [
            const Icon(Icons.event_available_rounded, size: 26),
            const SizedBox(width: 10),
            Expanded(child: Text(widget.service)),
          ],
        ),
      ),
      body: _loadingMeta
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                  const SizedBox(height: 16),
                  Text('Loading hospitals…', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : _loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 56, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(_loadError!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade800, height: 1.35)),
                        const SizedBox(height: 20),
                        ShadButton(
                          onPressed: _loadMeta,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh_rounded, size: 20, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Retry'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, 16, AppSpacing.md, 32),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withValues(alpha: 0.12),
                                AppColors.secondary.withValues(alpha: 0.15),
                              ],
                            ),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Book with Creative Mobadra',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.primary,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Hi ${widget.username}, choose hospital, speciality, and date.',
                                      style: TextStyle(color: Colors.grey.shade800, height: 1.35, fontSize: 13.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _SectionHeader(icon: Icons.people_outline_rounded, title: 'Who is this for?', accent: AppColors.secondary),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.25)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: DropdownButtonFormField<String>(
                            value: familyProvider.selectedMember?.id ?? '__self',
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            ),
                            icon: Icon(Icons.expand_more_rounded, color: AppColors.primary),
                            items: [
                              const DropdownMenuItem(value: '__self', child: Text('Myself')),
                              ...familyProvider.familyMembers.map(
                                (m) => DropdownMenuItem(
                                  value: m.id,
                                  child: Row(
                                    children: [
                                      Icon(_relationshipIcon(m.relationship), color: AppColors.primary, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text('${m.relationship}: ${m.firstName}')),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              if (v == null || v == '__self') {
                                familyProvider.selectMember(null);
                              } else {
                                FamilyMember? m;
                                for (final x in familyProvider.familyMembers) {
                                  if (x.id == v) {
                                    m = x;
                                    break;
                                  }
                                }
                                if (m != null) familyProvider.selectMember(m);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 22),
                        _SectionHeader(icon: Icons.local_hospital_rounded, title: 'Visit details', accent: AppColors.primary),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _hospitalId,
                          decoration: _fieldDeco(
                            'Hospital',
                            prefix: const Icon(Icons.apartment_rounded, color: AppColors.primary),
                          ),
                          items: _hospitals
                              .map(
                                (h) => DropdownMenuItem(
                                  value: h['id'] as String,
                                  child: Text(h['name'] as String? ?? ''),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _hospitalId = v),
                          validator: (v) => v == null ? 'Choose a hospital' : null,
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: _specialityId,
                          decoration: _fieldDeco(
                            'Speciality',
                            prefix: const Icon(Icons.medical_services_outlined, color: AppColors.primary),
                          ),
                          items: _specialities
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s['id'] as String,
                                  child: Text(s['name'] as String? ?? ''),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _specialityId = v),
                          validator: (v) => v == null ? 'Choose a speciality' : null,
                        ),
                            const SizedBox(height: 14),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final compact = constraints.maxWidth < 560;
                                final dateField = Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(AppRadii.md),
                                  child: InkWell(
                                    onTap: _pickDate,
                                    borderRadius: BorderRadius.circular(AppRadii.md),
                                    child: InputDecorator(
                                      decoration: _fieldDeco(
                                        'Preferred date',
                                        prefix: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _preferredDate == null
                                                  ? 'Tap to choose a date'
                                                  : _formatDate(_preferredDate!),
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: _preferredDate == null ? Colors.grey.shade500 : Colors.grey.shade900,
                                                fontWeight: _preferredDate == null ? FontWeight.w500 : FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Icon(Icons.edit_calendar_outlined, color: AppColors.secondary, size: 22),
                                        ],
                                      ),
                                    ),
                                  ),
                                );

                                final timeField = Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(AppRadii.md),
                                  child: InkWell(
                                    onTap: _pickTime,
                                    borderRadius: BorderRadius.circular(AppRadii.md),
                                    child: InputDecorator(
                                      decoration: _fieldDeco(
                                        'Preferred time',
                                        prefix: const Icon(Icons.access_time_rounded, color: AppColors.primary),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _preferredTime == null
                                                  ? 'Tap to choose a time'
                                                  : _formatTime(_preferredTime!),
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: _preferredTime == null ? Colors.grey.shade500 : Colors.grey.shade900,
                                                fontWeight: _preferredTime == null ? FontWeight.w500 : FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Icon(Icons.schedule_rounded, color: AppColors.secondary, size: 22),
                                        ],
                                      ),
                                    ),
                                  ),
                                );

                                if (compact) {
                                  return Column(
                                    children: [
                                      dateField,
                                      const SizedBox(height: 12),
                                      timeField,
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    Expanded(child: dateField),
                                    const SizedBox(width: 12),
                                    Expanded(child: timeField),
                                  ],
                                );
                              },
                            ),
                        const SizedBox(height: 22),
                        _SectionHeader(icon: Icons.directions_car_rounded, title: 'Transportation', accent: AppColors.tertiary),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                            border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.35)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.tertiary.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShadCheckbox(
                                value: _transportNeeded,
                                onChanged: (v) => setState(() {
                                  _transportNeeded = v;
                                  if (!v) _locationController.clear();
                                }),
                                label: Text(
                                  'Transportation needed (pickup / hospital transport)',
                                  style: TextStyle(
                                    color: scheme.foreground.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (_transportNeeded) ...[
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _locationController,
                                  maxLines: 2,
                                  validator: (value) {
                                    if (!_transportNeeded) return null;
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Enter pickup address or location';
                                    }
                                    return null;
                                  },
                                  decoration: _fieldDeco(
                                    'Pickup location',
                                    hint: 'Building, street, area, city…',
                                    prefix: const Icon(Icons.location_on_rounded, color: AppColors.tertiary),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        _SectionHeader(icon: Icons.edit_note_rounded, title: 'Extras', accent: AppColors.primary),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _referralController,
                          decoration: _fieldDeco(
                            'Sales rep code (optional)',
                            hint: 'Earn bonus points if your rep gave you a code',
                            prefix: const Icon(Icons.card_giftcard_rounded, color: AppColors.tertiary),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: _fieldDeco(
                            'Notes (optional)',
                            hint: 'Anything else we should know',
                            prefix: const Padding(
                              padding: EdgeInsets.only(bottom: 40),
                              child: Icon(Icons.notes_rounded, color: AppColors.primary),
                            ),
                          ),
                        ),
                            const SizedBox(height: 28),
                            DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                                  onPressed: _submitting
                                      ? null
                                      : () {
                                          if (_preferredDate == null || _preferredTime == null) {
                                            mobadraToast(
                                              context,
                                              'Please select preferred date and preferred time',
                                              error: true,
                                            );
                                            return;
                                          }
                                          _submit();
                                        },
                              child: _submitting
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_rounded, size: 22),
                                        SizedBox(width: 10),
                                        Text(
                                          'Confirm booking',
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accent, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: 0.2,
              ),
        ),
      ],
    );
  }
}
