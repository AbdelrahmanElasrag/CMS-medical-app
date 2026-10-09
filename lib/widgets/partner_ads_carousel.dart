import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cms/services/api_service.dart';
import 'package:cms/services/auth_service.dart';
import 'package:cms/theme/app_tokens.dart';
import 'package:cms/theme/concierge_theme.dart';
import 'package:cms/ui/concierge/membership_access_card.dart';
import 'package:cms/ui/concierge/skeleton_box.dart';
import 'package:cms/ui/offer_sheet.dart';

/// Auto-advancing carousel for partner offers / promos on the home screen.
class PartnerAdsCarousel extends StatefulWidget {
  const PartnerAdsCarousel({
    super.key,
    required this.onViewAllOffers,
    required this.onShowAbout,
  });

  final VoidCallback onViewAllOffers;
  final VoidCallback onShowAbout;

  @override
  State<PartnerAdsCarousel> createState() => _PartnerAdsCarouselState();
}

class _PartnerAdsCarouselState extends State<PartnerAdsCarousel> {
  final PageController _pageController = PageController(viewportFraction: 1);
  List<Map<String, dynamic>> _offers = [];
  bool _loading = true;
  String? _error;
  int _page = 0;
  Timer? _autoTimer;

  static const double _height = 168;

  bool? _trackedSignIn;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = context.watch<AuthService>().isLoggedIn;
    if (_trackedSignIn != signedIn) {
      final previous = _trackedSignIn;
      _trackedSignIn = signedIn;
      if (previous != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _load();
        });
      }
    }
    return _buildCarousel(context, signedIn);
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    if (!auth.isLoggedIn) {
      if (!mounted) return;
      setState(() {
        _offers = const [];
        _loading = false;
        _error = null;
      });
      _autoTimer?.cancel();
      return;
    }

    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final res = await ApiService.instance.getJson('/mobile/offers');
      final data = res['data'];
      final list = data != null && data['offers'] != null
          ? List<Map<String, dynamic>>.from(
              (data['offers'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
            )
          : <Map<String, dynamic>>[];
      if (!mounted) return;
      setState(() {
        _offers = list;
        _loading = false;
        _error = null;
      });
      _restartAutoAdvance();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (e is ApiException && e.statusCode == 401) {
          _error = 'Please sign in to view offers.';
        } else {
          _error = e.toString();
        }
      });
      _restartAutoAdvance();
    }
  }

  int get _slideCount {
    if (_loading) return 1;
    if (_error != null && _offers.isEmpty) return 1;
    if (_offers.isNotEmpty) return _offers.length + 1;
    return 2;
  }

  void _restartAutoAdvance() {
    _autoTimer?.cancel();
    if (_slideCount <= 1) return;
    _autoTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_page + 1) % _slideCount;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Widget _buildCarousel(BuildContext context, bool signedIn) {
    if (!signedIn) {
      return const MembershipAccessCard();
    }

    if (_loading) {
      return const SkeletonBox(height: 148, radius: AppRadii.lg);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _slideCount,
            onPageChanged: (i) {
              setState(() => _page = i);
            },
            itemBuilder: (context, index) {
              if (_error != null && _offers.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _QuietSlide(
                    title: 'Could not load offers',
                    subtitle: 'Check your connection, then retry.',
                    icon: Icons.wifi_off_outlined,
                    onTap: _load,
                    cta: 'Retry',
                  ),
                );
              }
              if (_offers.isNotEmpty) {
                if (index < _offers.length) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _OfferSlide(
                      offer: _offers[index],
                      onTap: () => showOfferDetailSheet(context, _offers[index]),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _QuietSlide(
                    title: 'All partner offers',
                    subtitle: 'Browse discounts and hospital privileges.',
                    icon: Icons.local_offer_outlined,
                    onTap: widget.onViewAllOffers,
                    cta: 'View offers',
                  ),
                );
              }
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _QuietSlide(
                    title: 'Partner offers',
                    subtitle: 'New privileges appear here when hospitals publish them.',
                    icon: Icons.local_offer_outlined,
                    onTap: widget.onViewAllOffers,
                    cta: 'Browse offers',
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _QuietSlide(
                  title: 'About Creative Mobadra',
                  subtitle: 'Your member service for partner hospitals in the UAE.',
                  icon: Icons.info_outline_rounded,
                  onTap: widget.onShowAbout,
                  cta: 'Learn more',
                ),
              );
            },
          ),
        ),
        if (_slideCount > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slideCount, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  color: active ? ConciergePalette.emerald(context) : ConciergePalette.line(context),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _OfferSlide extends StatelessWidget {
  const _OfferSlide({required this.offer, required this.onTap});

  final Map<String, dynamic> offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = ConciergePalette.ink(context);
    final muted = ConciergePalette.muted(context);
    final title = offer['title']?.toString() ?? 'Partner offer';
    final subtitle = offer['subtitle']?.toString();
    final hospital = offer['hospital'] is Map ? (offer['hospital'] as Map)['name']?.toString() : null;
    final imageUrl = offer['imageUrl']?.toString();

    return _FillCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: ConciergePalette.emeraldWash(context),
                      child: Center(
                        child: Icon(Icons.local_hospital_outlined, color: ConciergePalette.emerald(context)),
                      ),
                    ),
                  )
                else
                  ColoredBox(
                    color: ConciergePalette.emeraldWash(context),
                    child: Center(
                      child: Icon(Icons.local_hospital_outlined, color: ConciergePalette.emerald(context)),
                    ),
                  ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: ConciergePalette.surface(context),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: ConciergePalette.gold(context).withValues(alpha: 0.7)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      child: Text('Partner', style: ConciergeType.label(ConciergePalette.goldInk(context))),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ConciergeType.title(ink).copyWith(fontSize: 15),
                  ),
                  if (hospital != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      hospital,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ConciergeType.caption(ConciergePalette.emerald(context)).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ConciergeType.caption(muted),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FillCard extends StatelessWidget {
  const _FillCard({
    required this.child,
    required this.onTap,
    this.gold = false,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.lg);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: ConciergePalette.quiet(context),
      ),
      child: Material(
        color: ConciergePalette.surface(context),
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: ConciergePalette.line(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (gold) Container(height: 2, color: ConciergePalette.gold(context)),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuietSlide extends StatelessWidget {
  const _QuietSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.cta,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final String cta;

  @override
  Widget build(BuildContext context) {
    final ink = ConciergePalette.ink(context);
    final muted = ConciergePalette.muted(context);
    final emerald = ConciergePalette.emerald(context);
    return _FillCard(
      onTap: onTap,
      gold: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ConciergePalette.emeraldWash(context),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(icon, size: 20, color: emerald),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: ConciergeType.title(ink)),
                const SizedBox(height: 4),
                Text(subtitle, style: ConciergeType.caption(muted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(cta, style: ConciergeType.caption(emerald).copyWith(fontWeight: FontWeight.w600)),
        ],
        ),
      ),
    );
  }
}
