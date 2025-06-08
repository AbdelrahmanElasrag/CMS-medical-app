import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/custom_scaffold.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import 'admin_screen.dart';

class SignInScreen extends StatefulWidget {
  final String? prefillFirstName;
  final String? prefillLastName;
  final String? prefillPhone;
  final String? prefillNationalId;
  final String? prefillInsuranceStatus;

  const SignInScreen({
    super.key,
    this.prefillFirstName,
    this.prefillLastName,
    this.prefillPhone,
    this.prefillNationalId,
    this.prefillInsuranceStatus,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();

  String _verificationId = '';
  bool rememberPassword = false;
  bool isAdminSignIn = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefillPhone != null) {
      phoneController.text = widget.prefillPhone!;
    }
    if (widget.prefillNationalId != null) {
      nationalIdController.text = widget.prefillNationalId!;
    }
  }

  Future<void> saveLoginState(String phone, String nationalId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('phone', phone);
    await prefs.setString('nationalId', nationalId);
  }

  Future<void> _checkNationalId(String phone, String nationalId, BuildContext context) async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .where('nationalId', isEqualTo: nationalId)
        .get();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();

    if (!userDoc.exists) {
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
        'firstName': widget.prefillFirstName ?? '',
        'lastName': widget.prefillLastName ?? '',
        'phone': phone,
        'nationalId': nationalId,
        'insuranceStatus': widget.prefillInsuranceStatus ?? 'Ongoing',
        'points': 0,
        'qrCodeData': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    if (userSnapshot.docs.isNotEmpty) {
      final userData = userSnapshot.docs.first.data();
      if (rememberPassword) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', false);
        await prefs.setString('phone', phone);
        await prefs.setString('nationalId', nationalId);
      }
      if (isAdminSignIn) {
        final adminCollection = await FirebaseFirestore.instance.collection('admin').get();
        String? matchedAdminId;
        for (final doc in adminCollection.docs) {
          final data = doc.data();
          if (data['phone'] == phone && data['nationalId'] == nationalId) {
            matchedAdminId = doc.id;
            break;
          }
        }
        if (matchedAdminId != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminScreen(adminId: matchedAdminId!)),
          );
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not an admin account.')));
          return;
        }
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(username: '${userData['firstName']}', points: userData['points']),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('National ID not matched with phone number.')));
    }
  }

  void _showOTPDialog(BuildContext context, String verificationId, String phone, String nationalId) {
    final TextEditingController otpController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enter OTP'),
        content: TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'OTP Code'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final smsCode = otpController.text.trim();
              final credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
              try {
                await FirebaseAuth.instance.signInWithCredential(credential);
                Navigator.of(context).pop();
                await _checkNationalId(phone, nationalId, context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid OTP')));
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Future<void> _signIn(BuildContext context) async {
    if (!_formSignInKey.currentState!.validate()) return;
    String rawPhone = phoneController.text.trim();
    String nationalId = nationalIdController.text.trim();
    if (!rawPhone.startsWith('+')) {
      rawPhone = '+$rawPhone';
    }
    String phoneNumber = rawPhone;
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          await _checkNationalId(phoneNumber, nationalId, context);
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification failed: ${e.message}')));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _showOTPDialog(context, verificationId, phoneNumber, nationalId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // The CustomScaffold now automatically handles the back button because its
    // AppBar knows that this screen can be popped. No extra code is needed here.
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(flex: 1, child: SizedBox(height: 10)),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Phone Number';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: 'Enter Phone Number',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: nationalIdController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter National ID';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'National ID',
                          hintText: 'Enter National ID',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: rememberPassword,
                            onChanged: (value) {
                              setState(() {
                                rememberPassword = value!;
                              });
                            },
                            activeColor: lightColorScheme.primary,
                          ),
                          const Text('Remember me', style: TextStyle(color: Colors.black45)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: isAdminSignIn,
                            onChanged: (value) {
                              setState(() {
                                isAdminSignIn = value!;
                              });
                            },
                            activeColor: Colors.red,
                          ),
                          const Text('Sign in as admin', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 25.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _signIn(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(color: lightColorScheme.primary),
                          ),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(color: Color(0xFF00c896)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}