import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cms/widgets/custom_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cms/theme/theme.dart';
import 'package:cms/screens/home_screen.dart';
import 'package:cms/screens/signin_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String dropdownValue = 'Ongoing';
  final _formSignupKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nationalIDController = TextEditingController();
  bool agreePersonalData = true;

  // Save User Data to Firestore without OTP or verification
  Future<void> _saveUserDataToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Handle the case when user is not logged in (shouldn't happen if phone auth is set up properly)
      return;
    }

    final userId = user.uid;

    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'nationalId': _nationalIDController.text.trim(),
      'insuranceStatus': dropdownValue,
      'points': 0,
      'qrCodeData': userId, // Store the UID for QR code
      'createdAt': FieldValue.serverTimestamp(),
    });
  }


  // Navigate to Home Screen after saving data
  void _goToHomeScreen(String firstName) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(username: firstName, points: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 40.0),

                      // First Name
                      TextFormField(
                        controller: _firstNameController,
                        validator:
                            (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter First name'
                            : null,
                        decoration: _inputDecoration(
                          'First Name',
                          'Enter First Name',
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // Last Name
                      TextFormField(
                        controller: _lastNameController,
                        validator:
                            (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter Last Name'
                            : null,
                        decoration: _inputDecoration(
                          'Last Name',
                          'Enter Last Name',
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // Phone Number
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator:
                            (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter Phone Number'
                            : null,
                        decoration: _inputDecoration(
                          'Phone Number',
                          'Enter Phone Number (e.g. +971...)',
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // National ID
                      TextFormField(
                        controller: _nationalIDController,
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator:
                            (value) =>
                        value == null || value.isEmpty
                            ? 'Please Enter National ID'
                            : null,
                        decoration: _inputDecoration(
                          'National ID',
                          'Enter National ID',
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // Dropdown for Insurance Status
                      DropdownButtonFormField<String>(
                        value: dropdownValue,
                        iconEnabledColor: Colors.black26,
                        decoration: _inputDecoration(
                          'Insurance Status',
                          'Select Status',
                        ).copyWith(
                          prefixIcon: const Icon(
                            Icons.menu,
                            color: Colors.black26,
                          ),
                        ),
                        onChanged: (String? newValue) {
                          setState(() => dropdownValue = newValue!);
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'Ongoing',
                            child: Text('Ongoing'),
                          ),
                          DropdownMenuItem(
                            value: 'Expired',
                            child: Text('Expired'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),

                      // Agreement Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: agreePersonalData,
                            onChanged:
                                (bool? value) =>
                                setState(() => agreePersonalData = value!),
                            activeColor: lightColorScheme.primary,
                          ),
                          const Text(
                            'I agree to the processing of ',
                            style: TextStyle(color: Colors.black45),
                          ),
                          Text(
                            'Personal data',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: lightColorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formSignupKey.currentState!.validate() &&
                                agreePersonalData) {
                              // Check if user already exists by phone or national ID
                              final existingUsers = await FirebaseFirestore.instance
                                  .collection('users')
                                  .where('phone', isEqualTo: _phoneController.text.trim())
                                  .get();
                              final existingNationalId = await FirebaseFirestore.instance
                                  .collection('users')
                                  .where('nationalId', isEqualTo: _nationalIDController.text.trim())
                                  .get();
                              if (existingUsers.docs.isNotEmpty || existingNationalId.docs.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('A user with this phone or national ID already exists.')),
                                );
                                return;
                              }
                              // Navigate to Sign In screen with pre-filled data
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignInScreen(
                                    prefillFirstName: _firstNameController.text.trim(),
                                    prefillLastName: _lastNameController.text.trim(),
                                    prefillPhone: _phoneController.text.trim(),
                                    prefillNationalId: _nationalIDController.text.trim(),
                                    prefillInsuranceStatus: dropdownValue,
                                  ),
                                ),
                              );
                            } else if (!agreePersonalData) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please agree to the processing of personal data'),
                                ),
                              );
                            }
                          },
                          child: const Text("Sign Up"),
                        ),
                      ),
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

  // Helper function for input field decoration
  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      label: Text(label),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black26),
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
