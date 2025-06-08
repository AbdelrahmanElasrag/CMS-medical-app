import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'family_member.dart';
import 'family_provider.dart';
import '/screens/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/screens/splash_screen.dart';
import 'booking_history_screen.dart';
import 'settings_screen.dart';
import '../theme/theme_provider.dart';
import 'help_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final int points;

  const ProfileScreen({required this.username, required this.points, Key? key})
      : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loadingFamily = true;
  bool _isUploading = false;
  bool _isLoadingImage = true;
  File? _profileImage;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadFamily();
    _loadProfileImage();
  }

  Future<void> _loadFamily() async {
    setState(() => _loadingFamily = true);
    await Provider.of<FamilyProvider>(
      context,
      listen: false,
    ).loadFamilyMembers();
    setState(() => _loadingFamily = false);
  }

  Future<void> _loadProfileImage() async {
    try {
      setState(() {
        _isLoadingImage = true;
      });

      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data['profileImageUrl'] != null) {
          setState(() {
            _profileImageUrl = data['profileImageUrl'];
          });
        }
      }
    } catch (e) {
      print('Error loading profile image: $e');
    } finally {
      setState(() {
        _isLoadingImage = false;
      });
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      setState(() {
        _isUploading = true;
      });

      // Get the current user
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Create a reference to the image location in Firebase Storage
      final storageRef = _storage.ref().child('profile_images/${user.uid}.jpg');

      // Upload the file
      await storageRef.putFile(imageFile);

      // Get the download URL
      final downloadUrl = await storageRef.getDownloadURL();

      // Update the user's profile in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'profileImageUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile image updated successfully'),
          backgroundColor: Color(0xFF00C896),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        setState(() {
          _profileImage = imageFile;
        });
        await _uploadImage(imageFile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _performLogout(context);
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final familyProvider = Provider.of<FamilyProvider>(context, listen: false);

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Perform logout
      await authService.signOut();

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // This will clear all stored data

      // Clear any local data
      familyProvider.selectMember(null);

      // Close loading indicator
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully logged out'),
          backgroundColor: Color(0xFF00C896),
        ),
      );

      // Navigate to welcome screen and clear all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
            (route) => false,
      );
    } catch (e) {
      // Close loading indicator if it's showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Profile'), backgroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              margin: EdgeInsets.all(16),
              child: Column(
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: _isUploading ? null : _showImagePickerOptions,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Color(0xFFE6F3EF),
                              backgroundImage:
                              _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : (_profileImageUrl != null
                                  ? NetworkImage(_profileImageUrl!)
                              as ImageProvider
                                  : null),
                              child:
                              (_profileImage == null &&
                                  _profileImageUrl == null)
                                  ? Icon(
                                Icons.person,
                                size: 50,
                                color: Color(0xFF00C896),
                              )
                                  : null,
                            ),
                            if (_isLoadingImage)
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            if (_isUploading)
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            if (!_isUploading && !_isLoadingImage)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF00C896),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.username,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'VIP Member',
                    style: TextStyle(color: Color(0xFF00C896), fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  // Points display
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFE6F3EF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Color(0xFF00C896)),
                        SizedBox(width: 8),
                        Text(
                          'Your Points: ${widget.points}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  // QR Code Button
                  ElevatedButton.icon(
                    onPressed: () => _showQRCodeDialog(context),
                    icon: Icon(Icons.qr_code, color: Colors.white),
                    label: Text('View QR Code', ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00C896),
                      foregroundColor: Colors.white, // Sets color for text and icon
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Family Members Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Family Members',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => _showAddFamilyMemberDialog(context),
                    child: Text('Add New', style: TextStyle(color: Color(0xFF00C896))),
                  ),
                ],
              ),
            ),

            // Family Members List
            _loadingFamily
                ? Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
                : Consumer<FamilyProvider>(
              builder: (context, provider, child) {
                if (provider.familyMembers.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No family members added yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return Column(
                  children: [
                    ...provider.familyMembers.map(
                          (member) => _buildFamilyMemberCard(
                        context,
                        member,
                        provider.selectedMember?.id == member.id,
                      ),
                    ),
                  ],
                );
              },
            ),

            // Profile Sections
            _buildProfileSection(
              title: 'Booking History',
              icon: Icons.history,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingHistoryScreen(),
                  ),
                );
              },
            ),
            _buildProfileSection(
              title: 'Settings',
              icon: Icons.settings,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
            _buildProfileSection(
              title: 'Help & Support',
              icon: Icons.help_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HelpCenterScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: 20),

            // Logout button
            // In your ProfileScreen's build method:
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () => _showLogoutConfirmation(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Log Out'),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF00C896)),
        title: Text(title),
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFamilyMemberCard(
      BuildContext context,
      FamilyMember member,
      bool isSelected,
      ) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isSelected ? Color(0xFFE6F3EF) : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFF00C896).withOpacity(0.2),
          child: Icon(
            _getRelationshipIcon(member.relationship),
            color: Color(0xFF00C896),
          ),
        ),
        title: Text('${member.firstName} ${member.lastName}'),
        subtitle: Text('${member.relationship} • ${member.phoneNumber}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.qr_code, color: Color(0xFF00C896)),
              onPressed: () => _showFamilyMemberQRCodeDialog(context, member),
              tooltip: 'Show QR Code',
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.grey),
              onPressed: () => _showEditFamilyMemberDialog(context, member),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDeleteMember(context, member),
            ),
          ],
        ),
        onTap: () {
          Provider.of<FamilyProvider>(
            context,
            listen: false,
          ).selectMember(member);
        },
      ),
    );
  }

  IconData _getRelationshipIcon(String relationship) {
    switch (relationship.toLowerCase()) {
      case 'mother':
        return Icons.female;
      case 'father':
        return Icons.male;
      case 'wife':
        return Icons.female;
      case 'husband':
        return Icons.male;
      case 'daughter':
        return Icons.girl;
      case 'son':
        return Icons.boy;
      default:
        return Icons.person;
    }
  }

  void _showAddFamilyMemberDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final relationships = [
      'Mother',
      'Father',
      'Wife',
      'Husband',
      'Daughter',
      'Son',
    ];
    String? selectedRelationship;
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final nationalIdController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text('Add Family Member'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Relationship'),
                  items:
                  relationships
                      .map(
                        (rel) => DropdownMenuItem(
                      value: rel,
                      child: Text(rel),
                    ),
                  )
                      .toList(),
                  onChanged: (value) => selectedRelationship = value,
                  validator: (value) => value == null ? 'Required' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: firstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                  validator:
                      (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                  validator:
                      (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: nationalIdController,
                  decoration: InputDecoration(labelText: 'National ID'),
                  keyboardType: TextInputType.number,
                  validator:
                      (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator:
                      (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'You must be signed in to add a family member.',
                      ),
                    ),
                  );
                  return;
                }
                final familyCollection = FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('family');
                final docRef = await familyCollection.add({
                  'relationship': selectedRelationship!,
                  'firstName': firstNameController.text,
                  'lastName': lastNameController.text,
                  'nationalId': nationalIdController.text,
                  'phoneNumber': phoneController.text,
                  'parentUserId': user.uid,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                final newMember = FamilyMember(
                  id: docRef.id,
                  relationship: selectedRelationship!,
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  nationalId: nationalIdController.text,
                  phoneNumber: phoneController.text,
                );
                Provider.of<FamilyProvider>(
                  context,
                  listen: false,
                ).addFamilyMember(newMember);
                Navigator.pop(context);
                _loadFamily();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00C896),
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditFamilyMemberDialog(BuildContext context, FamilyMember member) {
    final formKey = GlobalKey<FormState>();
    final relationships = [
      'Mother',
      'Father',
      'Wife',
      'Husband',
      'Daughter',
      'Son',
    ];
    String selectedRelationship = member.relationship;
    final firstNameController = TextEditingController(text: member.firstName);
    final lastNameController = TextEditingController(text: member.lastName);
    final nationalIdController = TextEditingController(text: member.nationalId);
    final phoneController = TextEditingController(text: member.phoneNumber);

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Edit Family Member'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedRelationship,
                      decoration: InputDecoration(
                        labelText: 'Relationship',
                      ),
                      items:
                      relationships
                          .map(
                            (rel) => DropdownMenuItem(
                          value: rel,
                          child: Text(rel),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRelationship = value!;
                        });
                      },
                      validator:
                          (value) => value == null ? 'Required' : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: firstNameController,
                      decoration: InputDecoration(labelText: 'First Name'),
                      validator:
                          (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: lastNameController,
                      decoration: InputDecoration(labelText: 'Last Name'),
                      validator:
                          (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: nationalIdController,
                      decoration: InputDecoration(labelText: 'National ID'),
                      keyboardType: TextInputType.number,
                      validator:
                          (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                      ),
                      keyboardType: TextInputType.phone,
                      validator:
                          (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    final updatedMember = FamilyMember(
                      id: member.id,
                      relationship: selectedRelationship,
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      nationalId: nationalIdController.text,
                      phoneNumber: phoneController.text,
                    );

                    // You'll need to add an update method to your FamilyProvider
                    // Provider.of<FamilyProvider>(context, listen: false)
                    //   .updateFamilyMember(updatedMember);

                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child: Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteMember(BuildContext context, FamilyMember member) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text('Delete Family Member?'),
        content: Text(
          'Are you sure you want to remove ${member.firstName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<FamilyProvider>(
                context,
                listen: false,
              ).removeFamilyMember(member.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showQRCodeDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your QR Code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00C896),
                ),
              ),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF00C896),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: user.uid,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'One of our coordinators should scan this for you to enjoy our services',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Color(0xFF00C896),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFamilyMemberQRCodeDialog(
      BuildContext context,
      FamilyMember member,
      ) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Family Member QR Code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00C896),
                ),
              ),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF00C896),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: member.id,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Show this QR code to a coordinator for family member services',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Color(0xFF00C896),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
