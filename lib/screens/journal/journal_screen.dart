import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/journal_provider.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';
import '../../widgets/daylog_widgets.dart';
import 'journal_history_screen.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _q1 = TextEditingController();
  final _q2 = TextEditingController();
  final _q3 = TextEditingController();
  final _q4 = TextEditingController();

  DateTime? _lastDate;
  bool _initialized = false;

  @override
  void dispose() {
    _q1.dispose();
    _q2.dispose();
    _q3.dispose();
    _q4.dispose();
    super.dispose();
  }

  Future<void> _save(bool isSaved) async {
    if (_q1.text.trim().isEmpty) return;
    try {
      await ref.read(journalNotifierProvider.notifier).save(
        shipped: _q1.text.trim(),
        blockers: _q2.text.trim(),
        improved: _q3.text.trim(),
        tomorrow: _q4.text.trim(),
      );
      if (mounted) {
        showDaylogToast(context, isSaved ? 'Reflection updated' : 'Reflection saved');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save journal: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedJournalDateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Reset controllers if selected date changed
    if (_lastDate == null || !DateUtils.isSameDay(_lastDate!, selectedDate)) {
      _lastDate = selectedDate;
      _initialized = false;
      _q1.clear();
      _q2.clear();
      _q3.clear();
      _q4.clear();
    }

    final journalAsync = ref.watch(journalNotifierProvider);
    final totalAsync = ref.watch(todayTotalSecondsProvider);
    final active = ref.watch(activeTaskProvider).valueOrNull;

    final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());
    final isFirstDay = selectedDate.isBefore(DateTime.now().subtract(const Duration(days: 365)));

    final dayLabelStr = isToday
        ? 'Today · ${friendlyDate(selectedDate)}'
        : friendlyDate(selectedDate);

    final yesterdayDate = selectedDate.subtract(const Duration(days: 1));
    final yesterdayJournalAsync = ref.watch(journalForDateProvider(dayKey(yesterdayDate)));
    final yesterdayPriority = yesterdayJournalAsync.valueOrNull?.tomorrow;

    final trackedSeconds = isToday
        ? (totalAsync.valueOrNull ?? 0) + (active != null ? active.currentElapsedSeconds : 0)
        : null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Page Header with History Icon
            DaylogPageHeader(
              title: 'Reflection',
              trailing: IconButton(
                icon: const Icon(Icons.auto_stories_outlined, size: 22),
                tooltip: 'Journal History',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const JournalHistoryScreen()),
                ),
              ),
            ),

            // Day Selector Floating Pill Bar (< Day Label >)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.28)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : Colors.white.withValues(alpha: 0.85),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 22),
                      onPressed: isFirstDay
                          ? null
                          : () {
                              HapticFeedback.selectionClick();
                              ref.read(selectedJournalDateProvider.notifier).state =
                                  selectedDate.subtract(const Duration(days: 1));
                            },
                    ),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          ref.read(selectedJournalDateProvider.notifier).state = picked;
                        }
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        child: Text(
                          dayLabelStr,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, size: 22),
                      onPressed: isToday
                          ? null
                          : () {
                              HapticFeedback.selectionClick();
                              ref.read(selectedJournalDateProvider.notifier).state =
                                  selectedDate.add(const Duration(days: 1));
                            },
                    ),
                  ],
                ),
              ),
            ),

            // Journal Form Content
            Expanded(
              child: journalAsync.when(
                data: (existing) {
                  if (existing != null && !_initialized) {
                    _q1.text = existing.shipped;
                    _q2.text = existing.blockers;
                    _q3.text = existing.improved;
                    _q4.text = existing.tomorrow;
                    _initialized = true;
                  } else if (existing == null && !_initialized) {
                    _initialized = true;
                  }

                  final isSaved = existing != null && existing.shipped.isNotEmpty;
                  final displayTrackedSec = isToday
                      ? (trackedSeconds ?? 0)
                      : (existing?.totalTrackedSeconds ?? 0);

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    children: [
                      // Yesterday's Priority Card
                      if (yesterdayPriority != null && yesterdayPriority.trim().isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? DaylogColors.darkAccent.withValues(alpha: 0.45)
                                  : DaylogColors.accent.withValues(alpha: 0.35),
                              width: 1.1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isDark ? DaylogColors.darkAccent : DaylogColors.accent)
                                    .withValues(alpha: isDark ? 0.20 : 0.10),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Yesterday's priority",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? DaylogColors.darkAccent : DaylogColors.accent700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                yesterdayPriority,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Tracked That Day Subtitle Row
                      if (displayTrackedSec > 0) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tracked that day: ${formatDuration(displayTrackedSec)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],

                      // 4 Reflection Questions
                      _QuestionField(
                        label: 'What did you accomplish today?',
                        placeholder: 'Shipped work',
                        controller: _q1,
                      ),
                      const SizedBox(height: 14),

                      _QuestionField(
                        label: 'What slowed you down or blocked progress?',
                        placeholder: 'Blockers',
                        controller: _q2,
                      ),
                      const SizedBox(height: 14),

                      _QuestionField(
                        label: 'What did you improve or learn?',
                        placeholder: 'Self-growth',
                        controller: _q3,
                      ),
                      const SizedBox(height: 14),

                      _QuestionField(
                        label: 'What is your top priority for tomorrow?',
                        placeholder: 'Next day planning',
                        controller: _q4,
                      ),
                      const SizedBox(height: 22),

                      // Save Button
                      FilledButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          _save(isSaved);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: isDark ? DaylogColors.darkAccent : theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: (isDark ? DaylogColors.darkAccent : DaylogColors.accent)
                              .withValues(alpha: 0.35),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Text(
                          isSaved ? 'Update reflection' : 'Save reflection',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;

  const _QuestionField({
    required this.label,
    required this.placeholder,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: 2,
          minLines: 2,
          textCapitalization: TextCapitalization.sentences,
          style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}
