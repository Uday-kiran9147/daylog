// lib/screens/journal/journal_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/journal_entry.dart';
import '../../providers/journal_provider.dart';
import '../../utils/date_utils.dart';
import '../../widgets/daylog_widgets.dart';

class JournalHistoryScreen extends ConsumerWidget {
  const JournalHistoryScreen({super.key});

  void _showEntryDetail(BuildContext context, WidgetRef ref, JournalEntry entry) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    DateTime? entryDate;
    try {
      entryDate = DateTime.parse(entry.dayKey);
    } catch (_) {
      entryDate = entry.createdAt;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          friendlyDate(entryDate!),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (entry.totalTrackedSeconds > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF332D2A) : const Color(0xFFE8DFD3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    formatDuration(entry.totalTrackedSeconds),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              _buildModalSection(theme, 'Shipped', entry.shipped),
              const SizedBox(height: 12),
              _buildModalSection(theme, 'Blockers', entry.blockers.isNotEmpty ? entry.blockers : '—'),
              const SizedBox(height: 12),
              _buildModalSection(theme, 'Improved', entry.improved.isNotEmpty ? entry.improved : '—'),
              const SizedBox(height: 12),
              _buildModalSection(theme, 'Tomorrow', entry.tomorrow.isNotEmpty ? entry.tomorrow : '—'),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(selectedJournalDateProvider.notifier).state = entryDate!;
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to journal screen
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: const Text('Edit entry', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildModalSection(ThemeData theme, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          content,
          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalsAsync = ref.watch(allJournalsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DaylogPageHeader(
              title: 'Journal History',
              showBackButton: true,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: journalsAsync.when(
                data: (journals) {
                  final withContent = journals.where((j) => j.shipped.isNotEmpty).toList();

                  if (withContent.isEmpty) {
                    return Center(
                      child: Text(
                        'No reflections logged yet.',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: withContent.length,
                    itemBuilder: (context, index) {
                      final entry = withContent[index];
                      DateTime? entryDate;
                      try {
                        entryDate = DateTime.parse(entry.dayKey);
                      } catch (_) {
                        entryDate = entry.createdAt;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => _showEntryDetail(context, ref, entry),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.cardTheme.color,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      friendlyDate(entryDate),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    if (entry.totalTrackedSeconds > 0)
                                      Text(
                                        formatDuration(entry.totalTrackedSeconds),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  entry.shipped,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
