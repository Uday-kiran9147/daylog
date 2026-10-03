import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/journal_entry.dart';
import '../../providers/journal_provider.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';
import '../../widgets/daylog_widgets.dart';
import '../../widgets/native_ad_card.dart';
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

  String? _lastLoadedKey;
  String? _lastShipped;
  String? _lastBlockers;
  String? _lastImproved;
  String? _lastTomorrow;

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
      final s = _q1.text.trim();
      final b = _q2.text.trim();
      final imp = _q3.text.trim();
      final t = _q4.text.trim();

      _lastShipped = s;
      _lastBlockers = b;
      _lastImproved = imp;
      _lastTomorrow = t;

      await ref.read(journalNotifierProvider.notifier).save(
        shipped: s,
        blockers: b,
        improved: imp,
        tomorrow: t,
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
    final currentKey = dayKey(selectedDate);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Listen to background updates (e.g. from Focus Victory modal)
    ref.listen<AsyncValue<JournalEntry?>>(journalNotifierProvider, (previous, next) {
      final entry = next.valueOrNull;
      if (entry != null && entry.dayKey == currentKey) {
        if (_lastShipped != entry.shipped) {
          _q1.text = entry.shipped;
          _lastShipped = entry.shipped;
        }
        if (_lastBlockers != entry.blockers) {
          _q2.text = entry.blockers;
          _lastBlockers = entry.blockers;
        }
        if (_lastImproved != entry.improved) {
          _q3.text = entry.improved;
          _lastImproved = entry.improved;
        }
        if (_lastTomorrow != entry.tomorrow) {
          _q4.text = entry.tomorrow;
          _lastTomorrow = entry.tomorrow;
        }
      }
    });

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
                  if (_lastLoadedKey != currentKey ||
                      (existing != null && (
                          _lastShipped != existing.shipped ||
                          _lastBlockers != existing.blockers ||
                          _lastImproved != existing.improved ||
                          _lastTomorrow != existing.tomorrow
                      ))) {
                    _q1.text = existing?.shipped ?? '';
                    _q2.text = existing?.blockers ?? '';
                    _q3.text = existing?.improved ?? '';
                    _q4.text = existing?.tomorrow ?? '';

                    _lastLoadedKey = currentKey;
                    _lastShipped = existing?.shipped;
                    _lastBlockers = existing?.blockers;
                    _lastImproved = existing?.improved;
                    _lastTomorrow = existing?.tomorrow;
                  } else if (existing == null && _lastLoadedKey != currentKey) {
                    _q1.clear();
                    _q2.clear();
                    _q3.clear();
                    _q4.clear();
                    _lastLoadedKey = currentKey;
                    _lastShipped = null;
                    _lastBlockers = null;
                    _lastImproved = null;
                    _lastTomorrow = null;
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
                        questionNumber: 1,
                        label: 'What did you accomplish today?',
                        placeholder: 'Shipped work, focus sprints, completed tasks...',
                        controller: _q1,
                      ),
                      const SizedBox(height: 16),

                      _QuestionField(
                        questionNumber: 2,
                        label: 'What slowed you down or blocked progress?',
                        placeholder: 'Blockers, distractions, friction points...',
                        controller: _q2,
                      ),
                      const SizedBox(height: 16),

                      _QuestionField(
                        questionNumber: 3,
                        label: 'What did you improve or learn?',
                        placeholder: 'Self-growth, technical insights, workflow tweaks...',
                        controller: _q3,
                      ),
                      const SizedBox(height: 16),

                      _QuestionField(
                        questionNumber: 4,
                        label: 'What is your top priority for tomorrow?',
                        placeholder: 'The single most critical needle-mover...',
                        controller: _q4,
                      ),
                      const SizedBox(height: 24),

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

                      // Curated Native Sponsor Card (Post-reflection moment)
                      const DaylogNativeAdCard(
                        placement: 'journal_screen_footer',
                        title: 'Recommended for Builders',
                        subtitle: 'Curated tools to sharpen your evening review',
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
  final int questionNumber;
  final String label;
  final String placeholder;
  final TextEditingController controller;

  const _QuestionField({
    required this.questionNumber,
    required this.label,
    required this.placeholder,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.85),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header with Q-Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Q$questionNumber',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? DaylogColors.darkAccent : DaylogColors.accent700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Auto-expanding, comfortable multiline text input
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: null, // Auto-expand indefinitely for long reflections & bullet points
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.5, // Generous line spacing for long text readability
              color: theme.colorScheme.onSurface,
              letterSpacing: 0.15,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : const Color(0xFFF9F6F0),
              hintText: placeholder,
              hintStyle: TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? DaylogColors.darkAccent : DaylogColors.accent,
                  width: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
