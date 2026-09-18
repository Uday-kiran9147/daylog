// test/ad_service_test.dart
import 'package:daylog/services/ad_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdService Policy Constants (AdMob Checklist)', () {
    test('Interstitial & Rewarded ads have a 1-hour expiration TTL', () {
      expect(AdService.fullScreenAdTtl, const Duration(hours: 1));
    });

    test('App Open ads have a 4-hour expiration TTL', () {
      expect(AdService.appOpenAdTtl, const Duration(hours: 4));
    });

    test('Default frequency capping cooldowns are defined to prevent ad fatigue', () {
      expect(AdService.defaultInterstitialCooldown, const Duration(minutes: 3));
      expect(AdService.defaultAppOpenCooldown, const Duration(hours: 4));
    });
  });

  group('AdService Expiration Logic (Practice 7: Discard Expired Ads)', () {
    test('null loadedAt is treated as expired', () {
      expect(AdService.isAdExpired(null, AdService.fullScreenAdTtl), isTrue);
      expect(AdService.isAdExpired(null, AdService.appOpenAdTtl), isTrue);
    });

    test('Fresh ads within TTL are not expired', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final loaded30mAgo = now.subtract(const Duration(minutes: 30));

      expect(
        AdService.isAdExpired(loaded30mAgo, AdService.fullScreenAdTtl, now: now),
        isFalse,
      );
      expect(
        AdService.isAdExpired(loaded30mAgo, AdService.appOpenAdTtl, now: now),
        isFalse,
      );
    });

    test('Full-screen ad expires after 1 hour (AdMob policy)', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final loaded59mAgo = now.subtract(const Duration(minutes: 59));
      final loaded61mAgo = now.subtract(const Duration(minutes: 61));

      expect(
        AdService.isAdExpired(loaded59mAgo, AdService.fullScreenAdTtl, now: now),
        isFalse,
      );
      expect(
        AdService.isAdExpired(loaded61mAgo, AdService.fullScreenAdTtl, now: now),
        isTrue,
      );
    });

    test('App Open ad remains valid up to 4 hours, expires after 4 hours', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final loaded3hAgo = now.subtract(const Duration(hours: 3));
      final loaded4h1mAgo = now.subtract(const Duration(hours: 4, minutes: 1));

      // At 3 hours, fullScreen is expired, but appOpen is still fresh
      expect(
        AdService.isAdExpired(loaded3hAgo, AdService.fullScreenAdTtl, now: now),
        isTrue,
      );
      expect(
        AdService.isAdExpired(loaded3hAgo, AdService.appOpenAdTtl, now: now),
        isFalse,
      );

      // Beyond 4 hours, appOpen is expired
      expect(
        AdService.isAdExpired(loaded4h1mAgo, AdService.appOpenAdTtl, now: now),
        isTrue,
      );
    });
  });

  group('AdService Frequency Capping & Cooldown (Practice 7: Frequency Capping)', () {
    test('null lastShownAt means not on cooldown', () {
      expect(AdService.isOnCooldown(null, AdService.defaultInterstitialCooldown), isFalse);
    });

    test('Active cooldown suppresses repeated ad triggers', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final shown1mAgo = now.subtract(const Duration(minutes: 1));
      final shown5mAgo = now.subtract(const Duration(minutes: 5));

      expect(
        AdService.isOnCooldown(shown1mAgo, const Duration(minutes: 3), now: now),
        isTrue,
      );
      expect(
        AdService.isOnCooldown(shown5mAgo, const Duration(minutes: 3), now: now),
        isFalse,
      );
    });
  });

  group('AdService State & Lifecycle Testing', () {
    final adService = AdService.instance;

    setUp(() {
      adService.resetStateForTesting();
    });

    tearDown(() {
      adService.resetStateForTesting();
    });

    test('Initial state: no ads ready and timestamps are empty', () {
      expect(adService.isInterstitialReady, isFalse);
      expect(adService.isRewardedReady, isFalse);
      expect(adService.isAppOpenReady, isFalse);
      expect(adService.isInterstitialExpired, isTrue);
      expect(adService.isRewardedExpired, isTrue);
      expect(adService.isAppOpenExpired, isTrue);
      expect(adService.isShowingFullScreenAd, isFalse);
    });

    test('Timestamp overrides reflect expiration accurately', () {
      final fresh = DateTime.now().subtract(const Duration(minutes: 10));
      final stale = DateTime.now().subtract(const Duration(hours: 2));

      adService.setTimestampsForTesting(
        interstitialLoadedAt: fresh,
        rewardedLoadedAt: stale,
      );

      expect(adService.isInterstitialExpired, isFalse);
      expect(adService.isRewardedExpired, isTrue);
    });

    test('Collapsible Banner AdRequest extras configuration (Practice 2: Collapsible Banners)', () {
      // Standard Banner
      final standardBanner = adService.createBannerAd(
        placement: 'test_standard',
        size: AdSize.banner,
        isCollapsible: false,
        onAdLoaded: (_) {},
      );
      expect(standardBanner.request.extras, isNull);

      // Collapsible Banner (bottom)
      final collapsibleBottom = adService.createBannerAd(
        placement: 'test_collapsible_bottom',
        size: AdSize.banner,
        isCollapsible: true,
        collapsiblePlacement: 'bottom',
        onAdLoaded: (_) {},
      );
      expect(collapsibleBottom.request.extras, {'collapsible': 'bottom'});

      // Collapsible Banner (top)
      final collapsibleTop = adService.createBannerAd(
        placement: 'test_collapsible_top',
        size: AdSize.banner,
        isCollapsible: true,
        collapsiblePlacement: 'top',
        onAdLoaded: (_) {},
      );
      expect(collapsibleTop.request.extras, {'collapsible': 'top'});
    });
  });
}
