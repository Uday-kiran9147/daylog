// lib/widgets/native_ad_card.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../utils/constants.dart';

/// A Material 3 Terracotta-styled Native Ad Card that seamlessly blends into DayLog's UI.
/// Used at non-disruptive footer locations (Home feed, Insights bottom, Post-reflection).
class DaylogNativeAdCard extends StatefulWidget {
  final String placement;
  final String? title;
  final String? subtitle;

  const DaylogNativeAdCard({
    super.key,
    required this.placement,
    this.title = 'Curated for Builders',
    this.subtitle = 'Tools & resources to sharpen your daily deep work',
  });

  @override
  State<DaylogNativeAdCard> createState() => _DaylogNativeAdCardState();
}

class _DaylogNativeAdCardState extends State<DaylogNativeAdCard> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _bannerAd?.dispose();
      _bannerAd = null;
      _isLoaded = false;

      AdService.instance.createBannerAd(
        placement: widget.placement,
        size: AdSize.banner,
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _bannerAd = ad;
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint('[DaylogNativeAdCard] Ad failed to load (${widget.placement}): $error');
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isLoaded = false;
            });
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B18) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.black.withValues(alpha: 0.08),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row: Sponsored Tag + Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: (isDark ? DaylogColors.darkAccent : DaylogColors.accent).withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      'SPONSOR',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? DaylogColors.darkAccent : DaylogColors.accent700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.title ?? 'Curated for Builders',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ],
          ),

          if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.subtitle!,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Center Ad Banner
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                alignment: Alignment.center,
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
