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

Future<bool?> _showDeleteConfirmDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('delete task?'),
      content: const Text('are you sure you want to delete this task? this action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
          child: const Text('delete'),
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
    final now = DateTime.now();

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('today'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
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
                Expanded(
                  child: _StatBox(
                    label: 'tracked today',
                    value: totalAsync.when(
                      data: (s) => formatDuration(s),
                      loading: () => '--',
                      error: (_, __) => '--',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatBox(
                    label: 'tasks logged',
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
              'tasks',
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
        label: const Text('start new task'),
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

class _ActiveTaskBannerState extends State<_ActiveTaskBanner> {
  Timer? _timer;
  late int _elapsed;

  @override
  void initState() {
    super.initState();
    _elapsed = DateTime.now().difference(widget.task.startedAt).inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsed++;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant _ActiveTaskBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id || oldWidget.task.startedAt != widget.task.startedAt) {
      _timer?.cancel();
      _elapsed = DateTime.now().difference(widget.task.startedAt).inSeconds;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _elapsed++;
          });
        }
      });
    }
  }

  @override
  void dispose() {
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
                  widget.task.category,
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          Text(
            'running (${formatTimer(_elapsed)})',
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
                Text(task.category, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
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
          'no tasks yet — tap + to start tracking',
          style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
