import 'package:flutter_test/flutter_test.dart';
import 'package:daylog/config/flavor_config.dart';

void main() {
  group('FlavorConfig Tests', () {
    test('dev flavor has correct attributes', () {
      final config = FlavorConfig.dev;
      expect(config.flavor, Flavor.dev);
      expect(config.appTitle, 'DayLog Dev');
      expect(config.envFileName, '.env.dev');
      expect(config.isDev, isTrue);
      expect(config.isProd, isFalse);
    });

    test('prod flavor has correct attributes', () {
      final config = FlavorConfig.prod;
      expect(config.flavor, Flavor.prod);
      expect(config.appTitle, 'DayLog');
      expect(config.envFileName, '.env.prod');
      expect(config.isDev, isFalse);
      expect(config.isProd, isTrue);
    });

    test('default instance falls back to prod when uninitialized', () {
      expect(FlavorConfig.instance.flavor, Flavor.prod);
    });

    test('formattedVersion returns version and build number', () {
      FlavorConfig.appVersion = '1.0.4';
      FlavorConfig.buildNumber = '8';
      expect(FlavorConfig.formattedVersion, 'v1.0.4 (8)');
    });
  });
}
