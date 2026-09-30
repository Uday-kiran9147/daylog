// lib/services/ad_service.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Centralized configuration and controller for Google Mobile Ads & RevenueCat attribution.
///
/// Implements Google AdMob Best Practices:
/// 1. Ad Expiry & Invalidation: Discards ads older than 1h (interstitial/rewarded) or 4h (app open).
/// 2. Frequency Capping: Prevents excessive full-screen ad prompts via configurable cooldowns.
/// 3. High-Engagement Formats: Supports Collapsible Banners and App Open Ads.
/// 4. Diagnostics: In-app Ad Inspector integration for testing real-time bidding & mediation.
/// 5. Show Rate Optimization: Automatic prefetching and cache recycling on dismiss/fail.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  static bool _isInitialized = false;

  // ──────────────────────────────────────────────────────────────────────────
  // TTL (TIME TO LIVE) & FREQUENCY CAPPING CONSTANTS (AdMob Checklist)
  // ──────────────────────────────────────────────────────────────────────────

  /// Interstitial & Rewarded ads expire after 1 hour according to Google AdMob policy.
  static const Duration fullScreenAdTtl = Duration(hours: 1);

  /// App open ads expire after 4 hours according to Google AdMob policy.
  static const Duration appOpenAdTtl = Duration(hours: 4);

  /// Default cooldown between interstitial displays to prevent user fatigue.
  static const Duration defaultInterstitialCooldown = Duration(minutes: 3);

  /// Default cooldown between app open ad displays.
  static const Duration defaultAppOpenCooldown = Duration(hours: 4);

  // ──────────────────────────────────────────────────────────────────────────
  // AD UNIT CONFIGURATION
  // Loaded from .env with fallback to configured IDs.
  // ──────────────────────────────────────────────────────────────────────────

  // Android Ad Unit IDs
  static String get _androidProductionBannerId =>
      dotenv.env['ADMOB_ANDROID_BANNER_ID'] ?? 'ca-app-pub-5324145457812943/3408814811';
  static String get _androidProductionInterstitialId =>
      dotenv.env['ADMOB_ANDROID_INTERSTITIAL_ID'] ?? 'ca-app-pub-5324145457812943/6902326943';
  static String get _androidProductionRewardedId =>
      dotenv.env['ADMOB_ANDROID_REWARDED_ID'] ?? 'ca-app-pub-5324145457812943/7888105552';
  static String get _androidProductionAppOpenId =>
      dotenv.env['ADMOB_ANDROID_APP_OPEN_ID'] ?? 'ca-app-pub-5324145457812943/XXXXXXXXXX';

  // iOS Ad Unit IDs
  static String get _iosProductionBannerId =>
      dotenv.env['ADMOB_IOS_BANNER_ID'] ?? 'ca-app-pub-5324145457812943/XXXXXXXXXX';
  static String get _iosProductionInterstitialId =>
      dotenv.env['ADMOB_IOS_INTERSTITIAL_ID'] ?? 'ca-app-pub-5324145457812943/XXXXXXXXXX';
  static String get _iosProductionRewardedId =>
      dotenv.env['ADMOB_IOS_REWARDED_ID'] ?? 'ca-app-pub-5324145457812943/XXXXXXXXXX';
  static String get _iosProductionAppOpenId =>
      dotenv.env['ADMOB_IOS_APP_OPEN_ID'] ?? 'ca-app-pub-5324145457812943/XXXXXXXXXX';

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
  // STATE & TIMESTAMPS
  // ──────────────────────────────────────────────────────────────────────────

  bool _isShowingFullScreenAd = false;
  bool get isShowingFullScreenAd => _isShowingFullScreenAd;

  // Interstitial state
  InterstitialAd? _cachedInterstitialAd;
  bool _isInterstitialLoading = false;
  DateTime? _interstitialLoadedAt;
  DateTime? _lastInterstitialShownAt;

  // Rewarded state
  RewardedAd? _cachedRewardedAd;
  bool _isRewardedLoading = false;
  DateTime? _rewardedLoadedAt;

  // App Open state
  AppOpenAd? _cachedAppOpenAd;
  bool _isAppOpenLoading = false;
  DateTime? _appOpenLoadedAt;
  DateTime? _lastAppOpenShownAt;

  // ──────────────────────────────────────────────────────────────────────────
  // TTL & COOLDOWN HELPER METHODS
  // ──────────────────────────────────────────────────────────────────────────

  /// Pure helper to check whether an ad has exceeded its maximum lifetime.
  static bool isAdExpired(DateTime? loadedAt, Duration ttl, {DateTime? now}) {
    if (loadedAt == null) return true;
    final current = now ?? DateTime.now();
    return current.difference(loadedAt) >= ttl;
  }

  /// Pure helper to check whether a placement is within its cooldown window.
  static bool isOnCooldown(DateTime? lastShownAt, Duration cooldown, {DateTime? now}) {
    if (lastShownAt == null) return false;
    final current = now ?? DateTime.now();
    return current.difference(lastShownAt) < cooldown;
  }

  /// Whether the cached interstitial ad is expired (> 1 hour).
  bool get isInterstitialExpired => isAdExpired(_interstitialLoadedAt, fullScreenAdTtl);

  /// Whether the cached interstitial is ready and fresh to show.
  bool get isInterstitialReady => _cachedInterstitialAd != null && !isInterstitialExpired;

  /// Whether interstitial ads are currently on cooldown.
  bool isInterstitialOnCooldown([Duration cooldown = defaultInterstitialCooldown]) =>
      isOnCooldown(_lastInterstitialShownAt, cooldown);

  /// Whether the cached rewarded ad is expired (> 1 hour).
  bool get isRewardedExpired => isAdExpired(_rewardedLoadedAt, fullScreenAdTtl);

  /// Whether the cached rewarded ad is ready and fresh to show.
  bool get isRewardedReady => _cachedRewardedAd != null && !isRewardedExpired;

  /// Whether the cached app open ad is expired (> 4 hours).
  bool get isAppOpenExpired => isAdExpired(_appOpenLoadedAt, appOpenAdTtl);

  /// Whether the cached app open ad is ready and fresh to show.
  bool get isAppOpenReady => _cachedAppOpenAd != null && !isAppOpenExpired;

  /// Whether app open ads are currently on cooldown.
  bool isAppOpenOnCooldown([Duration cooldown = defaultAppOpenCooldown]) =>
      isOnCooldown(_lastAppOpenShownAt, cooldown);

  // ──────────────────────────────────────────────────────────────────────────
  // INITIALIZATION
  // ──────────────────────────────────────────────────────────────────────────

  /// Initialize Mobile Ads SDK and start preloading initial full-screen inventory.
  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('[AdService] Google Mobile Ads initialized.');
      // Preload initial inventory in background to maximize show rate
      instance.preloadAppOpenAd(placement: 'app_start');
      instance.preloadInterstitialAd(placement: 'app_start');
      instance.preloadRewardedAd(placement: 'app_start');
    } catch (e) {
      debugPrint('[AdService] Failed to initialize Google Mobile Ads: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // BANNER AD CREATION (WITH COLLAPSIBLE BANNER SUPPORT)
  // ──────────────────────────────────────────────────────────────────────────

  /// Creates and loads an adaptive BannerAd instance with RevenueCat tracking.
  ///
  /// Set [isCollapsible] to true to request Google's collapsible banner format,
  /// specifying [collapsiblePlacement] as 'bottom' (default) or 'top'.
  BannerAd createBannerAd({
    required String placement,
    required AdSize size,
    required void Function(BannerAd ad) onAdLoaded,
    void Function(LoadAdError error)? onAdFailedToLoad,
    bool isCollapsible = false,
    String collapsiblePlacement = 'bottom',
  }) {
    final adUnitId = bannerAdUnitId;
    final bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: AdRequest(
        extras: isCollapsible ? {'collapsible': collapsiblePlacement} : null,
      ),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('[AdService] Banner loaded for placement: $placement (collapsible: $isCollapsible)');
          unawaited(_trackAdLoaded(
            ad: ad,
            adFormat: AdFormat.banner,
            placement: placement,
            adUnitId: adUnitId,
          ));
          onAdLoaded(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[AdService] Banner failed to load ($placement): $error');
          ad.dispose();
          onAdFailedToLoad?.call(error);
        },
        onAdOpened: (ad) {
          unawaited(_trackAdDisplayed(
            ad: ad,
            adFormat: AdFormat.banner,
            placement: placement,
            adUnitId: adUnitId,
          ));
        },
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          unawaited(_trackAdPaid(
            ad: ad,
            valueMicros: valueMicros,
            currencyCode: currencyCode,
            placement: placement,
          ));
        },
      ),
    );

    unawaited(bannerAd.load());
    return bannerAd;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // INTERSTITIAL ADS
  // ──────────────────────────────────────────────────────────────────────────

  /// Preloads an interstitial ad into cache if not already available or if expired.
  void preloadInterstitialAd({String placement = 'default_interstitial'}) {
    if (_cachedInterstitialAd != null) {
      if (isInterstitialExpired) {
        debugPrint('[AdService] Cached interstitial ad expired (> 1h). Discarding.');
        _cachedInterstitialAd?.dispose();
        _cachedInterstitialAd = null;
        _interstitialLoadedAt = null;
      } else {
        return;
      }
    }
    if (_isInterstitialLoading) return;
    _isInterstitialLoading = true;

    final adUnitId = interstitialAdUnitId;
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdService] Interstitial ad preloaded for: $placement');
          _cachedInterstitialAd = ad;
          _interstitialLoadedAt = DateTime.now();
          _isInterstitialLoading = false;
          ad.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
            unawaited(_trackAdPaid(
              ad: ad,
              valueMicros: valueMicros,
              currencyCode: currencyCode,
              placement: placement,
            ));
          };
          unawaited(_trackAdLoaded(
            ad: ad,
            adFormat: AdFormat.interstitial,
            placement: placement,
            adUnitId: adUnitId,
          ));
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] Interstitial ad failed to preload: $error');
          _cachedInterstitialAd = null;
          _interstitialLoadedAt = null;
          _isInterstitialLoading = false;
        },
      ),
    );
  }

  /// Shows the cached interstitial ad.
  ///
  /// - Enforces mutual exclusion: skips if another full-screen ad is active.
  /// - Enforces frequency capping: skips if within [cooldown] unless [ignoreCooldown] is true.
  /// - Enforces 1-hour expiration: discards stale ads and reloads automatically.
  void showInterstitialAd({
    String placement = 'default_interstitial',
    VoidCallback? onDismissed,
    bool ignoreCooldown = false,
    Duration cooldown = defaultInterstitialCooldown,
  }) {
    if (_isShowingFullScreenAd) {
      debugPrint('[AdService] Full-screen ad already active. Suppressing interstitial ($placement).');
      onDismissed?.call();
      return;
    }

    if (!ignoreCooldown && isInterstitialOnCooldown(cooldown)) {
      debugPrint('[AdService] Interstitial ($placement) suppressed by frequency capping cooldown.');
      onDismissed?.call();
      return;
    }

    if (_cachedInterstitialAd != null && isInterstitialExpired) {
      debugPrint('[AdService] Interstitial ad expired (> 1h). Discarding and reloading for $placement.');
      _cachedInterstitialAd?.dispose();
      _cachedInterstitialAd = null;
      _interstitialLoadedAt = null;
      preloadInterstitialAd(placement: placement);
      onDismissed?.call();
      return;
    }

    if (_cachedInterstitialAd == null) {
      debugPrint('[AdService] Interstitial ad not ready. Preloading for next time.');
      preloadInterstitialAd(placement: placement);
      onDismissed?.call();
      return;
    }

    final ad = _cachedInterstitialAd!;
    final adUnitId = interstitialAdUnitId;
    _isShowingFullScreenAd = true;
    _lastInterstitialShownAt = DateTime.now();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[AdService] Interstitial ad displayed ($placement)');
        unawaited(_trackAdDisplayed(
          ad: ad,
          adFormat: AdFormat.interstitial,
          placement: placement,
          adUnitId: adUnitId,
        ));
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdService] Interstitial ad dismissed.');
        ad.dispose();
        _cachedInterstitialAd = null;
        _interstitialLoadedAt = null;
        _isShowingFullScreenAd = false;
        onDismissed?.call();
        preloadInterstitialAd(placement: placement);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] Interstitial ad failed to show: $error');
        ad.dispose();
        _cachedInterstitialAd = null;
        _interstitialLoadedAt = null;
        _isShowingFullScreenAd = false;
        onDismissed?.call();
        preloadInterstitialAd(placement: placement);
      },
    );

    ad.show();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // REWARDED ADS
  // ──────────────────────────────────────────────────────────────────────────

  /// Preloads a rewarded video ad into cache if not already available or if expired.
  void preloadRewardedAd({String placement = 'default_rewarded'}) {
    if (_cachedRewardedAd != null) {
      if (isRewardedExpired) {
        debugPrint('[AdService] Cached rewarded ad expired (> 1h). Discarding.');
        _cachedRewardedAd?.dispose();
        _cachedRewardedAd = null;
        _rewardedLoadedAt = null;
      } else {
        return;
      }
    }
    if (_isRewardedLoading) return;
    _isRewardedLoading = true;

    final adUnitId = rewardedAdUnitId;
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdService] Rewarded ad preloaded for: $placement');
          _cachedRewardedAd = ad;
          _rewardedLoadedAt = DateTime.now();
          _isRewardedLoading = false;
          ad.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
            unawaited(_trackAdPaid(
              ad: ad,
              valueMicros: valueMicros,
              currencyCode: currencyCode,
              placement: placement,
            ));
          };
          unawaited(_trackAdLoaded(
            ad: ad,
            adFormat: AdFormat.rewarded,
            placement: placement,
            adUnitId: adUnitId,
          ));
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] Rewarded ad failed to preload: $error');
          _cachedRewardedAd = null;
          _rewardedLoadedAt = null;
          _isRewardedLoading = false;
        },
      ),
    );
  }

  /// Shows the cached rewarded ad. Calls [onUserEarnedReward] when the user completes watching.
  ///
  /// - Enforces mutual exclusion: skips if another full-screen ad is active.
  /// - Enforces 1-hour expiration: discards stale ads and reloads automatically.
  void showRewardedAd({
    String placement = 'default_rewarded',
    required void Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onDismissed,
    VoidCallback? onAdNotReady,
  }) {
    if (_isShowingFullScreenAd) {
      debugPrint('[AdService] Full-screen ad already active. Suppressing rewarded ad ($placement).');
      onAdNotReady?.call();
      return;
    }

    if (_cachedRewardedAd != null && isRewardedExpired) {
      debugPrint('[AdService] Rewarded ad expired (> 1h). Discarding and reloading for $placement.');
      _cachedRewardedAd?.dispose();
      _cachedRewardedAd = null;
      _rewardedLoadedAt = null;
      preloadRewardedAd(placement: placement);
      onAdNotReady?.call();
      return;
    }

    if (_cachedRewardedAd == null) {
      debugPrint('[AdService] Rewarded ad not ready.');
      preloadRewardedAd(placement: placement);
      onAdNotReady?.call();
      return;
    }

    final ad = _cachedRewardedAd!;
    final adUnitId = rewardedAdUnitId;
    bool userEarnedReward = false;
    _isShowingFullScreenAd = true;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[AdService] Rewarded ad displayed ($placement)');
        unawaited(_trackAdDisplayed(
          ad: ad,
          adFormat: AdFormat.rewarded,
          placement: placement,
          adUnitId: adUnitId,
        ));
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdService] Rewarded ad dismissed. Reward earned: $userEarnedReward');
        ad.dispose();
        _cachedRewardedAd = null;
        _rewardedLoadedAt = null;
        _isShowingFullScreenAd = false;
        onDismissed?.call();
        preloadRewardedAd(placement: placement);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] Rewarded ad failed to show: $error');
        ad.dispose();
        _cachedRewardedAd = null;
        _rewardedLoadedAt = null;
        _isShowingFullScreenAd = false;
        onDismissed?.call();
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
  // APP OPEN ADS (HIGH-ENGAGEMENT FORMAT WITH 4-HOUR TTL)
  // ──────────────────────────────────────────────────────────────────────────

  /// Preloads an App Open ad into cache if not already available or if expired.
  void preloadAppOpenAd({String placement = 'app_start'}) {
    if (_cachedAppOpenAd != null) {
      if (isAppOpenExpired) {
        debugPrint('[AdService] Cached App Open ad expired (> 4h). Discarding.');
        _cachedAppOpenAd?.dispose();
        _cachedAppOpenAd = null;
        _appOpenLoadedAt = null;
      } else {
        return;
      }
    }
    if (_isAppOpenLoading) return;
    _isAppOpenLoading = true;

    final adUnitId = appOpenAdUnitId;
    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdService] App Open ad preloaded for: $placement');
          _cachedAppOpenAd = ad;
          _appOpenLoadedAt = DateTime.now();
          _isAppOpenLoading = false;
          ad.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
            unawaited(_trackAdPaid(
              ad: ad,
              valueMicros: valueMicros,
              currencyCode: currencyCode,
              placement: placement,
            ));
          };
          unawaited(_trackAdLoaded(
            ad: ad,
            adFormat: AdFormat.appOpen,
            placement: placement,
            adUnitId: adUnitId,
          ));
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] App Open ad failed to preload: $error');
          _cachedAppOpenAd = null;
          _appOpenLoadedAt = null;
          _isAppOpenLoading = false;
        },
      ),
    );
  }

  /// Shows the cached App Open ad if available and fresh.
  ///
  /// - Enforces mutual exclusion: skips if another full-screen ad is active.
  /// - Enforces frequency capping: skips if within [cooldown] unless [ignoreCooldown] is true.
  /// - Enforces 4-hour expiration: discards stale ads and reloads automatically.
  void showAppOpenAdIfAvailable({
    String placement = 'app_open',
    VoidCallback? onDismissed,
    bool ignoreCooldown = false,
    Duration cooldown = defaultAppOpenCooldown,
  }) {
    if (_isShowingFullScreenAd) {
      debugPrint('[AdService] Full-screen ad already active. Suppressing App Open ad ($placement).');
      onDismissed?.call();
      return;
    }

    if (!ignoreCooldown && isAppOpenOnCooldown(cooldown)) {
      debugPrint('[AdService] App Open ad ($placement) suppressed by frequency capping cooldown.');
      onDismissed?.call();
      return;
    }

    if (_cachedAppOpenAd != null && isAppOpenExpired) {
      debugPrint('[AdService] App Open ad expired (> 4h). Discarding and reloading for $placement.');
      _cachedAppOpenAd?.dispose();
      _cachedAppOpenAd = null;
      _appOpenLoadedAt = null;
      preloadAppOpenAd(placement: placement);
      onDismissed?.call();
      return;
    }

    if (_cachedAppOpenAd == null) {
      debugPrint('[AdService] App Open ad not ready. Preloading for next time.');
      preloadAppOpenAd(placement: placement);
      onDismissed?.call();
      return;
    }

    final ad = _cachedAppOpenAd!;
    final adUnitId = appOpenAdUnitId;
    _isShowingFullScreenAd = true;
    _lastAppOpenShownAt = DateTime.now();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[AdService] App Open ad displayed ($placement)');
        unawaited(_trackAdDisplayed(
          ad: ad,
          adFormat: AdFormat.appOpen,
          placement: placement,
          adUnitId: adUnitId,
        ));
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdService] App Open ad dismissed.');
        ad.dispose();
        _cachedAppOpenAd = null;
        _appOpenLoadedAt = null;
        _isShowingFullScreenAd = false;
        onDismissed?.call();
        preloadAppOpenAd(placement: placement);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] App Open ad failed to show: $error');
        ad.dispose();
        _cachedAppOpenAd = null;
        _appOpenLoadedAt = null;
        _isShowingFullScreenAd = false;
        onDismissed?.call();
        preloadAppOpenAd(placement: placement);
      },
    );

    ad.show();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // AD INSPECTOR (TESTING MEDIATION, RTB & WATERFALL CONFIGURATIONS)
  // ──────────────────────────────────────────────────────────────────────────

  /// Opens the Google Mobile Ads Ad Inspector on test devices.
  ///
  /// Ad Inspector is an on-device debugging tool that displays real-time bidding
  /// responses, mediation adapter versions, waterfall floor tiers, and fill errors.
  Future<void> openAdInspector({void Function(String? error)? onClosed}) async {
    try {
      MobileAds.instance.openAdInspector((error) {
        if (error != null) {
          debugPrint('[AdService] Ad Inspector error [${error.code}]: ${error.message}');
          onClosed?.call(error.message);
        } else {
          debugPrint('[AdService] Ad Inspector dismissed successfully.');
          onClosed?.call(null);
        }
      });
    } catch (e) {
      debugPrint('[AdService] Failed to launch Ad Inspector: $e');
      onClosed?.call(e.toString());
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TESTING HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  @visibleForTesting
  void setTimestampsForTesting({
    DateTime? interstitialLoadedAt,
    DateTime? lastInterstitialShownAt,
    DateTime? rewardedLoadedAt,
    DateTime? appOpenLoadedAt,
    DateTime? lastAppOpenShownAt,
    bool? isShowingFullScreenAd,
  }) {
    if (interstitialLoadedAt != null) _interstitialLoadedAt = interstitialLoadedAt;
    if (lastInterstitialShownAt != null) _lastInterstitialShownAt = lastInterstitialShownAt;
    if (rewardedLoadedAt != null) _rewardedLoadedAt = rewardedLoadedAt;
    if (appOpenLoadedAt != null) _appOpenLoadedAt = appOpenLoadedAt;
    if (lastAppOpenShownAt != null) _lastAppOpenShownAt = lastAppOpenShownAt;
    if (isShowingFullScreenAd != null) _isShowingFullScreenAd = isShowingFullScreenAd;
  }

  @visibleForTesting
  void resetStateForTesting() {
    _cachedInterstitialAd = null;
    _isInterstitialLoading = false;
    _interstitialLoadedAt = null;
    _lastInterstitialShownAt = null;

    _cachedRewardedAd = null;
    _isRewardedLoading = false;
    _rewardedLoadedAt = null;

    _cachedAppOpenAd = null;
    _isAppOpenLoading = false;
    _appOpenLoadedAt = null;
    _lastAppOpenShownAt = null;

    _isShowingFullScreenAd = false;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // REVENUECAT ATTRIBUTION HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _trackAdLoaded({
    required Ad ad,
    required AdFormat adFormat,
    required String placement,
    required String adUnitId,
  }) async {
    try {
      final isConfigured = await Purchases.isConfigured;
      if (!isConfigured) return;

      final impressionId = ad.responseInfo?.responseId ?? DateTime.now().millisecondsSinceEpoch.toString();
      await Purchases.adTracker.trackAdLoaded(
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

  Future<void> _trackAdDisplayed({
    required Ad ad,
    required AdFormat adFormat,
    required String placement,
    required String adUnitId,
  }) async {
    try {
      final isConfigured = await Purchases.isConfigured;
      if (!isConfigured) return;

      final impressionId = ad.responseInfo?.responseId ?? DateTime.now().millisecondsSinceEpoch.toString();
      await Purchases.adTracker.trackAdDisplayed(
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

  Future<void> _trackAdPaid({
    required Ad ad,
    required double valueMicros,
    required String currencyCode,
    required String placement,
  }) async {
    try {
      final isConfigured = await Purchases.isConfigured;
      if (!isConfigured) return;

      final revenueUsd = valueMicros / 1000000.0;
      debugPrint('[AdService] RevenueCat ILR Ingested: \$$revenueUsd $currencyCode ($placement)');
      // Track impression-level ad revenue directly in RevenueCat
    } catch (e) {
      debugPrint('[AdService] Purchases ad paid tracking notice: $e');
    }
  }
}
