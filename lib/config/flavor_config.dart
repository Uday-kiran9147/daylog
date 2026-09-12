// lib/config/flavor_config.dart

/// Supported build and runtime flavors for DayLog.
enum Flavor {
  dev,
  prod,
}

/// Global flavor configuration holder for the app.
class FlavorConfig {
  final Flavor flavor;
  final String appTitle;
  final String envFileName;

  FlavorConfig._({
    required this.flavor,
    required this.appTitle,
    required this.envFileName,
  });

  static const String appVersion = '1.0.4';
  static const String buildNumber = '8';

  static String get formattedVersion => 'v$appVersion ($buildNumber)';

  static FlavorConfig? _instance;

  static FlavorConfig get instance => _instance ?? FlavorConfig.prod;
  static set instance(FlavorConfig config) => _instance = config;

  static final FlavorConfig dev = FlavorConfig._(
    flavor: Flavor.dev,
    appTitle: 'DayLog Dev',
    envFileName: '.env.dev',
  );

  static final FlavorConfig prod = FlavorConfig._(
    flavor: Flavor.prod,
    appTitle: 'DayLog',
    envFileName: '.env.prod',
  );

  bool get isDev => flavor == Flavor.dev;
  bool get isProd => flavor == Flavor.prod;
}
