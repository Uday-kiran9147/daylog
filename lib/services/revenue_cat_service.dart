// lib/services/revenue_cat_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Configuration for RevenueCat Ad Revenue Attribution.
class RevenueCatConfig {
  RevenueCatConfig._();

  // ──────────────────────────────────────────────────────────────────────────
  // API KEYS FOR AD ATTRIBUTION
  // Loads from .env if present, otherwise falls back to defaults.
  // ──────────────────────────────────────────────────────────────────────────
  static String get androidApiKey =>
      dotenv.env['REVENUECAT_ANDROID_API_KEY'] ?? 'goog_lOUFOBeubFuutVTogLRwzoAvbsJ';

  static String get iosApiKey =>
      dotenv.env['REVENUECAT_IOS_API_KEY'] ?? 'appl_YOUR_REVENUECAT_IOS_API_KEY';
}

/// Lightweight service to configure RevenueCat for Ad Revenue & LTV tracking.
class RevenueCatService {

  RevenueCatService._();
  static final RevenueCatService instance = RevenueCatService._();

  static bool _isInitialized = false;

  /// Returns the appropriate API key for the current platform.
  static String get apiKey {
    if (Platform.isAndroid) {
      return RevenueCatConfig.androidApiKey;
    } else if (Platform.isIOS) {
      return RevenueCatConfig.iosApiKey;
    }
    return '';
  }

  /// Whether RevenueCat is configured and ready to track ad impressions.
  static Future<bool> get isConfigured async {
    try {
      return await Purchases.isConfigured;
    } catch (_) {
      return false;
    }
  }

  /// Initializes RevenueCat Purchases SDK for ad revenue tracking.
  /// Call this at app startup before loading ads.
  static Future<void> init({String? appUserId}) async {
    if (_isInitialized) return;

    final key = apiKey;
    if (key.isEmpty || key.contains('YOUR_REVENUECAT_')) {
      debugPrint('[RevenueCatService] Placeholder API key detected. Ad tracking will be safely bypassed until a valid key is set.');
      return;
    }

    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      } else {
        await Purchases.setLogLevel(LogLevel.warn);
      }

      final configuration = PurchasesConfiguration(key)..appUserID = appUserId;
      await Purchases.configure(configuration);
      _isInitialized = true;
      debugPrint('[RevenueCatService] RevenueCat configured for ad tracking.');
    } catch (e, stackTrace) {
      debugPrint('[RevenueCatService] Failed to initialize RevenueCat: $e\n$stackTrace');
    }
  }
}
