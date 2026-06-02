// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';
import '../timer/start_task_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(todayTasksProvider);
    final totalAsync = ref.watch(todayTotalSecondsProvider);
    final activeAsync = ref.watch(activeTaskProvider);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('today'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1EF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                friendlyDate(now),
                style: const TextStyle(fontSize: 13, color: Color(0xFF5F5E5A)),
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
            const Text(
              'tasks',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF888780)),
            ),
            const SizedBox(height: 10),

            tasksAsync.when(
              data: (tasks) => tasks.isEmpty
                  ? const _EmptyState()
                  : Card(
                      child: Column(
                        children: tasks
                            .where((t) => !t.isRunning)
                            .map((t) => _TaskRow(task: t))
                            .toList(),
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('error: $e'),
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
        backgroundColor: const Color(0xFF1D9E75),
        foregroundColor: Colors.white,
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1EF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF888780))),
        ],
      ),
    );
  }
}

class _ActiveTaskBanner extends StatelessWidget {
  final dynamic task;
  const _ActiveTaskBanner({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE1F5EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF9FE1CB), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Color(0xFF1D9E75)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              task.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF085041)),
            ),
          ),
          const Text('running', style: TextStyle(fontSize: 12, color: Color(0xFF0F6E56))),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final dynamic task;
  const _TaskRow({required this.task});

  @override
  Widget build(BuildContext context) {
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
                Text(task.category, style: const TextStyle(fontSize: 12, color: Color(0xFF888780))),
              ],
            ),
          ),
          Text(task.formattedDuration, style: const TextStyle(fontSize: 13, color: Color(0xFF5F5E5A))),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'no tasks yet — tap + to start tracking',
          style: TextStyle(fontSize: 14, color: Color(0xFF888780)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
