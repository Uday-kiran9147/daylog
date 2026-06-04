// lib/screens/home/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_entry.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';
import '../timer/start_task_sheet.dart';
import '../timer/edit_task_sheet.dart';
import '../../providers/theme_provider.dart';
import '../../services/export_service.dart';

Future<bool?> _showDeleteConfirmDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Task?'),
      content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final now = DateTime.now();

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.light
                  ? Icons.dark_mode_outlined
                  : themeMode == ThemeMode.dark
                      ? Icons.light_mode_outlined
                      : Icons.brightness_auto_outlined,
            ),
            tooltip: 'switch theme',
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
            icon: const Icon(Icons.more_vert_rounded),
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
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Imported ${result.tasks} new tasks and ${result.journals} journals successfully!',
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
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_download_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Import Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_upload_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                friendlyDate(now),
                style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayTasksProvider);
          ref.invalidate(todayTotalSecondsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // stat row
            const Row(
              children: [
                Expanded(
                  child: _TrackedTodayStatBox(),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _LoggedTasksStatBox(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // active task banner / dashboard (self-contained to prevent full screen rebuilds)
            const _ActiveTaskSection(),

            const SizedBox(height: 20),

            // task list
            Text(
              'Completed Today',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 10),

            const _CompletedTasksSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const StartTaskSheet(),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Start New Task'),
      ),
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
    );
  }
}

class _CompletedTasksSection extends ConsumerStatefulWidget {
  const _CompletedTasksSection();

  @override
  ConsumerState<_CompletedTasksSection> createState() => _CompletedTasksSectionState();
}

class _CompletedTasksSectionState extends ConsumerState<_CompletedTasksSection> {
  final Set<int> _dismissedIds = {};

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(todayTasksProvider);
    final theme = Theme.of(context);

    return tasksAsync.when(
      data: (tasks) {
        final completed = tasks
            .where((t) => !t.isRunning && !_dismissedIds.contains(t.id))
            .toList();
        return completed.isEmpty
            ? const _EmptyState()
            : Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: completed.map((t) {
                    return Dismissible(
                      key: ValueKey(t.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: theme.colorScheme.errorContainer,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: Icon(Icons.delete, color: theme.colorScheme.onErrorContainer),
                      ),
                      confirmDismiss: (_) => _showDeleteConfirmDialog(context),
                      onDismissed: (_) {
                        setState(() {
                          _dismissedIds.add(t.id);
                        });
                        ref.read(activeTaskProvider.notifier).deleteTask(t.id);
                      },
                      child: InkWell(
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => EditTaskSheet(task: t),
                        ),
                        child: _TaskRow(task: t),
                      ),
                    );
                  }).toList(),
                ),
              );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Failed to load tasks: $e',
            style: TextStyle(color: theme.colorScheme.error, fontSize: 14),
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

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
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Icon(
                Icons.check_circle_outline_rounded,
                size: 16,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
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
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
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
                    task.isPaused ? 'PAUSED' : 'TRACKING FOCUS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
                ),
                child: Text(
                  capitalizeCategory(task.category),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            task.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatTimer(elapsed),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: theme.colorScheme.onPrimaryContainer,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Row(
                children: [
                  Material(
                    color: theme.colorScheme.surface,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () {
                        if (task.isPaused) {
                          ref.read(activeTaskProvider.notifier).resumeActive();
                        } else {
                          ref.read(activeTaskProvider.notifier).pauseActive();
                        }
                      },
                      customBorder: const CircleBorder(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          task.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                          size: 24,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: theme.colorScheme.errorContainer,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => ref.read(activeTaskProvider.notifier).stopActive(),
                      customBorder: const CircleBorder(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.stop_rounded,
                          size: 24,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
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
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(
            Icons.rocket_launch_outlined,
            size: 32,
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            'Ready to focus?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start a task block to begin tracking your work.',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const StartTaskSheet(),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Start Focus Session', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final TaskEntry task;
  const _TaskRow({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: categoryColor(task.category),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Text(capitalizeCategory(task.category), style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Text(task.formattedDuration, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(32),
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
              size: 36,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
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
              'Tracked logs will appear here once completed.',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
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

    final theme = Theme.of(context);
    final baseSeconds = totalAsync.valueOrNull ?? 0;
    final activeSeconds = active != null ? active.currentElapsedSeconds : 0;
    final totalSeconds = baseSeconds + activeSeconds;

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
                totalAsync.when(
                  data: (_) => formatDuration(totalSeconds),
                  loading: () => '--',
                  error: (_, __) => '--',
                ),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tracked Today',
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
