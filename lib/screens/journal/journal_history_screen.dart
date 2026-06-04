// lib/screens/journal/journal_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app.dart';
import '../../models/journal_entry.dart';
import '../../providers/journal_provider.dart';
import '../../utils/date_utils.dart';

class JournalHistoryScreen extends ConsumerWidget {
  const JournalHistoryScreen({super.key});

  void _showEntryDetail(BuildContext context, WidgetRef ref, JournalEntry entry) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          friendlyDate(entry.createdAt),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _sectionHeader(theme, 'What did you do today?'),
              const SizedBox(height: 6),
              Text(entry.shipped, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              _sectionHeader(theme, 'What slowed you down?'),
              const SizedBox(height: 6),
              Text(
                entry.blockers.isNotEmpty ? entry.blockers : 'None',
                style: TextStyle(
                  fontSize: 14,
                  color: entry.blockers.isNotEmpty ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontStyle: entry.blockers.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              _sectionHeader(theme, 'What did you improve today?'),
              const SizedBox(height: 6),
              Text(
                entry.improved.isNotEmpty ? entry.improved : 'None',
                style: TextStyle(
                  fontSize: 14,
                  color: entry.improved.isNotEmpty ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontStyle: entry.improved.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              _sectionHeader(theme, 'What\'s the priority tomorrow?'),
              const SizedBox(height: 6),
              Text(
                entry.tomorrow.isNotEmpty ? entry.tomorrow : 'None',
                style: TextStyle(
                  fontSize: 14,
                  color: entry.tomorrow.isNotEmpty ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontStyle: entry.tomorrow.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                ),
              ),
              if (entry.totalTrackedSeconds > 0) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      '${formatDuration(entry.totalTrackedSeconds)} tracked',
                      style: TextStyle(fontSize: 13, color: theme.colorScheme.primary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton.icon(
            onPressed: () {
              try {
                final parsedDate = DateTime.parse(entry.dayKey);
                ref.read(selectedJournalDateProvider.notifier).state = parsedDate;
              } catch (_) {
                ref.read(selectedJournalDateProvider.notifier).state = entry.createdAt;
              }
              ref.read(navigationIndexProvider.notifier).state = 2;
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close history screen
            },
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text('View/Edit'),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
        letterSpacing: 0.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalsAsync = ref.watch(allJournalsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal History'),
      ),
      body: journalsAsync.when(
        data: (journals) {
          if (journals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu_outlined, size: 48, color: theme.colorScheme.outline),
                  const SizedBox(height: 12),
                  Text(
                    'No journals logged yet',
                    style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: journals.length,
            itemBuilder: (context, index) {
              final entry = journals[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _showEntryDetail(context, ref, entry),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                friendlyDate(entry.createdAt),
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                              if (entry.totalTrackedSeconds > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    formatDuration(entry.totalTrackedSeconds),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            entry.shipped,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'failed to load journals: $e',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ),
      ),
    );
  }
}
