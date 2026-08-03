import 'package:flutter/material.dart';

import 'package:cms/screens/admin_dashboard_screen.dart';
import 'package:cms/screens/coordinator_dashboard_screen.dart';
import 'package:cms/services/api_service.dart';
import 'package:cms/services/employee_auth_service.dart';
import 'package:cms/ui/auth_form_styles.dart';
import 'package:cms/ui/mobadra_motion.dart';
import 'package:cms/ui/mobadra_surface.dart';
import 'package:cms/ui/mobadra_toast.dart';
import 'package:cms/widgets/custom_scaffold.dart';

class StaffLoginScreen extends StatefulWidget {
  const StaffLoginScreen({super.key});

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  static const _adminRoles = {'admin'};
  static const _staffRoles = {'admin', 'team_leader', 'coordinator'};
  static const _buttonBlue = Color(0xFF003D7A);

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _resolveRole(Map<String, dynamic> user) {
    final role = user['role']?.toString();
    if (role != null && _staffRoles.contains(role)) return role;
    final roles = user['roles'];
    if (roles is List) {
      for (final r in roles) {
        final s = r?.toString();
        if (s != null && _staffRoles.contains(s)) return s;
      }
    }
    return null;
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final res = await ApiService.instance.postJson(
        '/auth/login',
        {
          'phone': _phoneController.text.trim(),
          'password': _passwordController.text,
        },
        requireAuth: false,
      );
      final data = res['data'] as Map<String, dynamic>?;
      final token = data?['accessToken'] as String?;
      final user = data?['user'] as Map<String, dynamic>?;
      if (token == null || user == null) {
        throw ApiException('Unexpected login response');
      }
      final role = _resolveRole(user);
      if (role == null) {
        throw ApiException('This account does not have staff access.');
      }
      final employeeId = user['id']?.toString() ?? '';
      final employeeName = user['name']?.toString() ?? '';
      await EmployeeAuthService.instance.setSession(token, role, employeeId, employeeName);
      if (!mounted) return;
      final dest = _adminRoles.contains(role)
          ? const AdminDashboardScreen()
          : const CoordinatorDashboardScreen();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => dest),
      );
    } on ApiException catch (e) {
      if (mounted) mobadraToast(context, e.message, error: true);
    } catch (e) {
      if (mounted) mobadraToast(context, 'Login failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return CustomScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset + 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: MobadraAuthSheet(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Staff Sign In',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.w800,
                              ),
                        ).mobadraFadeSlide(),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in with your Mobadra staff credentials.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ).mobadraFadeSlide(delayMs: 40),
                        const SizedBox(height: 28),
                        authFieldLabel('Phone Number'),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Please enter phone number' : null,
                          decoration: authFilledDecoration(
                            hintText: '+971 -- --- ----',
                            prefixIcon: const Icon(Icons.phone_outlined),
                          ),
                        ).mobadraFadeSlide(delayMs: 60),
                        const SizedBox(height: 18),
                        authFieldLabel('Password'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Please enter password' : null,
                          decoration: authFilledDecoration(
                            hintText: '••••••••••••',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ).mobadraFadeSlide(delayMs: 80),
                        const SizedBox(height: 32),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _buttonBlue.withValues(alpha: 0.42),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: _buttonBlue,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: _buttonBlue.withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              onPressed: _loading ? null : _signIn,
                              child: _loading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800, fontSize: 16),
                                    ),
                            ),
                          ),
                        ).mobadraFadeSlide(delayMs: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
