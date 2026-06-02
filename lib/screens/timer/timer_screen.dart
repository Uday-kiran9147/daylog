// lib/screens/timer/timer_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_entry.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';
import 'start_task_sheet.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  Timer? _ticker;
  final ValueNotifier<int> _elapsedNotifier = ValueNotifier<int>(0);
  int? _activeTaskId;
  bool? _lastIsPaused;

  @override
  void dispose() {
    _ticker?.cancel();
    _elapsedNotifier.dispose();
    super.dispose();
  }

  void _startTicker(TaskEntry task) {
    _ticker?.cancel();
    _elapsedNotifier.value = task.currentElapsedSeconds;
    if (task.isPaused) {
      _ticker = null;
      return;
    }
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedNotifier.value++;
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  Widget build(BuildContext context) {
    final activeAsync = ref.watch(activeTaskProvider);
    final recentAsync = ref.watch(recentTasksProvider);
    final theme = Theme.of(context);

    return activeAsync.when(
      data: (active) {
        if (active != null) {
          final isPausedChanged = _lastIsPaused != active.isPaused;
          if (_activeTaskId != active.id || isPausedChanged) {
            _activeTaskId = active.id;
            _lastIsPaused = active.isPaused;
            _startTicker(active);
          }
        } else {
          _activeTaskId = null;
          _lastIsPaused = null;
          _stopTicker();
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Timer')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (active != null) ...[
                // running hero
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        active.title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: theme.colorScheme.onPrimaryContainer),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          capitalizeCategory(active.category),
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimaryContainer),
                        ),
                      ),
                      const SizedBox(height: 18),
                      ValueListenableBuilder<int>(
                        valueListenable: _elapsedNotifier,
                        builder: (context, elapsed, _) {
                          return Text(
                            formatTimer(elapsed),
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onPrimaryContainer,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        label: 'Stop',
                        icon: Icons.stop_rounded,
                        color: theme.colorScheme.errorContainer,
                        textColor: theme.colorScheme.onErrorContainer,
                        onTap: () => ref.read(activeTaskProvider.notifier).stopActive(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: active.isPaused
                          ? _ActionBtn(
                              label: 'Resume',
                              icon: Icons.play_arrow_rounded,
                              color: theme.colorScheme.primaryContainer,
                              textColor: theme.colorScheme.onPrimaryContainer,
                              onTap: () => ref.read(activeTaskProvider.notifier).resumeActive(),
                            )
                          : _ActionBtn(
                              label: 'Pause',
                              icon: Icons.pause_rounded,
                              color: theme.colorScheme.surfaceContainer,
                              textColor: theme.colorScheme.onSurfaceVariant,
                              onTap: () => ref.read(activeTaskProvider.notifier).pauseActive(),
                            ),
                    ),
                  ],
                ),
              ] else ...[
                // idle state
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.timer_outlined, size: 48, color: theme.colorScheme.outline),
                      const SizedBox(height: 12),
                      Text('No active task', style: TextStyle(fontSize: 16, color: theme.colorScheme.outline)),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => const StartTaskSheet(),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Start a Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text('Quick-Start Recent', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.outline)),
              const SizedBox(height: 10),

              recentAsync.when(
                data: (tasks) {
                  final unique = <String, TaskEntry>{};
                  for (final t in tasks) {
                    unique.putIfAbsent(t.title, () => t);
                  }
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: unique.values.take(6).map((t) => _RecentChip(task: t)).toList(),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: textColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentChip extends ConsumerWidget {
  final TaskEntry task;
  const _RecentChip({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => ref.read(activeTaskProvider.notifier).startTask(task.title, task.category),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(color: categoryColor(task.category), shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(task.title, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
