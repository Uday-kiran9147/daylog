// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/todo_provider.dart';
import '../../services/export_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/daylog_widgets.dart';
import 'manage_categories_sheet.dart';

// State providers for notification preferences
final wrapUpNotifProvider = StateProvider<bool>((ref) => true);
final healthNotifProvider = StateProvider<bool>((ref) => true);
final highPriorityNotifProvider = StateProvider<bool>((ref) => true);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    final wrapUp = ref.watch(wrapUpNotifProvider);
    final health = ref.watch(healthNotifProvider);
    final highPriority = ref.watch(highPriorityNotifProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Page Header
            const DaylogPageHeader(title: 'Settings'),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── APPEARANCE SECTION ───────────────────────────────────
                  Text(
                    'Appearance',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Segmented control (Light, Dark, System)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SegmentItem(
                            label: 'Light',
                            isSelected: themeMode == ThemeMode.light,
                            onTap: () => ref.read(themeModeProvider.notifier).state = ThemeMode.light,
                          ),
                        ),
                        Expanded(
                          child: _SegmentItem(
                            label: 'Dark',
                            isSelected: themeMode == ThemeMode.dark,
                            onTap: () => ref.read(themeModeProvider.notifier).state = ThemeMode.dark,
                          ),
                        ),
                        Expanded(
                          child: _SegmentItem(
                            label: 'System',
                            isSelected: themeMode == ThemeMode.system,
                            onTap: () => ref.read(themeModeProvider.notifier).state = ThemeMode.system,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ── CATEGORIES SECTION ───────────────────────────────────
                  Text(
                    'Categories & Focus Domains',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 10),

                  OutlinedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const ManageCategoriesSheet(),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                      foregroundColor: theme.colorScheme.onSurface,
                      backgroundColor: theme.cardTheme.color,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    icon: const Icon(Icons.category_outlined, size: 18),
                    label: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Manage Work Categories',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        Icon(Icons.chevron_right_rounded, size: 20),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ── NOTIFICATIONS SECTION ────────────────────────────────
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Column(
                    children: [
                      _NotificationToggleRow(
                        title: '9 PM wrap-up reminder',
                        subtitle: 'Prompts your evening reflection',
                        value: wrapUp,
                        onChanged: (val) {
                          ref.read(wrapUpNotifProvider.notifier).state = val;
                          if (val) {
                            NotificationService.scheduleDaily9pmReminder();
                          } else {
                            NotificationService.cancelJournalReminder();
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      _NotificationToggleRow(
                        title: 'Focus & health checks',
                        subtitle: 'Every 2 hours while focusing',
                        value: health,
                        onChanged: (val) {
                          ref.read(healthNotifProvider.notifier).state = val;
                          final active = ref.read(activeTaskProvider).valueOrNull;
                          if (val) {
                            NotificationService.updateTaskReminders(active);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      _NotificationToggleRow(
                        title: 'High-priority reminders',
                        subtitle: 'Hourly nudge for unfinished flags',
                        value: highPriority,
                        onChanged: (val) {
                          ref.read(highPriorityNotifProvider.notifier).state = val;
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  // ── DATA BACKUP SECTION ──────────────────────────────────
                  Text(
                    'Data',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Column(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            await ExportService.exportData();
                            if (context.mounted) {
                              showDaylogToast(context, 'Backup exported as daylog-backup.json');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showDaylogToast(context, 'Export failed: $e');
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          side: BorderSide(color: theme.colorScheme.outlineVariant),
                          foregroundColor: theme.colorScheme.onSurface,
                          backgroundColor: theme.cardTheme.color,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        icon: const Icon(Icons.file_download_outlined, size: 18),
                        label: const Text(
                          'Export backup (JSON)',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            final result = await ExportService.importData();
                            if (result != null && context.mounted) {
                              ref.invalidate(todayTasksProvider);
                              ref.invalidate(todayTotalSecondsProvider);
                              ref.invalidate(recentTasksProvider);
                              ref.invalidate(todoProvider);
                              showDaylogToast(context, 'Backup restored');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showDaylogToast(context, 'Import failed: $e');
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          side: BorderSide(color: theme.colorScheme.outlineVariant),
                          foregroundColor: theme.colorScheme.onSurface,
                          backgroundColor: theme.cardTheme.color,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        icon: const Icon(Icons.file_upload_outlined, size: 18),
                        label: const Text(
                          'Import backup',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // Footer
                  Center(
                    child: Text(
                      'Daylog · v1.0.0 build',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [const BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1))]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

class _NotificationToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        DaylogSwitch(value: value, onChanged: onChanged),
      ],
    );
  }
}
