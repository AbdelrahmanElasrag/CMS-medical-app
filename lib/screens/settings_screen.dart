import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'welcome_screen.dart';


// --- IMPORTANT: You must import your welcome/login screen here ---
// For example, if your login screen is signin_screen.dart:
import 'signin_screen.dart';

const String _supportEmail = 'support@example.com';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDeleting = false;

  // --- FIX: The navigation logic is updated here ---
  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isDeleting = true);

    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDoc.delete();
      await user.delete();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        // This is the key change: it destroys the old UI and builds the new one
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const WelcomeScreen(), // Navigate to your sign-in screen
          ),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isDeleting = false);
      String message = 'Failed to delete account.';
      // This handles cases where the user needs to re-authenticate for security
      if (e.code == 'requires-recent-login') {
        message = 'This is a sensitive operation. Please log out and log back in before deleting your account.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() => _isDeleting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- FIX: The navigation logic is also updated here for consistency ---
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      // Use the same robust navigation method here
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(), // Navigate to your sign-in screen
        ),
            (route) => false,
      );
    }
  }


  // --- No changes needed for the other functions below ---

  void _contactSupport() async {
    final Uri emailLaunchUri = Uri(scheme: 'mailto', path: _supportEmail, query: 'subject=CMS App Support');
    try {
      await launchUrl(emailLaunchUri);
    } catch (e) {
      _showCopyEmailDialog();
    }
  }

  void _showCopyEmailDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Could not open your email app. You can copy our support email address and send a message manually.'),
            const SizedBox(height: 16),
            Text(_supportEmail, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: _supportEmail));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email address copied to clipboard!')));
            },
            child: const Text('COPY EMAIL'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE')),
        ],
      ),
    );
  }

  void _shareApp() {
    Share.share('Check out this app: https://placeholder.link');
  }

  void _aboutApp() {
    showAboutDialog(
      context: context,
      applicationName: 'CMS Medical Services',
      applicationVersion: '1.0.0',
      applicationLegalese: 'Developed by MA Devs',
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: _isDeleting ? null : () async {
              Navigator.pop(context);
              await _deleteAccount();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: _isDeleting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(leading: const Icon(Icons.share, color: Color(0xFF00C896)), title: const Text('Share App'), onTap: _shareApp),
          const Divider(),
          ListTile(leading: const Icon(Icons.support_agent, color: Color(0xFF00C896)), title: const Text('Contact Support'), onTap: _contactSupport),
          const Divider(),
          ListTile(leading: const Icon(Icons.info_outline, color: Color(0xFF00C896)), title: const Text('About App'), onTap: _aboutApp),
          const Divider(),
          ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text('Delete Account'), onTap: _showDeleteDialog),
          const Divider(),
          ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Log Out'), onTap: _logout),
          const SizedBox(height: 32),
          Center(child: Text('app version 1.0.0', style: TextStyle(color: Colors.grey[500], fontSize: 14))),
        ],
      ),
    );
  }
}