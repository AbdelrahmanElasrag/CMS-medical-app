import 'package:flutter/material.dart';

import 'package:cms/services/api_service.dart';
import 'package:cms/services/employee_auth_service.dart';
import 'package:cms/screens/coordinator_scan_screen.dart';
import 'package:cms/ui/mobadra_ui.dart';

class CoordinatorLoginScreen extends StatefulWidget {
  const CoordinatorLoginScreen({super.key});

  @override
  State<CoordinatorLoginScreen> createState() => _CoordinatorLoginScreenState();
}

class _CoordinatorLoginScreenState extends State<CoordinatorLoginScreen> {
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  static const _allowed = {'admin', 'team_leader', 'coordinator'};

  bool _isAllowedRole(Map<String, dynamic> user) {
    final role = user['role']?.toString();
    if (role != null && _allowed.contains(role)) return true;
    final roles = user['roles'];
    if (roles is List) {
      for (final r in roles) {
        if (_allowed.contains(r?.toString())) return true;
      }
    }
    return false;
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.instance.postJson(
        '/auth/login',
        {'phone': _phone.text.trim(), 'password': _password.text},
        requireAuth: false,
      );
      final data = res['data'] as Map<String, dynamic>?;
      final token = data?['accessToken'] as String?;
      final user = data?['user'] as Map<String, dynamic>?;
      if (token == null || user == null) {
        setState(() => _error = 'Unexpected login response');
        return;
      }
      if (!_isAllowedRole(user)) {
        setState(() => _error = 'This account cannot use coordinator scan. Use admin, team leader, or coordinator.');
        return;
      }
      await EmployeeAuthService.instance.setToken(token);
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CoordinatorScanScreen()),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MobadraAppBar(title: Text('Coordinator login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sign in with your CMS staff phone and password to scan patient QR codes.',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _password,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 24),
            ShadButton(
              enabled: !_loading,
              onPressed: _login,
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
