import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cms/services/auth_service.dart';
import 'package:cms/theme/app_tokens.dart';
import 'package:cms/ui/mobadra_ui.dart';

const String _supportEmail = 'info@creativemultisolutions.com';
const String _privacyPolicyUrl = String.fromEnvironment(
  'PRIVACY_POLICY_URL',
  defaultValue: 'https://www.creativemultisolutions.com/privacy',
);
const String _termsUrl = String.fromEnvironment(
  'TERMS_OF_SERVICE_URL',
  defaultValue: 'https://www.creativemultisolutions.com/terms',
);
const String _dataNoticeUrl = String.fromEnvironment(
  'DATA_COLLECTION_URL',
  defaultValue: 'https://www.creativemultisolutions.com/data-collection',
);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDeleting = false;

  Future<void> _deleteAccount() async {
    setState(() => _isDeleting = true);
    try {
      // Backend does not expose account deletion from app; direct user to support
      if (mounted) {
        mobadraToast(context, 'To delete your account, please contact support.');
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _logout() async {
    await Provider.of<AuthService>(context, listen: false).logout();
    if (mounted) {
      Navigator.of(context).pop();
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

  Future<void> _openLegalUrl(String rawUrl) async {
    final uri = Uri.parse(rawUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      mobadraToast(context, 'Could not open link right now', error: true);
    }
  }

  void _showCopyEmailDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Contact Support'),
        actions: [
          ShadButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: _supportEmail));
              Navigator.pop(context);
              mobadraToast(context, 'Email address copied to clipboard!');
            },
            child: const Text('Copy email'),
          ),
          ShadButton.outline(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Could not open your email app. You can copy our support email address and send a message manually.'),
            const SizedBox(height: 16),
            Text(_supportEmail, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _shareApp() {
    Share.share('Check out this app: https://placeholder.link');
  }

  void _aboutApp() {
    showAboutDialog(
      context: context,
      applicationName: 'Creative Mobadra',
      applicationVersion: '1.0.0',
      applicationLegalese: 'Developed by MA Devs',
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Delete Account'),
        description: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          ShadButton.outline(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ShadButton.destructive(
            onPressed: _isDeleting
                ? null
                : () async {
                    Navigator.pop(context);
                    await _deleteAccount();
                  },
            child: _isDeleting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      appBar: const MobadraAppBar(title: Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(leading: const Icon(Icons.share, color: AppColors.primary), title: const Text('Share App'), onTap: _shareApp),
          const Divider(),
          ListTile(leading: const Icon(Icons.support_agent, color: AppColors.primary), title: const Text('Contact Support'), onTap: _contactSupport),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
            title: const Text('Privacy Policy'),
            onTap: () => _openLegalUrl(_privacyPolicyUrl),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.gavel_outlined, color: AppColors.primary),
            title: const Text('Terms of Service'),
            onTap: () => _openLegalUrl(_termsUrl),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shield_outlined, color: AppColors.primary),
            title: const Text('Data Collection Notice'),
            onTap: () => _openLegalUrl(_dataNoticeUrl),
          ),
          const Divider(),
          ListTile(leading: const Icon(Icons.info_outline, color: AppColors.primary), title: const Text('About App'), onTap: _aboutApp),
          if (auth.isLoggedIn) ...[
            const Divider(),
            ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text('Delete Account'), onTap: _showDeleteDialog),
            const Divider(),
            ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Log Out'), onTap: _logout),
          ],
          const SizedBox(height: 32),
          Center(child: Text('app version 1.0.0', style: TextStyle(color: Colors.grey[500], fontSize: 14))),
        ],
      ),
    );
  }
}