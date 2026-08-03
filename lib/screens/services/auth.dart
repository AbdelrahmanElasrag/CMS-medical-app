import 'package:flutter/material.dart';
import '../signin_screen.dart';

/// Legacy screen kept for routing compatibility.
/// Firebase phone auth was removed; this now forwards to the app's API login.
class PhoneAuthScreen extends StatelessWidget {
  const PhoneAuthScreen({super.key});

  @override
  Widget build(BuildContext context) => const SignInScreen();
}