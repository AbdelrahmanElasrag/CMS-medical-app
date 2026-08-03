import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_tokens.dart';
import '../ui/auth_form_styles.dart';
import '../ui/mobadra_motion.dart';
import '../ui/mobadra_surface.dart';
import '../ui/mobadra_toast.dart';
import '../widgets/custom_scaffold.dart';
import 'signin_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nationalIDController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool agreePersonalData = true;
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nationalIDController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formSignupKey.currentState!.validate()) return;
    if (!agreePersonalData) {
      mobadraToast(context, 'Please agree to the processing of personal data', error: true);
      return;
    }
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final nationalId = _nationalIDController.text.trim();
    final password = _passwordController.text;
    setState(() => _loading = true);
    try {
      await context.read<AuthService>().signup(
            name: name,
            phone: phone,
            nationalId: nationalId,
            password: password,
          );
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on ApiException catch (e) {
      if (!mounted) return;
      mobadraToast(context, e.message, error: true);
    } catch (e) {
      if (!mounted) return;
      mobadraToast(context, 'Registration failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ShadTheme.of(context).colorScheme;
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
                    key: _formSignupKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Create Account',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ).mobadraFadeSlide(),
                        const SizedBox(height: 8),
                        Text(
                          'Please enter your clinical credentials to begin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ).mobadraFadeSlide(delayMs: 40),
                        const SizedBox(height: 26),
                        authCapsLabel('Full Name'),
                        TextFormField(
                          controller: _nameController,
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Please enter your name' : null,
                          decoration: authFilledDecoration(
                            hintText: 'Dr. Sarah Al-Sayed',
                            suffixIcon: Icon(Icons.person_outline, color: Colors.grey.shade600),
                          ),
                        ).mobadraFadeSlide(delayMs: 50),
                        const SizedBox(height: 16),
                        authCapsLabel('Phone Number'),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Please enter phone number' : null,
                          decoration: authFilledDecoration(
                            hintText: '+971 -- --- ----',
                            suffixIcon: Icon(Icons.phone_outlined, color: Colors.grey.shade600),
                          ),
                        ).mobadraFadeSlide(delayMs: 65),
                        const SizedBox(height: 16),
                        authCapsLabel('National ID'),
                        TextFormField(
                          controller: _nationalIDController,
                          keyboardType: TextInputType.text,
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Please enter National ID' : null,
                          decoration: authFilledDecoration(
                            hintText: '784-XXXX-XXXXXXX-X',
                            suffixIcon: Icon(Icons.perm_identity_outlined, color: Colors.grey.shade600),
                          ),
                        ).mobadraFadeSlide(delayMs: 80),
                        const SizedBox(height: 16),
                        authCapsLabel('Password'),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter password';
                            if (value.length < 8) return 'Password must be at least 8 characters';
                            return null;
                          },
                          decoration: authFilledDecoration(
                            hintText: '••••••••••••',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                          ),
                        ).mobadraFadeSlide(delayMs: 95),
                        const SizedBox(height: 14),
                        ShadCheckbox(
                          value: agreePersonalData,
                          onChanged: (v) => setState(() => agreePersonalData = v),
                          label: Text(
                            'I agree to the processing of Personal data',
                            style: TextStyle(
                              color: scheme.foreground.withValues(alpha: 0.85),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.45),
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
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              onPressed: _loading ? null : () => _signUp(),
                              child: _loading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Create Account',
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded, size: 20),
                                      ],
                                    ),
                            ),
                          ),
                        ).mobadraFadeSlide(delayMs: 110),
                        const SizedBox(height: 22),
                        Text(
                          'Already a member?',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
                            );
                          },
                          child: const Text(
                            'Sign In to Mobadra',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
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
        },
      ),
    );
  }
}
