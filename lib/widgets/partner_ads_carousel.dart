import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cms/services/api_service.dart';
import 'package:cms/services/auth_service.dart';
import 'package:cms/theme/app_tokens.dart';
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

  static const double _height = 186;

  @override
  void initState() {
    super.initState();
    _load();
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
      _restartAutoAdvance();
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final auth = context.watch<AuthService>();

    if (!auth.isLoggedIn) {
      return SizedBox(
        height: _height,
        child: _FallbackSlide(
          title: 'Member-only offers',
          subtitle: 'Sign in to browse partner discounts and promos',
          gradientColors: [cs.primary, cs.primary.withValues(alpha: 0.75)],
          icon: Icons.lock_outline_rounded,
          onTap: widget.onViewAllOffers,
          cta: 'Sign in',
        ),
      );
    }

    if (_loading) {
      return SizedBox(
        height: _height,
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child:
                  CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
            ),
          ),
        ),
      );
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
                  child: _FallbackSlide(
                    title: 'Could not load offers',
                    subtitle: 'Check your connection, then retry.',
                    gradientColors: [cs.primary, cs.primary.withValues(alpha: 0.75)],
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
                  child: _FallbackSlide(
                    title: 'All partner offers',
                    subtitle: 'Browse discounts, hospital promos & more',
                    gradientColors: [cs.tertiary, cs.primary],
                    icon: Icons.local_offer_rounded,
                    onTap: widget.onViewAllOffers,
                    cta: 'View offers',
                  ),
                );
              }
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _FallbackSlide(
                    title: 'Partner offers & discounts',
                    subtitle: 'New promos appear here when hospitals publish them',
                    gradientColors: [cs.primary, const Color(0xFF2563EB)],
                    icon: Icons.percent_rounded,
                    onTap: widget.onViewAllOffers,
                    cta: 'Browse offers',
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _FallbackSlide(
                  title: 'About Creative Mobadra',
                  subtitle: 'Your member hub for partner hospitals in the UAE',
                  gradientColors: [const Color(0xFF0F766E), cs.primary],
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
                  color: active ? cs.primary : cs.outline.withValues(alpha: 0.35),
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
    final cs = Theme.of(context).colorScheme;
    final title = offer['title']?.toString() ?? 'Partner offer';
    final subtitle = offer['subtitle']?.toString();
    final hospital = offer['hospital'] is Map ? (offer['hospital'] as Map)['name']?.toString() : null;
    final imageUrl = offer['imageUrl']?.toString();

    return PhysicalModel(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      elevation: 8,
      shadowColor: cs.shadow.withValues(alpha: 0.22),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: ColoredBox(
              color: cs.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 11,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (imageUrl != null && imageUrl.isNotEmpty)
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => ColoredBox(color: cs.primaryContainer),
                          )
                        else
                          ColoredBox(
                            color: Color.lerp(cs.primaryContainer, cs.surfaceContainerHighest, 0.4)!,
                          ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: cs.tertiary.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(
                                'Partner deal',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: cs.onSurface,
                                        fontWeight: FontWeight.w800,
                                        height: 1.2,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          if (hospital != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              hospital,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: cs.primary, fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                          ],
                          if (subtitle != null && subtitle.isNotEmpty) ...[
                            SizedBox(height: hospital != null ? 2 : 4),
                            Expanded(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey[700], fontSize: 12, height: 1.25),
                                ),
                              ),
                            ),
                          ] else
                            const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FallbackSlide extends StatelessWidget {
  const _FallbackSlide({
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.icon,
    required this.onTap,
    required this.cta,
  });

  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final IconData icon;
  final VoidCallback onTap;
  final String cta;

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      elevation: 8,
      shadowColor: gradientColors.first.withValues(alpha: 0.26),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 44,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cta,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
