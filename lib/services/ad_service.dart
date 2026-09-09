// lib/services/ad_service.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Centralized configuration and controller for Google Mobile Ads & RevenueCat attribution.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  static bool _isInitialized = false;

  // ──────────────────────────────────────────────────────────────────────────
  // AD UNIT CONFIGURATION
  // Replace production IDs with your live AdMob Ad Unit IDs before release.
  // ──────────────────────────────────────────────────────────────────────────

  // Android Ad Unit IDs
  static const String _androidProductionBannerId = 'ca-app-pub-5324145457812943/3408814811';
  static const String _androidProductionInterstitialId = 'ca-app-pub-5324145457812943/6902326943';
  static const String _androidProductionRewardedId = 'ca-app-pub-5324145457812943/7888105552';
  static const String _androidProductionAppOpenId = 'ca-app-pub-5324145457812943/XXXXXXXXXX';

  // iOS Ad Unit IDs
  static const String _iosProductionBannerId = 'ca-app-pub-5324145457812943/XXXXXXXXXX';
  static const String _iosProductionInterstitialId = 'ca-app-pub-5324145457812943/XXXXXXXXXX';
  static const String _iosProductionRewardedId = 'ca-app-pub-5324145457812943/XXXXXXXXXX';
  static const String _iosProductionAppOpenId = 'ca-app-pub-5324145457812943/XXXXXXXXXX';

  // Google Official Test Ad Unit IDs (used automatically in debug mode)
  static const String _androidTestBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _androidTestInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _androidTestRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _androidTestAppOpenId = 'ca-app-pub-3940256099942544/9257395921';

  static const String _iosTestBannerId = 'ca-app-pub-3940256099942544/2934735716';
  static const String _iosTestInterstitialId = 'ca-app-pub-3940256099942544/4411468910';
  static const String _iosTestRewardedId = 'ca-app-pub-3940256099942544/1712485313';
  static const String _iosTestAppOpenId = 'ca-app-pub-3940256099942544/5662855259';

  /// Returns the appropriate Banner Ad Unit ID based on platform and build mode.
  static String get bannerAdUnitId {
    if (kDebugMode) {
      return Platform.isIOS ? _iosTestBannerId : _androidTestBannerId;
    }
    return Platform.isIOS ? _iosProductionBannerId : _androidProductionBannerId;
  }

  /// Returns the appropriate Interstitial Ad Unit ID based on platform and build mode.
  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return Platform.isIOS ? _iosTestInterstitialId : _androidTestInterstitialId;
    }
    return Platform.isIOS ? _iosProductionInterstitialId : _androidProductionInterstitialId;
  }

  /// Returns the appropriate Rewarded Ad Unit ID based on platform and build mode.
  static String get rewardedAdUnitId {
    if (kDebugMode) {
      return Platform.isIOS ? _iosTestRewardedId : _androidTestRewardedId;
    }
    return Platform.isIOS ? _iosProductionRewardedId : _androidProductionRewardedId;
  }

  /// Returns the appropriate App Open Ad Unit ID based on platform and build mode.
  static String get appOpenAdUnitId {
    if (kDebugMode) {
      return Platform.isIOS ? _iosTestAppOpenId : _androidTestAppOpenId;
    }
    return Platform.isIOS ? _iosProductionAppOpenId : _androidProductionAppOpenId;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // INITIALIZATION
  // ──────────────────────────────────────────────────────────────────────────

  /// Initialize Mobile Ads SDK and start preloading full-screen ads.
  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('[AdService] Google Mobile Ads initialized.');
      // Preload initial interstitial & rewarded ads in background
      instance.preloadInterstitialAd(placement: 'app_start');
      instance.preloadRewardedAd(placement: 'app_start');
    } catch (e) {
      debugPrint('[AdService] Failed to initialize Google Mobile Ads: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // BANNER AD CREATION
  // ──────────────────────────────────────────────────────────────────────────

  /// Creates and loads an adaptive BannerAd instance with RevenueCat tracking.
  BannerAd createBannerAd({
    required String placement,
    required AdSize size,
    required void Function(BannerAd ad) onAdLoaded,
    void Function(LoadAdError error)? onAdFailedToLoad,
  }) {
    final adUnitId = bannerAdUnitId;
    final bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('[AdService] Banner loaded for placement: $placement');
          _trackAdLoaded(
            ad: ad,
            adFormat: AdFormat.banner,
            placement: placement,
            adUnitId: adUnitId,
          );
          onAdLoaded(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[AdService] Banner failed to load ($placement): $error');
          ad.dispose();
          onAdFailedToLoad?.call(error);
        },
        onAdOpened: (ad) {
          _trackAdDisplayed(
            ad: ad,
            adFormat: AdFormat.banner,
            placement: placement,
            adUnitId: adUnitId,
          );
        },
      ),
    );

    unawaited(bannerAd.load());
    return bannerAd;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // INTERSTITIAL ADS
  // ──────────────────────────────────────────────────────────────────────────

  InterstitialAd? _cachedInterstitialAd;
  bool _isInterstitialLoading = false;

  /// Preloads an interstitial ad into cache if not already available.
  void preloadInterstitialAd({String placement = 'default_interstitial'}) {
    if (_cachedInterstitialAd != null || _isInterstitialLoading) return;
    _isInterstitialLoading = true;

    final adUnitId = interstitialAdUnitId;
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdService] Interstitial ad preloaded for: $placement');
          _cachedInterstitialAd = ad;
          _isInterstitialLoading = false;
          _trackAdLoaded(
            ad: ad,
            adFormat: AdFormat.interstitial,
            placement: placement,
            adUnitId: adUnitId,
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] Interstitial ad failed to preload: $error');
          _cachedInterstitialAd = null;
          _isInterstitialLoading = false;
        },
      ),
    );
  }

  /// Shows the cached interstitial ad. Preloads a new ad once closed.
  void showInterstitialAd({
    String placement = 'default_interstitial',
    VoidCallback? onDismissed,
  }) {
    if (_cachedInterstitialAd == null) {
      debugPrint('[AdService] Interstitial ad not ready. Preloading for next time.');
      preloadInterstitialAd(placement: placement);
      onDismissed?.call();
      return;
    }

    final ad = _cachedInterstitialAd!;
    final adUnitId = interstitialAdUnitId;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[AdService] Interstitial ad displayed ($placement)');
        _trackAdDisplayed(
          ad: ad,
          adFormat: AdFormat.interstitial,
          placement: placement,
          adUnitId: adUnitId,
        );
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdService] Interstitial ad dismissed.');
        ad.dispose();
        _cachedInterstitialAd = null;
        onDismissed?.call();
        // Preload next interstitial ad
        preloadInterstitialAd(placement: placement);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] Interstitial ad failed to show: $error');
        ad.dispose();
        _cachedInterstitialAd = null;
        onDismissed?.call();
        // Preload next interstitial ad
        preloadInterstitialAd(placement: placement);
      },
    );

    ad.show();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // REWARDED ADS
  // ──────────────────────────────────────────────────────────────────────────

  RewardedAd? _cachedRewardedAd;
  bool _isRewardedLoading = false;

  /// Preloads a rewarded video ad into cache if not already available.
  void preloadRewardedAd({String placement = 'default_rewarded'}) {
    if (_cachedRewardedAd != null || _isRewardedLoading) return;
    _isRewardedLoading = true;

    final adUnitId = rewardedAdUnitId;
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdService] Rewarded ad preloaded for: $placement');
          _cachedRewardedAd = ad;
          _isRewardedLoading = false;
          _trackAdLoaded(
            ad: ad,
            adFormat: AdFormat.rewarded,
            placement: placement,
            adUnitId: adUnitId,
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] Rewarded ad failed to preload: $error');
          _cachedRewardedAd = null;
          _isRewardedLoading = false;
        },
      ),
    );
  }

  /// Shows the cached rewarded ad. Calls [onUserEarnedReward] when the user completes watching.
  void showRewardedAd({
    String placement = 'default_rewarded',
    required void Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onDismissed,
    VoidCallback? onAdNotReady,
  }) {
    if (_cachedRewardedAd == null) {
      debugPrint('[AdService] Rewarded ad not ready.');
      preloadRewardedAd(placement: placement);
      onAdNotReady?.call();
      return;
    }

    final ad = _cachedRewardedAd!;
    final adUnitId = rewardedAdUnitId;
    bool userEarnedReward = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[AdService] Rewarded ad displayed ($placement)');
        _trackAdDisplayed(
          ad: ad,
          adFormat: AdFormat.rewarded,
          placement: placement,
          adUnitId: adUnitId,
        );
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdService] Rewarded ad dismissed. Reward earned: $userEarnedReward');
        ad.dispose();
        _cachedRewardedAd = null;
        onDismissed?.call();
        // Preload next rewarded ad
        preloadRewardedAd(placement: placement);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] Rewarded ad failed to show: $error');
        ad.dispose();
        _cachedRewardedAd = null;
        onDismissed?.call();
        // Preload next rewarded ad
        preloadRewardedAd(placement: placement);
      },
    );

    ad.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        userEarnedReward = true;
        onUserEarnedReward(reward);
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // REVENUECAT ATTRIBUTION HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  void _trackAdLoaded({
    required Ad ad,
    required AdFormat adFormat,
    required String placement,
    required String adUnitId,
  }) {
    try {
      final impressionId = ad.responseInfo?.responseId ?? DateTime.now().millisecondsSinceEpoch.toString();
      Purchases.adTracker.trackAdLoaded(
        AdLoadedData(
          networkName: 'Google Ads',
          mediatorName: AdMediatorName.adMob,
          adFormat: adFormat,
          placement: placement,
          adUnitId: adUnitId,
          impressionId: impressionId,
        ),
      );
    } catch (e) {
      debugPrint('[AdService] Purchases ad load tracking notice: $e');
    }
  }

  void _trackAdDisplayed({
    required Ad ad,
    required AdFormat adFormat,
    required String placement,
    required String adUnitId,
  }) {
    try {
      final impressionId = ad.responseInfo?.responseId ?? DateTime.now().millisecondsSinceEpoch.toString();
      Purchases.adTracker.trackAdDisplayed(
        AdDisplayedData(
          networkName: 'Google Ads',
          mediatorName: AdMediatorName.adMob,
          adFormat: adFormat,
          placement: placement,
          adUnitId: adUnitId,
          impressionId: impressionId,
        ),
      );
    } catch (e) {
      debugPrint('[AdService] Purchases ad display tracking notice: $e');
    }
  }
}
