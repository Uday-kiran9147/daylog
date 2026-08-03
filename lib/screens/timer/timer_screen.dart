// lib/screens/timer/timer_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_entry.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';
import 'start_task_sheet.dart';
import '../../widgets/notion_widgets.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(activeTaskProvider);
    final recentAsync = ref.watch(recentTasksProvider);
    final theme = Theme.of(context);

    final active = activeAsync.valueOrNull;
    if (active != null) {
      ref.watch(appTickerProvider);
    }

    final elapsed = active != null ? active.currentElapsedSeconds : 0;

    return activeAsync.when(
      data: (active) {
        return Scaffold(
          body: SafeArea(
            top: false,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Compact Header
                const NotionPageHeader(
                  icon: Icons.timer_outlined,
                  title: 'Focus Timer',
                  subtitle: 'Track active focus session and launch quick focus blocks.',
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (active != null) ...[
                        // Running Hero Focus Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
                          ),
                          child: Column(
                            children: [
                              Text(
                                active.title,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              NotionTag(label: capitalizeCategory(active.category), categoryKey: active.category),
                              const SizedBox(height: 24),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  formatTimer(elapsed),
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 64,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    color: theme.colorScheme.onSurface,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _ActionBtn(
                                label: 'Stop Block',
                                icon: Icons.stop_rounded,
                                color: theme.colorScheme.errorContainer,
                                textColor: theme.colorScheme.onErrorContainer,
                                onTap: () => ref.read(activeTaskProvider.notifier).stopActive(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: active.isPaused
                                  ? _ActionBtn(
                                      label: 'Resume',
                                      icon: Icons.play_arrow_rounded,
                                      color: theme.colorScheme.primary,
                                      textColor: Colors.white,
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
                        // Idle Focus Callout
                        NotionCallout(
                          icon: Icons.track_changes_rounded,
                          title: 'No active focus session',
                          subtitle: 'Select a quick-start task below or tap to launch a new session.',
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Center(
                              child: FilledButton.icon(
                                onPressed: () => showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) => const StartTaskSheet(),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text('Start Focus Session', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        'Quick-Start Recent Tasks',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(height: 10),

                      recentAsync.when(
                        data: (tasks) {
                          final unique = <String, TaskEntry>{};
                          for (final t in tasks) {
                            unique.putIfAbsent(t.title, () => t);
                          }
                          if (unique.isEmpty) {
                            return Text(
                              'No recent tasks found.',
                              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                            );
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
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
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
    final theme = Theme.of(context);
    return Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
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
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: categoryColor(task.category), shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(task.title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}
