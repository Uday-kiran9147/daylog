// lib/screens/journal/journal_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/journal_entry.dart';
import '../../providers/journal_provider.dart';
import '../../providers/task_provider.dart';
import '../../utils/date_utils.dart';
import 'journal_history_screen.dart';
import '../../providers/theme_provider.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _q1 = TextEditingController();
  final _q2 = TextEditingController();
  final _q3 = TextEditingController();
  bool _saved = false;
  bool _initialized = false;
  DateTime? _lastProcessedDate;

  @override
  void dispose() {
    _q1.dispose(); _q2.dispose(); _q3.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_q1.text.trim().isEmpty) return;
    try {
      await ref.read(journalNotifierProvider.notifier).save(
        shipped: _q1.text.trim(),
        blockers: _q2.text.trim(),
        tomorrow: _q3.text.trim(),
      );
      if (mounted) {
        setState(() => _saved = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save journal: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedJournalDateProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    // Reset inputs and saved flag when date changes
    if (_lastProcessedDate == null || !DateUtils.isSameDay(_lastProcessedDate!, selectedDate)) {
      _lastProcessedDate = selectedDate;
      _initialized = false;
      _saved = false;
      _q1.clear();
      _q2.clear();
      _q3.clear();
    }

    final journalAsync = ref.watch(journalNotifierProvider);
    final totalAsync = ref.watch(todayTotalSecondsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
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
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'journal history',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JournalHistoryScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const _DateSelectorHeader(),
          Expanded(
            child: journalAsync.when(
              data: (existing) {
                // pre-fill if entry exists and not yet initialized
                if (existing != null && !_initialized) {
                  _q1.text = existing.shipped;
                  _q2.text = existing.blockers;
                  _q3.text = existing.tomorrow;
                  _saved = true;
                  _initialized = true;
                } else if (existing == null && !_initialized) {
                  _initialized = true;
                }

                return _saved
                    ? _SavedView(
                        entry: existing!,
                        onEdit: () => setState(() => _saved = false),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          totalAsync.when(
                            data: (s) => s > 0
                                ? Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainer,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${formatDuration(s)} tracked today',
                                      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                          _QuestionCard(
                            number: '01 / 03',
                            question: 'What did you do today?',
                            controller: _q1,
                            hint: 'Features, fixes, progress…',
                          ),
                          const SizedBox(height: 10),
                          _QuestionCard(
                            number: '02 / 03',
                            question: 'What slowed you down?',
                            controller: _q2,
                            hint: 'Blockers, bugs, distractions…',
                          ),
                          const SizedBox(height: 10),
                          _QuestionCard(
                            number: '03 / 03',
                            question: 'What\'s the priority tomorrow?',
                            controller: _q3,
                            hint: 'Top 1-2 things to tackle…',
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: _save,
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.check, size: 20),
                            label: const Text('Save Journal Entry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSelectorHeader extends ConsumerWidget {
  const _DateSelectorHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedJournalDateProvider);
    final theme = Theme.of(context);
    
    final dateStr = DateUtils.isSameDay(selectedDate, DateTime.now())
        ? 'Today'
        : DateUtils.isSameDay(selectedDate, DateTime.now().subtract(const Duration(days: 1)))
            ? 'Yesterday'
            : friendlyDate(selectedDate);

    final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Previous Day',
            onPressed: () {
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
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_rounded, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down_rounded, color: theme.colorScheme.primary),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Next Day',
            onPressed: isToday
                ? null
                : () {
                    ref.read(selectedJournalDateProvider.notifier).state =
                        selectedDate.add(const Duration(days: 1));
                  },
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String number;
  final String question;
  final TextEditingController controller;
  final String hint;

  const _QuestionCard({
    required this.number,
    required this.question,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
              fillColor: theme.colorScheme.surface,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedView extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onEdit;

  const _SavedView({
    required this.entry,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Journal Logged',
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'You can edit this entry anytime',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (entry.totalTrackedSeconds > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined, size: 12, color: theme.colorScheme.onPrimary),
                      const SizedBox(width: 4),
                      Text(
                        formatDuration(entry.totalTrackedSeconds),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  context,
                  title: '01 / What did you do today?',
                  content: entry.shipped,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1),
                ),
                _buildSection(
                  context,
                  title: '02 / What slowed you down?',
                  content: entry.blockers.isNotEmpty ? entry.blockers : 'None',
                  isItalic: entry.blockers.isEmpty,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1),
                ),
                _buildSection(
                  context,
                  title: '03 / What\'s the priority tomorrow?',
                  content: entry.tomorrow.isNotEmpty ? entry.tomorrow : 'None',
                  isItalic: entry.tomorrow.isEmpty,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: onEdit,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.edit_rounded, size: 20),
          label: const Text('Edit Journal Entry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required String content, bool isItalic = false}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            color: isItalic ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6) : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
