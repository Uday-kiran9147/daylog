// lib/widgets/soundscape_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/soundscape_provider.dart';
import '../services/soundscape_service.dart';
import '../utils/constants.dart';
import 'daylog_widgets.dart';

/// Bottom sheet modal for Gentle Rain ambient focus audio with 60-min rewarded ad pass.
class SoundscapeBottomSheet extends ConsumerWidget {
  const SoundscapeBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SoundscapeBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final soundState = ref.watch(soundscapeProvider);
    final notifier = ref.read(soundscapeProvider.notifier);
    const track = SoundscapeCatalog.gentleRain;
    final isPlaying = soundState.isPlaying;
    final isBuffering = soundState.isBuffering;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B18) : const Color(0xFFFAF7F2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.08),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.headphones_rounded,
                      size: 20,
                      color: isDark ? DaylogColors.darkAccent : DaylogColors.accent700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Focus Audio',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Distraction-free ambient rain',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Pass Status Banner (Value Exchange Display)
          _PassStatusCard(
            soundState: soundState,
            onUnlockTapped: () {
              HapticFeedback.selectionClick();
              notifier.unlock60MinPass(
                onRewardGranted: () {
                  showDaylogToast(context, '🎉 +60 Minutes Focus Audio Unlocked!');
                },
                onError: (msg) {
                  showDaylogToast(context, msg);
                },
              );
            },
          ),

          const SizedBox(height: 16),

          // Hero Gentle Rain Player Card
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              if (soundState.currentTrack == null) {
                notifier.selectTrack(track);
              } else {
                notifier.togglePlayPause();
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isPlaying
                    ? (isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100)
                    : (isDark ? const Color(0xFF28231E) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isPlaying
                      ? (isDark ? DaylogColors.darkAccent : DaylogColors.accent)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.10)
                          : Colors.black.withValues(alpha: 0.08)),
                  width: isPlaying ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isPlaying
                        ? (isDark ? DaylogColors.darkAccent : DaylogColors.accent).withValues(alpha: 0.20)
                        : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isDark ? DaylogColors.darkAccent.withValues(alpha: 0.2) : DaylogColors.accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        track.iconEmoji,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              track.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isPlaying
                                    ? (isDark ? DaylogColors.darkAccent : DaylogColors.accent700)
                                    : (isDark ? const Color(0xFF332D2A) : const Color(0xFFE8DFD3)),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                isPlaying ? 'PLAYING' : 'TAP TO PLAY',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: isPlaying ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          track.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.60),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isPlaying
                          ? (isDark ? DaylogColors.darkAccent : DaylogColors.accent700)
                          : (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08)),
                      shape: BoxShape.circle,
                    ),
                    child: isBuffering
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(
                            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 24,
                            color: isPlaying ? Colors.white : theme.colorScheme.onSurface,
                          ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Volume Slider Row
          Row(
            children: [
              Icon(
                Icons.volume_down_rounded,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: isDark ? DaylogColors.darkAccent : DaylogColors.accent,
                    inactiveTrackColor: isDark ? const Color(0xFF332D2A) : const Color(0xFFE8DFD3),
                    thumbColor: isDark ? DaylogColors.darkAccent : DaylogColors.accent,
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: soundState.volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (val) => notifier.setVolume(val),
                  ),
                ),
              ),
              Icon(
                Icons.volume_up_rounded,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dynamic Pass Status Banner with Rewarded Ad Value-Exchange Trigger
class _PassStatusCard extends StatelessWidget {
  final SoundscapeState soundState;
  final VoidCallback onUnlockTapped;

  const _PassStatusCard({
    required this.soundState,
    required this.onUnlockTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (soundState.isPassActive) {
      final remaining = soundState.remainingPassMinutes;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A2B).withValues(alpha: isDark ? 0.6 : 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF5B8266).withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '60-Min Focus Pass Active',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF75A082),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$remaining minutes of ambient rain left',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            TextButton.icon(
              onPressed: onUnlockTapped,
              icon: const Icon(Icons.add_rounded, size: 14),
              label: const Text('+60m', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF75A082),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      );
    }

    if (soundState.isPreviewActive) {
      final remainingSec = soundState.remainingPreviewSeconds;
      final mins = (remainingSec ~/ 60).toString();
      final secs = (remainingSec % 60).toString().padLeft(2, '0');

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF28231E) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? DaylogColors.darkAccent.withValues(alpha: 0.35) : DaylogColors.accent.withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🌧️', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      'Preview: $mins:$secs remaining',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? DaylogColors.darkAccent : DaylogColors.accent700,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Free Trial',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _RewardedUnlockButton(
              onTap: onUnlockTapped,
              isLoading: soundState.isAdLoading,
            ),
          ],
        ),
      );
    }

    // Expired or Not Started
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF28231E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? DaylogColors.darkAccent.withValues(alpha: 0.4) : DaylogColors.accent.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Unlock 60 Minutes of Uninterrupted Rain Audio',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _RewardedUnlockButton(
            onTap: onUnlockTapped,
            isLoading: soundState.isAdLoading,
          ),
        ],
      ),
    );
  }
}

class _RewardedUnlockButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const _RewardedUnlockButton({
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [DaylogColors.darkAccent, const Color(0xFF9E401E)]
                : [DaylogColors.accent, DaylogColors.accent700],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (isDark ? DaylogColors.darkAccent : DaylogColors.accent).withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              const Text(
                'Loading sponsor...',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ] else ...[
              const Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              const Text(
                'Unlock 60 Mins (Watch 15s Sponsor)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Floating Pill widget for the timer screen to toggle soundscapes
class SoundscapeTimerPill extends ConsumerWidget {
  const SoundscapeTimerPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final soundState = ref.watch(soundscapeProvider);

    final isPlaying = soundState.isPlaying;

    return InkWell(
      onTap: () => SoundscapeBottomSheet.show(context),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isPlaying
              ? (isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isPlaying
                ? (isDark ? DaylogColors.darkAccent.withValues(alpha: 0.5) : DaylogColors.accent.withValues(alpha: 0.4))
                : (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08)),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌧️', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 6),
            Text(
              isPlaying ? 'Gentle Rain' : 'Rain Audio',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isPlaying ? FontWeight.bold : FontWeight.w500,
                color: isPlaying
                    ? (isDark ? DaylogColors.darkAccent : DaylogColors.accent700)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.8),
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
                  style: const TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
