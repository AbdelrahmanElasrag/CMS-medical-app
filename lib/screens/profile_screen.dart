import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'family_member.dart';
import 'family_provider.dart';
import 'package:cms/services/auth_service.dart';
import 'package:cms/services/api_service.dart';
import 'package:cms/theme/app_tokens.dart';
import 'package:cms/ui/mobadra_ui.dart';
import 'package:cms/ui/vip_membership_card.dart';
import 'booking_history_screen.dart';
import 'settings_screen.dart';
import 'wellness_screen.dart';
import 'help_screen.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final int points;

  const ProfileScreen({
    required this.username,
    required this.points,
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loadingFamily = true;
  bool _isLoadingImage = true;
  File? _profileImage;
  String? _profileImageUrl;
  bool _loadingPatientQr = false;
  String? _patientQrData;
  String? _patientQrError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = Provider.of<AuthService>(context, listen: false);
      if (!auth.isLoggedIn) {
        setState(() {
          _loadingFamily = false;
          _isLoadingImage = false;
        });
        return;
      }
      _loadFamily();
      _loadProfileImage();
      _loadPatientQr();
    });
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasGuest = oldWidget.username == 'Guest';
    final isGuest = widget.username == 'Guest';
    if (wasGuest && !isGuest) {
      _loadFamily();
      _loadProfileImage();
      _loadPatientQr();
    }
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
      setState(() => _isLoadingImage = true);
      final res = await ApiService.instance.getJson('/mobile/patient/me');
      final data = res['data'];
      if (data != null && data['patient'] != null) {
        final patient = data['patient'] as Map<String, dynamic>;
        final url = patient['profileImageUrl'] as String?;
        if (mounted) setState(() => _profileImageUrl = url);
      }
    } catch (e) {
      if (mounted) setState(() => _profileImageUrl = null);
    } finally {
      if (mounted) setState(() => _isLoadingImage = false);
    }
  }

  Future<void> _loadPatientQr() async {
    if (!mounted) return;
    setState(() {
      _loadingPatientQr = true;
      _patientQrError = null;
    });
    try {
      final res = await ApiService.instance.getJson('/mobile/patient/qr-code');
      final data = res['data'];
      final qrCodeData = data != null ? data['qrCodeData'] as String? : null;
      if (!mounted) return;
      setState(() {
        _patientQrData = qrCodeData;
        _patientQrError = qrCodeData == null ? 'Could not load QR code' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _patientQrData = null;
        _patientQrError = 'Failed to load QR code';
      });
    } finally {
      if (mounted) setState(() => _loadingPatientQr = false);
    }
  }

  void _showImagePickerOptions() {
    mobadraToast(context, 'Profile image upload not available yet');
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => ShadDialog.alert(
            title: const Text('Log Out'),
            description: const Text('Are you sure you want to log out?'),
            actions: [
              ShadButton.outline(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ShadButton.destructive(
                onPressed: () async {
                  Navigator.pop(context);
                  await _performLogout();
                },
                child: const Text('Log Out'),
              ),
            ],
          ),
    );
  }

  Future<void> _performLogout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final familyProvider = Provider.of<FamilyProvider>(context, listen: false);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const Center(child: CircularProgressIndicator()),
      );

      await authService.logout();
      familyProvider.selectMember(null);

      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully logged out'),
          backgroundColor: AppColors.primary,
        ),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
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
    final auth = context.watch<AuthService>();
    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: const MobadraAppBar(title: Text('My Profile')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.person_outline,
                size: 64,
                color: AppColors.primary.withValues(alpha: 0.65),
              ),
              const SizedBox(height: 20),
              Text(
                'Sign in to unlock your profile',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text(
                'Book visits, view your QR, track points, and manage family members once you have an account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.4,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),
              ShadButton(
                onPressed: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const SignupScreen(),
                    ),
                  );
                },
                child: const Text('Create account'),
              ),
              const SizedBox(height: 12),
              ShadButton.outline(
                onPressed: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const SignInScreen(),
                    ),
                  );
                },
                child: const Text('Sign in'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const MobadraAppBar(title: Text('My Profile')),
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
                        onTap: _isLoadingImage ? null : _showImagePickerOptions,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.primaryContainer,
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
                                        color: AppColors.primary,
                                      )
                                      : null,
                            ),
                            if (_isLoadingImage)
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
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
                            if (!_isLoadingImage)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
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
                  SizedBox(height: 10),
                  VipMembershipCard(
                    titleName: widget.username,
                    tierLabel: 'VIP Member',
                    points: widget.points,
                    qrData: _patientQrData,
                    isLoadingQr: _loadingPatientQr,
                    qrErrorMessage: _patientQrError,
                    onRetryQr: _loadPatientQr,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white.withValues(alpha: 0.35),
                      child: Icon(
                        Icons.verified_rounded,
                        size: 18,
                        color: const Color(0xFF1B1407).withValues(alpha: 0.82),
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
                    child: Text(
                      'Add New',
                      style: TextStyle(color: AppColors.primary),
                    ),
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
              title: 'Wellness',
              icon: Icons.favorite_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WellnessScreen(),
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
                  MaterialPageRoute(builder: (context) => HelpCenterScreen()),
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
        leading: Icon(icon, color: AppColors.primary),
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
      color: isSelected ? AppColors.primaryContainer : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
          child: Icon(
            _getRelationshipIcon(member.relationship),
            color: AppColors.primary,
          ),
        ),
        title: Text('${member.firstName} ${member.lastName}'),
        subtitle: Text('${member.relationship} • ${member.phoneNumber}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.qr_code, color: AppColors.primary),
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
                    final newMember = FamilyMember(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
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
                  backgroundColor: AppColors.primary,
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
                        // TODO: FamilyProvider.updateFamilyMember(FamilyMember(...))
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

  void _showFamilyMemberQRCodeDialog(
    BuildContext context,
    FamilyMember member,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                VipMembershipCard(
                  titleName: '${member.firstName} ${member.lastName}',
                  tierLabel: member.relationship,
                  points: 0,
                  qrData: member.id,
                  onTap: () => Navigator.pop(sheetContext),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black.withValues(alpha: 0.25),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
