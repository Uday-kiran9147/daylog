import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/day_entry.dart';
import '../models/todo_item.dart';
import '../theme/daynote_theme.dart';

class DetailsSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const DetailsSheet({
    super.key,
    required this.title,
    required this.children,
  });

  static String formatDateTime(DateTime? dt) {
    if (dt == null) return '—';
    final datePart = DateFormat('MMM d, y').format(dt);
    final timePart = DateFormat('h:mm a').format(dt);
    return '$datePart at $timePart';
  }

  static String formatRelative(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.isNegative || diff.inSeconds < 45) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24 && now.day == dt.day) return '${diff.inHours}h ago';
    if (diff.inDays == 1 || (diff.inHours < 48 && now.day != dt.day)) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }

  static Future<void> showEntryDetails(
    BuildContext context, {
    required DayEntry entry,
    required DateTime date,
  }) {
    final dayFormatted = DateFormat('EEEE, MMMM d, y').format(date);
    final noteHasContent = entry.note.trim().isNotEmpty;
    final noteLength = entry.note.trim().length;
    final noteWordCount = noteHasContent
        ? entry.note.trim().split(RegExp(r'\s+')).length
        : 0;

    return showModalBottomSheet(
      context: context,
      backgroundColor: DayNoteTheme.cardBackground(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => DetailsSheet(
        title: 'ENTRY DETAILS',
        children: [
          // Date Subtitle
          Text(
            dayFormatted,
            style: DayNoteTheme.body(ctx).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14.5,
              color: DayNoteTheme.textPrimary(ctx),
            ),
          ),
          const SizedBox(height: 16),

          // Daily Record Card
          _buildCard(
            ctx,
            title: 'DAILY RECORD',
            icon: Icons.calendar_today_outlined,
            items: [
              _DetailRow(
                label: 'CREATED',
                value: formatDateTime(entry.createdAt),
                badge: formatRelative(entry.createdAt),
              ),
              _DetailRow(
                label: 'LAST UPDATED',
                value: formatDateTime(entry.updatedAt),
                badge: formatRelative(entry.updatedAt),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Journal Note Card
          _buildCard(
            ctx,
            title: 'JOURNAL NOTE',
            icon: Icons.edit_note_rounded,
            items: [
              _DetailRow(
                label: 'STATUS',
                value: noteHasContent
                    ? '$noteWordCount words • $noteLength characters'
                    : 'No note recorded',
              ),
              if (noteHasContent) ...[
                _DetailRow(
                  label: 'CREATED',
                  value: formatDateTime(entry.noteCreatedAt ?? entry.createdAt),
                  badge: formatRelative(entry.noteCreatedAt ?? entry.createdAt),
                ),
                _DetailRow(
                  label: 'LAST MODIFIED',
                  value: formatDateTime(entry.noteUpdatedAt ?? entry.updatedAt),
                  badge: formatRelative(entry.noteUpdatedAt ?? entry.updatedAt),
                ),
              ],
            ],
          ),

          const SizedBox(height: 14),

          // Checklist Card
          _buildCard(
            ctx,
            title: 'CHECKLIST TASKS',
            icon: Icons.checklist_rounded,
            items: [
              _DetailRow(
                label: 'TASKS COUNT',
                value: entry.todos.isEmpty
                    ? 'No tasks added'
                    : '${entry.completedTodosCount} of ${entry.totalTodosCount} completed',
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> showTodoDetails(
    BuildContext context,
    TodoItem todo,
  ) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: DayNoteTheme.cardBackground(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => DetailsSheet(
        title: 'TASK DETAILS',
        children: [
          // Task Text Card
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: DayNoteTheme.surfaceHighlight(ctx),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  todo.isDone ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                  size: 20,
                  color: todo.isDone
                      ? DayNoteTheme.accent(ctx)
                      : DayNoteTheme.textTertiary(ctx),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    todo.text,
                    style: DayNoteTheme.body(ctx).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      decoration: todo.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Timestamps & Meta Card
          _buildCard(
            ctx,
            title: 'TIMESTAMPS & STATUS',
            icon: Icons.schedule_rounded,
            items: [
              _DetailRow(
                label: 'STATUS',
                value: todo.isDone ? 'Completed' : 'Pending',
              ),
              if (todo.priority != TodoPriority.none)
                _DetailRow(
                  label: 'PRIORITY',
                  value: todo.priority.label,
                ),
              _DetailRow(
                label: 'CREATED',
                value: formatDateTime(todo.createdAt),
                badge: formatRelative(todo.createdAt),
              ),
              _DetailRow(
                label: 'LAST UPDATED',
                value: formatDateTime(todo.updatedAt),
                badge: formatRelative(todo.updatedAt),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> showNoteDetails(
    BuildContext context, {
    required String note,
    DateTime? createdAt,
    DateTime? updatedAt,
    required DateTime date,
  }) {
    final dayFormatted = DateFormat('EEEE, MMMM d, y').format(date);
    final hasContent = note.trim().isNotEmpty;
    final wordCount = hasContent ? note.trim().split(RegExp(r'\s+')).length : 0;
    final charCount = note.trim().length;

    return showModalBottomSheet(
      context: context,
      backgroundColor: DayNoteTheme.cardBackground(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => DetailsSheet(
        title: 'NOTE DETAILS',
        children: [
          // Date Subtitle
          Text(
            dayFormatted,
            style: DayNoteTheme.body(ctx).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14.5,
              color: DayNoteTheme.textPrimary(ctx),
            ),
          ),
          const SizedBox(height: 16),

          _buildCard(
            ctx,
            title: 'WRITING TIMESTAMPS',
            icon: Icons.edit_note_rounded,
            items: [
              _DetailRow(
                label: 'STATUS',
                value: hasContent
                    ? '$wordCount words • $charCount characters (Auto-saved)'
                    : 'Empty note surface',
              ),
              if (hasContent) ...[
                _DetailRow(
                  label: 'CREATED',
                  value: formatDateTime(createdAt),
                  badge: formatRelative(createdAt),
                ),
                _DetailRow(
                  label: 'LAST MODIFIED',
                  value: formatDateTime(updatedAt),
                  badge: formatRelative(updatedAt),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<_DetailRow> items,
  }) {
    final highlightBg = DayNoteTheme.surfaceHighlight(context);
    final primary = DayNoteTheme.textPrimary(context);

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: highlightBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: DayNoteTheme.accent(context)),
              const SizedBox(width: 8),
              Text(
                title,
                style: DayNoteTheme.caption(context).copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            items[i],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor = DayNoteTheme.divider(context);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Top Bar Title & Close
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: DayNoteTheme.sectionTitle(context).copyWith(
                        fontSize: 13,
                        letterSpacing: 1.5,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 20,
                        color: DayNoteTheme.textSecondary(context),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final String? badge;

  const _DetailRow({
    required this.label,
    required this.value,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final accent = DayNoteTheme.accent(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DayNoteTheme.caption(context).copyWith(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: DayNoteTheme.textTertiary(context),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value,
                style: DayNoteTheme.body(context).copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (badge != null && badge!.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: DayNoteTheme.accentLight(context),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge!,
                  style: DayNoteTheme.caption(context).copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
