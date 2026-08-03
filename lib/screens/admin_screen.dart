import 'package:flutter/material.dart';

import 'package:cms/ui/mobadra_ui.dart';

/// Admin check-in is available on the web app. This screen is a placeholder.
class AdminScreen extends StatelessWidget {
  final String adminId;
  const AdminScreen({required this.adminId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MobadraAppBar(title: Text('Admin')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 24),
              Text(
                'Admin check-in is available on the web app.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Text(
                'Please log in to the CMS web app to scan patient QR codes and record check-ins.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
