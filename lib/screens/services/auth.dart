import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_gate.dart'; // Import your new AuthGate

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({Key? key}) : super(key: key);

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String? _verificationId;
  bool _otpSent = false;
  bool _isLoading = false;

  // --- FIX: Added loading state and robust error handling ---
  Future<void> _sendOTP() async {
    // Add a country code if it's not there. Use your country's code.
    String phoneNumber = '+20${_phoneController.text.trim()}'; // Example for Egypt (+20)

    if (phoneNumber.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // This is for auto-retrieval on some Android devices.
        await _signIn(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _otpSent = true;
          _isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // --- FIX: Added loading state, robust error handling, and navigation ---
  Future<void> _verifyOTP() async {
    if (_verificationId == null || _otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: _otpController.text.trim(),
    );

    await _signIn(credential);
  }

  // --- NEW: A reusable sign-in function to keep code DRY ---
  Future<void> _signIn(PhoneAuthCredential credential) async {
    try {
      await _auth.signInWithCredential(credential);

      // When sign-in is successful, navigate to the AuthGate.
      // The AuthGate will see the user is logged in and show the HomeScreen.
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGate()),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle wrong OTP or other errors
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _otpSent ? _buildOtpForm() : _buildPhoneForm(),
        ),
      ),
    );
  }

  Widget _buildPhoneForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Enter Your Phone Number', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('We will send you a one-time password (OTP)', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixText: '+20 ', // Example for Egypt
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(onPressed: _sendOTP, child: const Text('Send OTP')),
      ],
    );
  }

  Widget _buildOtpForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Enter Verification Code', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text('A 6-digit code was sent to ${_phoneController.text}', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: 'OTP Code',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(onPressed: _verifyOTP, child: const Text('Verify & Continue')),
        TextButton(
          onPressed: () => setState(() => _otpSent = false),
          child: const Text('Use a different number'),
        ),
      ],
    );
  }
}