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
  int _elapsed = 0;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker(TaskEntry task) {
    _ticker?.cancel();
    _elapsed = DateTime.now().difference(task.startedAt).inSeconds;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed++);
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

    return activeAsync.when(
      data: (active) {
        if (active != null) {
          _startTicker(active);
        } else {
          _stopTicker();
        }

        return Scaffold(
          appBar: AppBar(title: const Text('timer')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (active != null) ...[
                // running hero
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1F5EE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        active.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF085041)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9FE1CB),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          active.category,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF085041)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        formatTimer(_elapsed),
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF085041),
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        label: 'stop',
                        icon: Icons.stop_rounded,
                        color: const Color(0xFFFCEBEB),
                        textColor: const Color(0xFFA32D2D),
                        onTap: () => ref.read(activeTaskProvider.notifier).stopActive(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionBtn(
                        label: 'pause',
                        icon: Icons.pause_rounded,
                        color: const Color(0xFFF1F1EF),
                        textColor: const Color(0xFF5F5E5A),
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
                      const Icon(Icons.timer_outlined, size: 48, color: Color(0xFF888780)),
                      const SizedBox(height: 12),
                      const Text('no active task', style: TextStyle(fontSize: 16, color: Color(0xFF888780))),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => const StartTaskSheet(),
                        ),
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1D9E75)),
                        icon: const Icon(Icons.add),
                        label: const Text('start a task'),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              const Text('quick-start recent', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF888780))),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
          ],
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
    return GestureDetector(
      onTap: () => ref.read(activeTaskProvider.notifier).startTask(task.title, task.category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1EF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x22000000), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(color: categoryColor(task.category), shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(task.title, style: const TextStyle(fontSize: 13, color: Color(0xFF5F5E5A))),
          ],
        ),
      ),
    );
  }
}
