// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_entry.dart';
import '../../providers/task_provider.dart';
import '../../providers/todo_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/export_service.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';
import '../timer/start_task_sheet.dart';
import '../timer/edit_task_sheet.dart';
import '../../widgets/notion_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final now = DateTime.now();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(todayTasksProvider);
            ref.invalidate(todayTotalSecondsProvider);
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Modern Compact Header
              NotionPageHeader(
                icon: Icons.bolt_rounded,
                title: "Today's Focus Workspace",
                subtitle: friendlyDate(now),
                trailingActions: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        themeMode == ThemeMode.light
                            ? Icons.dark_mode_outlined
                            : themeMode == ThemeMode.dark
                                ? Icons.light_mode_outlined
                                : Icons.brightness_auto_outlined,
                        size: 20,
                      ),
                      tooltip: 'Switch theme',
                      onPressed: () {
                        final next = themeMode == ThemeMode.system
                            ? ThemeMode.light
                            : themeMode == ThemeMode.light
                                ? ThemeMode.dark
                                : ThemeMode.system;
                        ref.read(themeModeProvider.notifier).state = next;
                      },
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'More options',
                      icon: const Icon(Icons.more_vert_rounded, size: 20),
                      onSelected: (value) async {
                        if (value == 'export') {
                          try {
                            await ExportService.exportData();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Data exported successfully!')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Export failed: $e'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        } else if (value == 'import') {
                          try {
                            final result = await ExportService.importData();
                            if (result != null) {
                              ref.invalidate(todayTasksProvider);
                              ref.invalidate(todayTotalSecondsProvider);
                              ref.invalidate(recentTasksProvider);
                              ref.invalidate(todoProvider);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Imported ${result.tasks} tasks, ${result.journals} journals, and ${result.todos} todos!',
                                    ),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Import failed: $e'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'import',
                          child: Row(
                            children: [
                              Icon(Icons.file_download_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Import Data', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'export',
                          child: Row(
                            children: [
                              Icon(Icons.file_upload_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Export Data', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Summary Stats Row
                    Row(
                      children: [
                        Expanded(child: _TrackedTodayStatBox()),
                        SizedBox(width: 12),
                        Expanded(child: _LoggedTasksStatBox()),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Active Focus Card
                    _ActiveTaskSection(),

                    SizedBox(height: 20),

                    // Dynamic non-scrollable category grid board
                    _HomeKanbanBoardSection(),

                    SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const StartTaskSheet(),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Start Session', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _ActiveTaskSection extends ConsumerWidget {
  const _ActiveTaskSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(activeTaskProvider);
    return activeAsync.when(
      data: (active) => active != null
          ? _ActiveTaskBanner(task: active)
          : const _IdleActiveTaskCard(),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ActiveTaskBanner extends ConsumerWidget {
  final TaskEntry task;
  const _ActiveTaskBanner({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appTickerProvider);
    final elapsed = task.currentElapsedSeconds;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: task.isPaused ? theme.colorScheme.error : theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    task.isPaused ? 'PAUSED' : 'LIVE FOCUSING',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              NotionTag(label: capitalizeCategory(task.category), categoryKey: task.category),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            task.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatTimer(elapsed),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: theme.colorScheme.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () {
                      if (task.isPaused) {
                        ref.read(activeTaskProvider.notifier).resumeActive();
                      } else {
                        ref.read(activeTaskProvider.notifier).pauseActive();
                      }
                    },
                    icon: Icon(task.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 22),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => ref.read(activeTaskProvider.notifier).stopActive(),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.errorContainer,
                      foregroundColor: theme.colorScheme.onErrorContainer,
                    ),
                    icon: const Icon(Icons.stop_rounded, size: 22),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IdleActiveTaskCard extends StatelessWidget {
  const _IdleActiveTaskCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.play_circle_outline_rounded, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Active Session',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  'Start a timer block to track your focus.',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const StartTaskSheet(),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Start', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _TrackedTodayStatBox extends ConsumerWidget {
  const _TrackedTodayStatBox();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalAsync = ref.watch(todayTotalSecondsProvider);
    final active = ref.watch(activeTaskProvider).valueOrNull;

    if (active != null) {
      ref.watch(appTickerProvider);
    }

    final baseSeconds = totalAsync.valueOrNull ?? 0;
    final activeSeconds = active != null ? active.currentElapsedSeconds : 0;
    final totalSeconds = baseSeconds + activeSeconds;

    return _StatBox(
      label: 'Tracked Today',
      value: formatDuration(totalSeconds),
      icon: Icons.timer_outlined,
    );
  }
}

class _LoggedTasksStatBox extends ConsumerWidget {
  const _LoggedTasksStatBox();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(todayTasksProvider);
    return _StatBox(
      label: 'Tasks Logged',
      value: tasksAsync.when(
        data: (t) => t.where((x) => !x.isRunning).length.toString(),
        loading: () => '--',
        error: (_, __) => '--',
      ),
      icon: Icons.check_circle_outline_rounded,
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Icon(icon, size: 16, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dynamic, Non-Scrollable Category Grid/Stack for Home Screen
class _HomeKanbanBoardSection extends ConsumerWidget {
  const _HomeKanbanBoardSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(todayTasksProvider);
    final theme = Theme.of(context);

    return tasksAsync.when(
      data: (tasks) {
        final completed = tasks.where((t) => !t.isRunning).toList();
        if (completed.isEmpty) {
          return const _EmptyTasksState();
        }

        // Filter categories that have completed tasks today
        final activeCategories = kCategories.where((cat) {
          return completed.any((t) => t.category == cat);
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Logs by Category',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${completed.length} tasks',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Dynamic layout: Each category card grows dynamically to fit all its tasks!
            LayoutBuilder(
              builder: (context, constraints) {
                final useTwoColumns = constraints.maxWidth > 550;

                if (useTwoColumns) {
                  final leftCats = <String>[];
                  final rightCats = <String>[];
                  for (int i = 0; i < activeCategories.length; i++) {
                    if (i.isEven) {
                      leftCats.add(activeCategories[i]);
                    } else {
                      rightCats.add(activeCategories[i]);
                    }
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: leftCats
                              .map((cat) => _buildCategoryCard(context, cat, completed))
                              .toList(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: rightCats
                              .map((cat) => _buildCategoryCard(context, cat, completed))
                              .toList(),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: activeCategories
                      .map((cat) => _buildCategoryCard(context, cat, completed))
                      .toList(),
                );
              },
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading tasks: $e'),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String cat, List<TaskEntry> completed) {
    final theme = Theme.of(context);
    final catTasks = completed.where((t) => t.category == cat).toList();
    final catTotalSeconds = catTasks.fold<int>(0, (sum, t) => sum + t.durationSeconds);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NotionTag(label: capitalizeCategory(cat), categoryKey: cat),
              Text(
                '${catTasks.length} • ${formatDuration(catTotalSeconds)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: catTasks.map((task) {
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: InkWell(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => EditTaskSheet(task: task),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          task.formattedDuration,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _EmptyTasksState extends StatelessWidget {
  const _EmptyTasksState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.checklist_rounded,
              size: 32,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 10),
            Text(
              'No completed tasks today',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tracked logs will appear here categorized once completed.',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
