// lib/screens/timer/timer_fullscreen_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_entry.dart';
import '../../providers/soundscape_provider.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';
import '../../widgets/daylog_widgets.dart';
import '../../widgets/focus_timer_widgets.dart';
import '../../widgets/focus_victory_modal.dart';
import '../../widgets/soundscape_sheet.dart';

class TimerFullscreenModal extends ConsumerStatefulWidget {
  final TaskEntry task;
  final VoidCallback onMinimize;

  const TimerFullscreenModal({
    super.key,
    required this.task,
    required this.onMinimize,
  });

  @override
  ConsumerState<TimerFullscreenModal> createState() => _TimerFullscreenModalState();
}

class _TimerFullscreenModalState extends ConsumerState<TimerFullscreenModal> {
  bool _isZenMode = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.task.isPaused) {
      ref.watch(appTickerProvider);
    }
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark || _isZenMode;
    final elapsed = widget.task.currentElapsedSeconds;

    final backgroundColor = _isZenMode
        ? const Color(0xFF0C0A09)
        : theme.scaffoldBackgroundColor;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (_isZenMode) {
            setState(() => _isZenMode = false);
          } else {
            widget.onMinimize();
          }
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxHeight < 680;
              final auraSize = (constraints.maxHeight * 0.30)
                  .clamp(140.0, 230.0)
                  .clamp(0.0, constraints.maxWidth * 0.68);

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Column(
                        children: [
                          // Top Bar: Minimize + Zen Toggle + Rain Pill
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (_isZenMode) {
                                    setState(() => _isZenMode = false);
                                  } else {
                                    widget.onMinimize();
                                  }
                                },
                                icon: Icon(
                                  _isZenMode ? Icons.fullscreen_exit_rounded : Icons.keyboard_arrow_down_rounded,
                                  size: 28,
                                  color: _isZenMode ? Colors.white70 : theme.colorScheme.onSurface,
                                ),
                                style: IconButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(40, 40),
                                ),
                              ),
                              Wrap(
                                spacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  // Zen Mode Button
                                  InkWell(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() => _isZenMode = !_isZenMode);
                                    },
                                    borderRadius: BorderRadius.circular(999),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _isZenMode
                                            ? DaylogColors.darkAccent.withValues(alpha: 0.25)
                                            : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(
                                          color: _isZenMode
                                              ? DaylogColors.darkAccent
                                              : (isDark ? Colors.white12 : Colors.black12),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _isZenMode ? Icons.visibility_off_rounded : Icons.visibility_outlined,
                                            size: 14,
                                            color: _isZenMode ? DaylogColors.darkAccent : theme.colorScheme.onSurface,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Zen',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              color: _isZenMode ? DaylogColors.darkAccent : theme.colorScheme.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SoundscapeTimerPill(),
                                ],
                              ),
                            ],
                          ),

                          const Spacer(flex: 1),

                          // Central Radial Breathing Clock & Task Details
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CategoryTag(category: widget.task.category, isDark: isDark),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    widget.task.title,
                                    style: TextStyle(
                                      fontSize: isCompact ? 17 : 21,
                                      fontWeight: FontWeight.bold,
                                      color: _isZenMode ? Colors.white : theme.colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Radial Breathing Glow Aura around Clock
                                RadialBreathingAura(
                                  isPaused: widget.task.isPaused,
                                  size: auraSize,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          formatTimer(elapsed),
                                          style: TextStyle(
                                            fontSize: isCompact ? 46 : 56,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                            color: _isZenMode ? Colors.white : theme.colorScheme.onSurface,
                                            fontFeatures: const [FontFeature.tabularFigures()],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          PulsingDot(
                                            color: _isZenMode ? DaylogColors.darkAccent : theme.colorScheme.primary,
                                            size: 7,
                                            isPaused: widget.task.isPaused,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            widget.task.isPaused ? 'Paused' : 'Focusing',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _isZenMode
                                                  ? Colors.white70
                                                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // Streamlined Ambient Audio Capsule Dock
                                const AmbientAudioDock(),
                              ],
                            ),
                          ),

                          const Spacer(flex: 1),

                          // Bottom Action Buttons: Pause/Resume + Stop (Victory Modal on Stop)
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    HapticFeedback.selectionClick();
                                    if (widget.task.isPaused) {
                                      ref.read(activeTaskProvider.notifier).resumeActive();
                                    } else {
                                      ref.read(activeTaskProvider.notifier).pauseActive();
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    side: BorderSide(
                                      color: _isZenMode
                                          ? Colors.white24
                                          : theme.colorScheme.outlineVariant,
                                      width: 1.0,
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                    backgroundColor: _isZenMode ? const Color(0xFF1E1B18) : theme.cardTheme.color,
                                    foregroundColor: _isZenMode ? Colors.white : theme.colorScheme.onSurface,
                                  ),
                                  icon: Icon(
                                    widget.task.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                    size: 19,
                                  ),
                                  label: Text(
                                    widget.task.isPaused ? 'Resume' : 'Pause',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () async {
                                    HapticFeedback.mediumImpact();
                                    final completedSec = widget.task.currentElapsedSeconds;
                                    final taskToLog = widget.task;

                                    await ref.read(activeTaskProvider.notifier).stopActive();
                                    ref.read(soundscapeProvider.notifier).stop();

                                    if (context.mounted) {
                                      await FocusVictoryModal.show(
                                        context,
                                        task: taskToLog,
                                        completedSeconds: completedSec,
                                        onDismiss: widget.onMinimize,
                                      );
                                    }
                                  },
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    backgroundColor: isDark ? DaylogColors.darkAccent700 : DaylogColors.accent700,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                  ),
                                  icon: const Icon(Icons.stop_rounded, size: 19),
                                  label: const Text(
                                    'Stop',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
