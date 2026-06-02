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
    final tasksAsync = ref.watch(todayTasksProvider);
    final totalAsync = ref.watch(todayTotalSecondsProvider);
    final activeAsync = ref.watch(activeTaskProvider);
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
            Row(
              children: [
                const Expanded(
                  child: _TrackedTodayStatBox(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatBox(
                    label: 'Tasks Logged',
                    value: tasksAsync.when(
                      data: (t) => t.where((x) => !x.isRunning).length.toString(),
                      loading: () => '--',
                      error: (_, __) => '--',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // active task banner
            activeAsync.when(
              data: (active) => active != null
                  ? _ActiveTaskBanner(task: active)
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 20),

            // task list
            Text(
              'Tasks',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 10),

            tasksAsync.when(
              data: (tasks) => tasks.isEmpty
                  ? const _EmptyState()
                  : Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: tasks
                            .where((t) => !t.isRunning)
                            .map((t) {
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
                            })
                            .toList(),
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Failed to load tasks: $e',
                    style: TextStyle(color: theme.colorScheme.error, fontSize: 14),
                  ),
                ),
              ),
            ),
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

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ActiveTaskBanner extends StatefulWidget {
  final TaskEntry task;
  const _ActiveTaskBanner({required this.task});

  @override
  State<_ActiveTaskBanner> createState() => _ActiveTaskBannerState();
}

class _ActiveTaskBannerState extends State<_ActiveTaskBanner> with WidgetsBindingObserver {
  Timer? _timer;
  late int _elapsed;

  void _setupTimer() {
    _timer?.cancel();
    _elapsed = widget.task.currentElapsedSeconds;
    if (widget.task.isPaused) {
      _timer = null;
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsed = widget.task.currentElapsedSeconds;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setupTimer();
    }
  }

  @override
  void didUpdateWidget(covariant _ActiveTaskBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id || 
        oldWidget.task.startedAt != widget.task.startedAt || 
        oldWidget.task.isPaused != widget.task.isPaused) {
      _setupTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.task.title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onPrimaryContainer),
                ),
                Text(
                  capitalizeCategory(widget.task.category),
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          Text(
            widget.task.isPaused
                ? 'Paused (${formatTimer(_elapsed)})'
                : 'Running (${formatTimer(_elapsed)})',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onPrimaryContainer),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'No tasks yet — tap + to start tracking',
          style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _TrackedTodayStatBox extends ConsumerStatefulWidget {
  const _TrackedTodayStatBox();

  @override
  ConsumerState<_TrackedTodayStatBox> createState() => _TrackedTodayStatBoxState();
}

class _TrackedTodayStatBoxState extends ConsumerState<_TrackedTodayStatBox> with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimerIfRunning();
  }

  void _startTimerIfRunning() {
    _timer?.cancel();
    final active = ref.read(activeTaskProvider).valueOrNull;
    if (active != null && !active.isPaused) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      _timer = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startTimerIfRunning();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalAsync = ref.watch(todayTotalSecondsProvider);
    final active = ref.watch(activeTaskProvider).valueOrNull;

    ref.listen(activeTaskProvider, (prev, next) {
      _startTimerIfRunning();
    });

    final theme = Theme.of(context);
    final baseSeconds = totalAsync.valueOrNull ?? 0;
    final activeSeconds = active != null ? active.currentElapsedSeconds : 0;
    final totalSeconds = baseSeconds + activeSeconds;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            totalAsync.when(
              data: (_) => formatDuration(totalSeconds),
              loading: () => '--',
              error: (_, __) => '--',
            ),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            'Tracked Today',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
