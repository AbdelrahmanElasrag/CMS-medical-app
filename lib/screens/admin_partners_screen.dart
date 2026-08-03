import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:cms/services/api_service.dart';
import 'package:cms/services/employee_auth_service.dart';
import 'package:cms/theme/app_tokens.dart';
import 'package:cms/ui/mobadra_ui.dart';
import 'package:image_picker/image_picker.dart';

// ── Data models ───────────────────────────────────────────────────────────────

class _Hospital {
  final String id;
  final String name;
  final String? address;

  const _Hospital({required this.id, required this.name, this.address});

  factory _Hospital.fromJson(Map<String, dynamic> j) => _Hospital(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? 'Unnamed',
        address: j['address']?.toString(),
      );
}

class _PartnerOffer {
  final String id;
  final String title;
  final String? subtitle;
  final String? body;
  final String? imageUrl;
  final String? hospitalId;
  final String? hospitalName;
  final String? ctaLabel;
  final String? ctaUrl;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final bool isActive;
  final int sortOrder;

  const _PartnerOffer({
    required this.id,
    required this.title,
    this.subtitle,
    this.body,
    this.imageUrl,
    this.hospitalId,
    this.hospitalName,
    this.ctaLabel,
    this.ctaUrl,
    this.validFrom,
    this.validUntil,
    required this.isActive,
    required this.sortOrder,
  });

  factory _PartnerOffer.fromJson(Map<String, dynamic> j) {
    final hospital = j['hospital'] as Map<String, dynamic>?;
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try { return DateTime.parse(v.toString()).toLocal(); } catch (_) { return null; }
    }
    return _PartnerOffer(
      id: j['id']?.toString() ?? '',
      title: j['title']?.toString() ?? 'Untitled',
      subtitle: j['subtitle']?.toString(),
      body: j['body']?.toString(),
      imageUrl: j['imageUrl']?.toString(),
      hospitalId: hospital?['id']?.toString() ?? j['hospitalId']?.toString(),
      hospitalName: hospital?['name']?.toString(),
      ctaLabel: j['ctaLabel']?.toString(),
      ctaUrl: j['ctaUrl']?.toString(),
      validFrom: parseDate(j['validFrom']),
      validUntil: parseDate(j['validUntil']),
      isActive: j['isActive'] != false,
      sortOrder: (j['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminPartnersScreen extends StatefulWidget {
  const AdminPartnersScreen({super.key});

  @override
  State<AdminPartnersScreen> createState() => _AdminPartnersScreenState();
}

class _AdminPartnersScreenState extends State<AdminPartnersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  String? _token;

  List<_Hospital> _hospitals = [];
  bool _loadingHospitals = true;
  String? _hospitalError;

  List<_PartnerOffer> _offers = [];
  bool _loadingOffers = true;
  String? _offerError;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _init();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _token = await EmployeeAuthService.instance.getToken();
    await Future.wait([_fetchHospitals(), _fetchOffers()]);
  }

  // ── Hospital CRUD ──────────────────────────────────────────────────────────

  Future<void> _fetchHospitals() async {
    if (_token == null) return;
    setState(() { _loadingHospitals = true; _hospitalError = null; });
    try {
      final res = await ApiService.instance.getJsonWithBearer('/hospital', _token!);
      final raw = res['data'];
      final list = raw is List ? raw : (raw is Map ? raw['hospitals'] ?? [] : []);
      setState(() {
        _hospitals = (list as List)
            .whereType<Map<String, dynamic>>()
            .map(_Hospital.fromJson)
            .toList();
        _loadingHospitals = false;
      });
    } on ApiException catch (e) {
      setState(() { _hospitalError = e.message; _loadingHospitals = false; });
    } catch (e) {
      setState(() { _hospitalError = e.toString(); _loadingHospitals = false; });
    }
  }

  Future<void> _showHospitalDialog({_Hospital? editing}) async {
    final nameCtrl = TextEditingController(text: editing?.name ?? '');
    final addrCtrl = TextEditingController(text: editing?.address ?? '');
    final formKey = GlobalKey<FormState>();
    bool submitting = false;
    String? dialogError;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(editing == null ? 'Add hospital / clinic' : 'Edit hospital'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_hospital_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addrCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  if (dialogError != null) ...[
                    const SizedBox(height: 10),
                    Text(dialogError!,
                        style: TextStyle(
                            color: Theme.of(ctx).colorScheme.error,
                            fontSize: 13)),
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
                      setLocal(() { submitting = true; dialogError = null; });
                      try {
                        final body = {
                          'name': nameCtrl.text.trim(),
                          if (addrCtrl.text.trim().isNotEmpty)
                            'address': addrCtrl.text.trim(),
                        };
                        if (editing == null) {
                          await ApiService.instance
                              .postJsonWithBearer('/hospital', body, _token!);
                        } else {
                          await ApiService.instance.putJsonWithBearer(
                              '/hospital/${editing.id}', body, _token!);
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                        await _fetchHospitals();
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
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(editing == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
    nameCtrl.dispose();
    addrCtrl.dispose();
  }

  Future<void> _deleteHospital(_Hospital h) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove partner'),
        content: Text('Remove "${h.name}"? This may affect linked offers.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ApiService.instance
          .deleteJsonWithBearer('/hospital/${h.id}', _token!);
      await Future.wait([_fetchHospitals(), _fetchOffers()]);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.message}')));
      }
    }
  }

  // ── Offer CRUD ─────────────────────────────────────────────────────────────

  Future<void> _fetchOffers() async {
    if (_token == null) return;
    setState(() { _loadingOffers = true; _offerError = null; });
    try {
      final res = await ApiService.instance
          .getJsonWithBearer('/partner-offers', _token!);
      final raw = res['data'];
      List<dynamic> list;
      if (raw is Map) {
        list = (raw['offers'] ?? []) as List;
      } else if (raw is List) {
        list = raw;
      } else {
        list = [];
      }
      setState(() {
        _offers = list
            .whereType<Map<String, dynamic>>()
            .map(_PartnerOffer.fromJson)
            .toList();
        _loadingOffers = false;
      });
    } on ApiException catch (e) {
      setState(() { _offerError = e.message; _loadingOffers = false; });
    } catch (e) {
      setState(() { _offerError = e.toString(); _loadingOffers = false; });
    }
  }

  Future<void> _showOfferDialog({_PartnerOffer? editing, String? presetHospitalId}) async {
    final titleCtrl = TextEditingController(text: editing?.title ?? '');
    final subtitleCtrl = TextEditingController(text: editing?.subtitle ?? '');
    final bodyCtrl = TextEditingController(text: editing?.body ?? '');
    final imageCtrl = TextEditingController(text: editing?.imageUrl ?? '');
    final ctaLabelCtrl = TextEditingController(text: editing?.ctaLabel ?? '');
    final ctaUrlCtrl = TextEditingController(text: editing?.ctaUrl ?? '');
    final sortCtrl = TextEditingController(text: (editing?.sortOrder ?? 0).toString());
    final formKey = GlobalKey<FormState>();

    String? selectedHospitalId = editing?.hospitalId ?? presetHospitalId;
    DateTime? validFrom = editing?.validFrom;
    DateTime? validUntil = editing?.validUntil;
    bool isActive = editing?.isActive ?? true;
    bool submitting = false;
    bool uploadingImage = false;
    String? dialogError;

    String? formatOfferDate(DateTime? dt) {
      if (dt == null) return null;
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          Future<void> pickDate(bool isStart) async {
            final picked = await showDatePicker(
              context: ctx,
              initialDate: (isStart ? validFrom : validUntil) ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              setLocal(() {
                if (isStart) { validFrom = picked; } else { validUntil = picked; }
              });
            }
          }

          return AlertDialog(
            title: Text(editing == null ? 'Add offer' : 'Edit offer'),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: subtitleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Subtitle',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: bodyCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: imageCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Image URL',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.image_outlined),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: uploadingImage
                              ? null
                              : () async {
                                  setLocal(() {
                                    uploadingImage = true;
                                    dialogError = null;
                                  });
                                  try {
                                    final picked = await _imagePicker.pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 88,
                                      maxWidth: 1800,
                                    );
                                    if (picked == null) {
                                      setLocal(() => uploadingImage = false);
                                      return;
                                    }

                                    final bytes = await picked.readAsBytes();
                                    if (bytes.isEmpty) {
                                      throw Exception('Selected image is empty');
                                    }

                                    final mime = _mimeTypeFromFileName(picked.name);
                                    final base64Image = base64Encode(bytes);
                                    final payload = 'data:$mime;base64,$base64Image';

                                    final res = await ApiService.instance.postJsonWithBearer(
                                      '/upload/national-id',
                                      <String, dynamic>{'image': payload},
                                      _token!,
                                    );

                                    final fileUrl = (res['fileUrl'] ?? res['data']?['fileUrl'])?.toString();
                                    if (fileUrl == null || fileUrl.isEmpty) {
                                      throw Exception('Upload succeeded but no file URL was returned');
                                    }

                                    setLocal(() {
                                      imageCtrl.text = _resolveImageUrl(fileUrl);
                                      uploadingImage = false;
                                    });
                                  } on ApiException catch (e) {
                                    setLocal(() {
                                      dialogError = e.message;
                                      uploadingImage = false;
                                    });
                                  } catch (e) {
                                    setLocal(() {
                                      dialogError = 'Image upload failed: $e';
                                      uploadingImage = false;
                                    });
                                  }
                                },
                          icon: uploadingImage
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.upload_rounded),
                          label: Text(uploadingImage ? 'Uploading...' : 'Upload image'),
                        ),
                      ),
                      if (imageCtrl.text.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageCtrl.text.trim(),
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 120,
                              alignment: Alignment.center,
                              color: Colors.grey.shade100,
                              child: const Text('Preview unavailable'),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      // Hospital dropdown
                      DropdownButtonFormField<String?>(
                        value: selectedHospitalId,
                        decoration: const InputDecoration(
                          labelText: 'Partner (hospital)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.local_hospital_outlined),
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('— No hospital —')),
                          ..._hospitals.map((h) => DropdownMenuItem(
                                value: h.id,
                                child: Text(h.name),
                              )),
                        ],
                        onChanged: (v) =>
                            setLocal(() => selectedHospitalId = v),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: ctaLabelCtrl,
                              decoration: const InputDecoration(
                                labelText: 'CTA Label',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: ctaUrlCtrl,
                              decoration: const InputDecoration(
                                labelText: 'CTA URL',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.url,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Date range row
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => pickDate(true),
                              borderRadius: BorderRadius.circular(4),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Valid from',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today_outlined, size: 16),
                                ),
                                child: Text(
                                  formatOfferDate(validFrom) ?? 'Any',
                                  style: TextStyle(
                                      color: validFrom != null
                                          ? null
                                          : Colors.grey[500]),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: InkWell(
                              onTap: () => pickDate(false),
                              borderRadius: BorderRadius.circular(4),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Valid until',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.event_outlined, size: 16),
                                ),
                                child: Text(
                                  formatOfferDate(validUntil) ?? 'No expiry',
                                  style: TextStyle(
                                      color: validUntil != null
                                          ? null
                                          : Colors.grey[500]),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: sortCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Sort order',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SwitchListTile(
                              value: isActive,
                              onChanged: (v) =>
                                  setLocal(() => isActive = v),
                              title: const Text('Active',
                                  style: TextStyle(fontSize: 13)),
                              contentPadding: EdgeInsets.zero,
                              activeColor: AppColors.primary,
                            ),
                          ),
                        ],
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
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel')),
              FilledButton(
                onPressed: submitting
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setLocal(() { submitting = true; dialogError = null; });
                        try {
                          final body = <String, dynamic>{
                            'title': titleCtrl.text.trim(),
                            'subtitle': subtitleCtrl.text.trim().isEmpty
                                ? null
                                : subtitleCtrl.text.trim(),
                            'body': bodyCtrl.text.trim().isEmpty
                                ? null
                                : bodyCtrl.text.trim(),
                            'imageUrl': imageCtrl.text.trim().isEmpty
                                ? null
                                : imageCtrl.text.trim(),
                            'hospitalId': selectedHospitalId,
                            'ctaLabel': ctaLabelCtrl.text.trim().isEmpty
                                ? null
                                : ctaLabelCtrl.text.trim(),
                            'ctaUrl': ctaUrlCtrl.text.trim().isEmpty
                                ? null
                                : ctaUrlCtrl.text.trim(),
                            'validFrom': validFrom?.toIso8601String(),
                            'validUntil': validUntil?.toIso8601String(),
                            'isActive': isActive,
                            'sortOrder': int.tryParse(sortCtrl.text) ?? 0,
                          };
                          if (editing == null) {
                            await ApiService.instance.postJsonWithBearer(
                                '/partner-offers', body, _token!);
                          } else {
                            await ApiService.instance.patchJsonWithBearer(
                                '/partner-offers/${editing.id}', body, _token!);
                          }
                          if (ctx.mounted) Navigator.pop(ctx);
                          await _fetchOffers();
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
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(editing == null ? 'Add' : 'Save'),
              ),
            ],
          );
        },
      ),
    );

    titleCtrl.dispose();
    subtitleCtrl.dispose();
    bodyCtrl.dispose();
    imageCtrl.dispose();
    ctaLabelCtrl.dispose();
    ctaUrlCtrl.dispose();
    sortCtrl.dispose();
  }

  String _mimeTypeFromFileName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  String _resolveImageUrl(String raw) {
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    final base = Uri.parse(ApiService.instance.baseUrl);
    final origin = '${base.scheme}://${base.host}${base.hasPort ? ':${base.port}' : ''}';
    if (raw.startsWith('/')) return '$origin$raw';
    return '$origin/$raw';
  }

  Future<void> _deleteOffer(_PartnerOffer o) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete offer'),
        content: Text('Delete "${o.title}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ApiService.instance
          .deleteJsonWithBearer('/partner-offers/${o.id}', _token!);
      setState(() => _offers.removeWhere((x) => x.id == o.id));
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppColors.primary.withValues(alpha: 0.4),
        scrolledUnderElevation: 0,
        title: const Row(
          children: [
            Icon(Icons.handshake_outlined, size: 20),
            SizedBox(width: 8),
            Text(
              'Partners & Offers',
              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.local_hospital_outlined), text: 'Hospitals'),
            Tab(icon: Icon(Icons.local_offer_outlined), text: 'Offers'),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabs,
        builder: (_, __) {
          if (_tabs.index == 0) {
            return FloatingActionButton.extended(
              heroTag: 'fab_hospital',
              onPressed: _showHospitalDialog,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_business_rounded),
              label: const Text('Add hospital',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            );
          }
          return FloatingActionButton.extended(
            heroTag: 'fab_offer',
            onPressed: _showOfferDialog,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add offer',
                style: TextStyle(fontWeight: FontWeight.w700)),
          );
        },
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _HospitalsTab(
            hospitals: _hospitals,
            loading: _loadingHospitals,
            error: _hospitalError,
            offersOf: (id) =>
                _offers.where((o) => o.hospitalId == id).length,
            onRefresh: _fetchHospitals,
            onAdd: _showHospitalDialog,
            onEdit: (h) => _showHospitalDialog(editing: h),
            onDelete: _deleteHospital,
            onAddOffer: (h) {
              _tabs.animateTo(1);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showOfferDialog(presetHospitalId: h.id);
              });
            },
          ),
          _OffersTab(
            offers: _offers,
            loading: _loadingOffers,
            error: _offerError,
            onRefresh: _fetchOffers,
            onAdd: _showOfferDialog,
            onEdit: (o) => _showOfferDialog(editing: o),
            onDelete: _deleteOffer,
            onToggleActive: (o) async {
              try {
                await ApiService.instance.patchJsonWithBearer(
                  '/partner-offers/${o.id}',
                  {'isActive': !o.isActive},
                  _token!,
                );
                await _fetchOffers();
              } on ApiException catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.message}')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// ── Hospitals tab ─────────────────────────────────────────────────────────────

class _HospitalsTab extends StatelessWidget {
  final List<_Hospital> hospitals;
  final bool loading;
  final String? error;
  final int Function(String id) offersOf;
  final Future<void> Function() onRefresh;
  final void Function() onAdd;
  final void Function(_Hospital) onEdit;
  final void Function(_Hospital) onDelete;
  final void Function(_Hospital) onAddOffer;

  const _HospitalsTab({
    required this.hospitals,
    required this.loading,
    required this.error,
    required this.offersOf,
    required this.onRefresh,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onAddOffer,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (hospitals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_hospital_outlined,
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No hospitals yet',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Tap the button below to add a partner.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_business_rounded),
              label: const Text('Add hospital'),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: hospitals.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final h = hospitals[i];
          final count = offersOf(h.id);
          return ShadCard(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.local_hospital_outlined,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        if (h.address != null && h.address!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            h.address!,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _Pill(
                              icon: Icons.local_offer_outlined,
                              label: '$count offer${count == 1 ? '' : 's'}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Add offer',
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        color: AppColors.primary,
                        onPressed: () => onAddOffer(h),
                      ),
                      IconButton(
                        tooltip: 'Edit',
                        icon: const Icon(Icons.edit_outlined),
                        color: Colors.blueGrey,
                        onPressed: () => onEdit(h),
                      ),
                      IconButton(
                        tooltip: 'Remove',
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: Colors.red.shade400,
                        onPressed: () => onDelete(h),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Offers tab ────────────────────────────────────────────────────────────────

class _OffersTab extends StatelessWidget {
  final List<_PartnerOffer> offers;
  final bool loading;
  final String? error;
  final Future<void> Function() onRefresh;
  final void Function() onAdd;
  final void Function(_PartnerOffer) onEdit;
  final void Function(_PartnerOffer) onDelete;
  final void Function(_PartnerOffer) onToggleActive;

  const _OffersTab({
    required this.offers,
    required this.loading,
    required this.error,
    required this.onRefresh,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No offers yet',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Tap the button below to create an offer.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add offer'),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: offers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final o = offers[i];
          return ShadCard(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    o.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _StatusBadge(active: o.isActive),
                              ],
                            ),
                            if (o.subtitle != null &&
                                o.subtitle!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                o.subtitle!,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 13),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (o.body != null && o.body!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      o.body!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (o.hospitalName != null)
                        _Pill(
                          icon: Icons.local_hospital_outlined,
                          label: o.hospitalName!,
                        ),
                      if (o.ctaLabel != null)
                        _Pill(
                          icon: Icons.open_in_new_rounded,
                          label: o.ctaLabel!,
                        ),
                      _Pill(
                        icon: Icons.calendar_today_outlined,
                        label:
                            '${_formatDate(o.validFrom)} → ${_formatDate(o.validUntil)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => onToggleActive(o),
                        icon: Icon(
                          o.isActive
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 16,
                        ),
                        label:
                            Text(o.isActive ? 'Deactivate' : 'Activate'),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              o.isActive ? Colors.orange : Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 4),
                      TextButton.icon(
                        onPressed: () => onEdit(o),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blueGrey,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 4),
                      TextButton.icon(
                        onPressed: () => onDelete(o),
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 16),
                        label: const Text('Delete'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red.shade400,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Tiny helpers ──────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Pill({required this.icon, required this.label});

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
          Icon(icon, size: 11, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool active;

  const _StatusBadge({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.grey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: active ? Colors.green.shade700 : Colors.grey.shade600,
        ),
      ),
    );
  }
}
