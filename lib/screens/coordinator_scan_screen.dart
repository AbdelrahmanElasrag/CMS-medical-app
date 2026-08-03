import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:cms/services/api_service.dart';
import 'package:cms/ui/mobadra_ui.dart';
import 'package:cms/services/employee_auth_service.dart';

class CoordinatorScanScreen extends StatefulWidget {
  const CoordinatorScanScreen({super.key});

  @override
  State<CoordinatorScanScreen> createState() => _CoordinatorScanScreenState();
}

class _CoordinatorScanScreenState extends State<CoordinatorScanScreen> {
  bool _busy = false;
  final _scanner = MobileScannerController();

  Future<void> _onDetect(BarcodeCapture cap) async {
    if (_busy) return;
    final codes = cap.barcodes;
    if (codes.isEmpty) return;
    final raw = codes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    final token = await EmployeeAuthService.instance.getToken();
    if (token == null || !mounted) return;

    setState(() => _busy = true);
    try {
      final res = await ApiService.instance.postJsonWithBearer(
        '/web/check-in/scan',
        {'scannedId': raw.trim()},
        token,
      );
      final d = res['data'] as Map<String, dynamic>?;
      final name = d?['displayName']?.toString();
      final pts = d?['pointsAwarded'];
      final msg = name != null
          ? 'Check-in: $name${pts != null ? ' (+$pts pts)' : ''}'
          : (res['message']?.toString() ?? 'Check-in recorded');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MobadraAppBar(
        title: const Text('Scan patient QR'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scanner,
            onDetect: _onDetect,
          ),
          if (_busy)
            Container(
              color: Colors.black38,
              child: const Center(child: CircularProgressIndicator()),
            ),
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: Text(
              'Point the camera at the patient or family QR code from the Creative Mobadra app.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 4)]),
            ),
          ),
        ],
      ),
    );
  }
}
