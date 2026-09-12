// lib/screens/timer/timer_fullscreen_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_entry.dart';
import '../../providers/task_provider.dart';
import '../../services/ad_service.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';
import '../../widgets/daylog_widgets.dart';

class TimerFullscreenModal extends ConsumerWidget {
  final TaskEntry task;
  final VoidCallback onMinimize;

  const TimerFullscreenModal({
    super.key,
    required this.task,
    required this.onMinimize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!task.isPaused) {
      ref.watch(appTickerProvider);
    }
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final elapsed = task.currentElapsedSeconds;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) onMinimize();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Minimize Arrow Button
              IconButton(
                onPressed: onMinimize,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 30,
                  color: theme.colorScheme.onSurface,
                ),
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(40, 40),
                ),
              ),

              const Spacer(flex: 1),

              // Center Content: Category Tag, Task Title, Big Clock, Live State
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CategoryTag(category: task.category, isDark: isDark),
                    const SizedBox(height: 18),
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatTimer(elapsed),
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: theme.colorScheme.onSurface,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PulsingDot(
                          color: theme.colorScheme.primary,
                          size: 7,
                          isPaused: task.isPaused,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          task.isPaused ? 'Paused' : 'Focusing',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Bottom Action Buttons: Pause/Resume + Stop
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (task.isPaused) {
                          ref.read(activeTaskProvider.notifier).resumeActive();
                        } else {
                          ref.read(activeTaskProvider.notifier).pauseActive();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        backgroundColor: theme.cardTheme.color,
                        foregroundColor: theme.colorScheme.onSurface,
                      ),
                      icon: Icon(
                        task.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                        size: 20,
                      ),
                      label: Text(
                        task.isPaused ? 'Resume' : 'Pause',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        await ref.read(activeTaskProvider.notifier).stopActive();
                        onMinimize();
                        AdService.instance.showInterstitialAd(placement: 'timer_complete');
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: isDark ? DaylogColors.darkAccent700 : DaylogColors.accent700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                      icon: const Icon(Icons.stop_rounded, size: 20),
                      label: const Text(
                        'Stop',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
