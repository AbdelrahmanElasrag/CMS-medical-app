import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cms/services/api_service.dart';
import 'package:cms/services/auth_service.dart';
import 'package:cms/screens/signin_screen.dart';
import 'package:cms/theme/app_tokens.dart';
import 'package:cms/ui/mobadra_ui.dart';
import 'package:cms/ui/offer_sheet.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _offers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    if (!auth.isLoggedIn) {
      if (mounted) {
        setState(() {
          _offers = const [];
          _loading = false;
          _error = null;
        });
      }
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.instance.getJson('/mobile/offers');
      final data = res['data'];
      final list = data != null && data['offers'] != null
          ? List<Map<String, dynamic>>.from(
              (data['offers'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
            )
          : <Map<String, dynamic>>[];
      if (mounted) {
        setState(() {
          _offers = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e is ApiException && e.statusCode == 401) {
            _error = 'Please sign in to view partner offers.';
          } else {
            _error = e.toString();
          }
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final auth = context.watch<AuthService>();

    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: const MobadraAppBar(title: Text('Partner offers')),
        body: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 40),
            Icon(Icons.lock_outline_rounded, size: 56, color: cs.outline),
            const SizedBox(height: 16),
            const Text(
              'Sign in to view offers',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Partner discounts are available to members. Sign in to browse current promos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.outline, height: 1.35),
            ),
            const SizedBox(height: 18),
            ShadButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
              ),
              child: const Text('Sign in'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: const MobadraAppBar(title: Text('Partner offers')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ShadButton(onPressed: _load, child: const Text('Retry')),
                          ],
                        ),
                      ),
                    ],
                  )
                : _offers.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          Icon(Icons.local_offer_outlined, size: 56, color: Colors.grey),
                          SizedBox(height: 16),
                          Center(child: Text('No active offers right now. Pull to refresh.')),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: _offers.length,
                        itemBuilder: (context, i) {
                          final o = _offers[i];
                          final title = o['title']?.toString() ?? 'Offer';
                          final subtitle = o['subtitle']?.toString();
                          final hospital = o['hospital'] is Map ? (o['hospital'] as Map)['name']?.toString() : null;
                          final imageUrl = o['imageUrl']?.toString();
                          return mobadraStagger(
                            i,
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ShadCard(
                                child: InkWell(
                              onTap: () => showOfferDetailSheet(context, o),
                              borderRadius: BorderRadius.circular(AppRadii.lg),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (imageUrl != null && imageUrl.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(AppRadii.md),
                                        child: Image.network(
                                          imageUrl,
                                          width: 88,
                                          height: 88,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 88,
                                            height: 88,
                                            color: cs.surfaceContainerHighest,
                                            child: Icon(Icons.image_not_supported, color: cs.outline),
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        width: 88,
                                        height: 88,
                                        decoration: BoxDecoration(
                                          color: cs.tertiaryContainer,
                                          borderRadius: BorderRadius.circular(AppRadii.md),
                                        ),
                                        child: Icon(Icons.local_offer, color: cs.tertiary, size: 36),
                                      ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          if (hospital != null)
                                            Text(hospital, style: TextStyle(color: cs.primary, fontSize: 13)),
                                          if (subtitle != null && subtitle.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 6),
                                              child: Text(
                                                subtitle,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.chevron_right, color: cs.outline),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                        },
                      ),
      ),
    );
  }
}
