import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/flavor_config.dart';
import 'daynote/screens/daynote_screen.dart';
import 'providers/theme_provider.dart';
import 'services/ad_service.dart';
import 'utils/constants.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);
final showTimerFullProvider = StateProvider<bool>((ref) => false);
final appInitErrorProvider = StateProvider<String?>((ref) => null);

class DayLogApp extends ConsumerStatefulWidget {
  const DayLogApp({super.key});

  @override
  ConsumerState<DayLogApp> createState() => _DayLogAppState();
}

class _DayLogAppState extends ConsumerState<DayLogApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: _onAppResume,
    );
  }

  void _onAppResume() {
    AdService.instance.showAppOpenAdIfAvailable();
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final initError = ref.watch(appInitErrorProvider);
    final appTitle = FlavorConfig.instance.appTitle;

    if (initError != null) {
      return MaterialApp(
        title: '$appTitle - Error',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to initialize $appTitle',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      initError,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: appTitle,
      theme: kLightTheme,
      darkTheme: kDarkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: FlavorConfig.instance.isDev,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: isDark ? DaylogColors.darkBg : DaylogColors.lightBg,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const DayNoteScreen(),
    );
  }
}
