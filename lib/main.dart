// lib/main.dart
import 'config/flavor_config.dart';
import 'main_common.dart';

/// Default application entry point (defaults to prod flavor).`
void main() {
  mainCommon(FlavorConfig.prod);
}
