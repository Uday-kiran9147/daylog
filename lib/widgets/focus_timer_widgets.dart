// lib/widgets/focus_timer_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/soundscape_provider.dart';
import '../services/soundscape_service.dart';
import '../utils/constants.dart';
import 'soundscape_sheet.dart';

/// Animated radial aura that gently breathes around the focus timer to reinforce flow state.
class RadialBreathingAura extends StatefulWidget {
  final Widget child;
  final bool isPaused;
  final double size;

  const RadialBreathingAura({
    super.key,
    required this.child,
    required this.isPaused,
    this.size = 260,
  });

  @override
  State<RadialBreathingAura> createState() => _RadialBreathingAuraState();
}

class _RadialBreathingAuraState extends State<RadialBreathingAura>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // 4-second breathing cycle
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _opacityAnimation = Tween<double>(begin: 0.25, end: 0.55).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    if (!widget.isPaused) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant RadialBreathingAura oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPaused != oldWidget.isPaused) {
      if (widget.isPaused) {
        _controller.stop();
      } else {
        _controller.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? DaylogColors.darkAccent : DaylogColors.accent;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Breathing Glow Rings
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final scale = widget.isPaused ? 1.0 : _scaleAnimation.value;
              final opacity = widget.isPaused ? 0.15 : _opacityAnimation.value;

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: opacity * 0.4),
                        blurRadius: 36,
                        spreadRadius: 8,
                      ),
                      BoxShadow(
                        color: (isDark ? Colors.black : Colors.white)
                            .withValues(alpha: 0.2),
                        blurRadius: 16,
                      ),
                    ],
                    border: Border.all(
                      color: accentColor.withValues(alpha: opacity * 0.5),
                      width: 1.5,
                    ),
                  ),
                ),
              );
            },
          ),

          // Central Timer Widget
          widget.child,
        ],
      ),
    );
  }
}

/// Sleek Audio Control Dock embedded directly into the Focus Timer view.
class AmbientAudioDock extends ConsumerWidget {
  const AmbientAudioDock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final soundState = ref.watch(soundscapeProvider);
    final notifier = ref.read(soundscapeProvider.notifier);
    final isPlaying = soundState.isPlaying;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1B18).withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isPlaying
              ? (isDark ? DaylogColors.darkAccent.withValues(alpha: 0.4) : DaylogColors.accent.withValues(alpha: 0.35))
              : (isDark ? Colors.white12 : Colors.black12),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause circular button
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              if (soundState.currentTrack == null) {
                notifier.selectTrack(SoundscapeCatalog.gentleRain);
              } else {
                notifier.togglePlayPause();
              }
            },
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isPlaying
                    ? (isDark ? DaylogColors.darkAccent : DaylogColors.accent700)
                    : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                shape: BoxShape.circle,
              ),
              child: isPlaying
                  ? const Icon(Icons.pause_rounded, size: 16, color: Colors.white)
                  : Icon(
                      Icons.play_arrow_rounded,
                      size: 18,
                      color: isDark ? DaylogColors.darkAccent : DaylogColors.accent700,
                    ),
            ),
          ),
          const SizedBox(width: 10),

          // Label & Remaining Pass Time (Tappable to open Sheet)
          InkWell(
            onTap: () => SoundscapeBottomSheet.show(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌧️', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Text(
                    isPlaying ? 'Gentle Rain' : 'Rain Audio',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (soundState.isPassActive) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B8266),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${soundState.remainingPassMinutes}m',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Quick Sheet Launcher Icon
          IconButton(
            onPressed: () => SoundscapeBottomSheet.show(context),
            icon: const Icon(Icons.tune_rounded, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            style: IconButton.styleFrom(
              backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
            ),
          ),
        ],
      ),
    );
  }
}
