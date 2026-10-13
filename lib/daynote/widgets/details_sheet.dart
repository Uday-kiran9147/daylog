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

  static String _formatExplanation({
    required DateTime dt,
    DateTime? compareWith,
    bool isCreated = false,
  }) {
    final rel = formatRelative(dt).toLowerCase();
    if (isCreated) {
      return 'Initial record created $rel';
    }
    if (compareWith != null && dt.isAtSameMomentAs(compareWith)) {
      return 'Never modified (same as creation time)';
    }
    return 'Last modified $rel';
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
          // Date Header Pill
          _buildDateHeader(ctx, dayFormatted),
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
                explanation: _formatExplanation(dt: entry.createdAt, isCreated: true),
                icon: Icons.add_circle_outline_rounded,
              ),
              _DetailRow(
                label: 'LAST UPDATED',
                value: formatDateTime(entry.updatedAt),
                badge: formatRelative(entry.updatedAt),
                explanation: _formatExplanation(
                  dt: entry.updatedAt,
                  compareWith: entry.createdAt,
                  isCreated: false,
                ),
                icon: Icons.update_rounded,
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
                explanation: noteHasContent
                    ? 'Saved locally to your device'
                    : 'Write reflections on the quiet writing surface',
                icon: Icons.notes_rounded,
              ),
              if (noteHasContent) ...[
                _DetailRow(
                  label: 'CREATED',
                  value: formatDateTime(entry.noteCreatedAt ?? entry.createdAt),
                  badge: formatRelative(entry.noteCreatedAt ?? entry.createdAt),
                  explanation: _formatExplanation(
                    dt: entry.noteCreatedAt ?? entry.createdAt,
                    isCreated: true,
                  ),
                  icon: Icons.add_circle_outline_rounded,
                ),
                _DetailRow(
                  label: 'LAST MODIFIED',
                  value: formatDateTime(entry.noteUpdatedAt ?? entry.updatedAt),
                  badge: formatRelative(entry.noteUpdatedAt ?? entry.updatedAt),
                  explanation: _formatExplanation(
                    dt: entry.noteUpdatedAt ?? entry.updatedAt,
                    compareWith: entry.noteCreatedAt ?? entry.createdAt,
                    isCreated: false,
                  ),
                  icon: Icons.update_rounded,
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
                explanation: entry.todos.isEmpty
                    ? 'Add todo tasks to track what matters today'
                    : '${entry.totalTodosCount - entry.completedTodosCount} tasks remaining for this day',
                icon: Icons.task_alt_rounded,
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
          // Task Preview Card with Status
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: DayNoteTheme.surfaceHighlight(ctx),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      todo.isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                      size: 22,
                      color: todo.isDone
                          ? DayNoteTheme.accent(ctx)
                          : DayNoteTheme.textTertiary(ctx),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        todo.text,
                        style: DayNoteTheme.body(ctx).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          height: 1.35,
                          decoration: todo.isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    // Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: todo.isDone
                            ? DayNoteTheme.priorityLowBg(ctx)
                            : DayNoteTheme.subtleHover(ctx),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: todo.isDone
                              ? DayNoteTheme.priorityLow(ctx).withValues(alpha: 0.3)
                              : Colors.white,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            todo.isDone ? Icons.done : Icons.hourglass_bottom_rounded,
                            size: 13,
                            color: todo.isDone
                                ? DayNoteTheme.priorityLow(ctx)
                                : DayNoteTheme.textSecondary(ctx),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            todo.isDone ? 'Completed' : 'Pending',
                            style: DayNoteTheme.caption(ctx).copyWith(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: todo.isDone
                                  ? DayNoteTheme.priorityLow(ctx)
                                  : DayNoteTheme.textSecondary(ctx),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Priority Pill
                    if (todo.priority != TodoPriority.none)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: _priorityBg(ctx, todo.priority),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white),
                        ),
                        child: Text(
                          '${todo.priority.label} Priority',
                          style: DayNoteTheme.caption(ctx).copyWith(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: _priorityColor(ctx, todo.priority),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Timestamps Card
          _buildCard(
            ctx,
            title: 'TIMESTAMPS & STATUS',
            icon: Icons.schedule_rounded,
            items: [
              _DetailRow(
                label: 'STATUS',
                value: todo.isDone ? 'Completed' : 'Pending',
                explanation: todo.isDone
                    ? 'Task marked done'
                    : 'Task is waiting to be finished',
                icon: todo.isDone ? Icons.check_circle_outline : Icons.pending_actions_outlined,
              ),
              if (todo.priority != TodoPriority.none)
                _DetailRow(
                  label: 'PRIORITY',
                  value: todo.priority.label,
                  explanation: 'Priority level assigned to this task',
                  icon: Icons.flag_outlined,
                ),
              _DetailRow(
                label: 'CREATED',
                value: formatDateTime(todo.createdAt),
                badge: formatRelative(todo.createdAt),
                explanation: _formatExplanation(dt: todo.createdAt, isCreated: true),
                icon: Icons.add_circle_outline_rounded,
              ),
              _DetailRow(
                label: 'LAST UPDATED',
                value: formatDateTime(todo.updatedAt),
                badge: formatRelative(todo.updatedAt),
                explanation: _formatExplanation(
                  dt: todo.updatedAt,
                  compareWith: todo.createdAt,
                  isCreated: false,
                ),
                icon: Icons.update_rounded,
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
          // Date Header Pill
          _buildDateHeader(ctx, dayFormatted),
          const SizedBox(height: 16),

          // Note Statistics Card
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: DayNoteTheme.surfaceHighlight(ctx),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    ctx,
                    icon: Icons.article_outlined,
                    label: 'Word Count',
                    value: '$wordCount',
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: DayNoteTheme.divider(ctx),
                ),
                Expanded(
                  child: _buildStatItem(
                    ctx,
                    icon: Icons.text_fields_rounded,
                    label: 'Characters',
                    value: '$charCount',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Writing Timestamps Card
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
                explanation: hasContent
                    ? 'All edits auto-saved continuously'
                    : 'Type anywhere in the note area to write',
                icon: Icons.save_outlined,
              ),
              if (hasContent) ...[
                _DetailRow(
                  label: 'CREATED',
                  value: formatDateTime(createdAt),
                  badge: formatRelative(createdAt),
                  explanation: createdAt != null
                      ? _formatExplanation(dt: createdAt, isCreated: true)
                      : null,
                  icon: Icons.add_circle_outline_rounded,
                ),
                _DetailRow(
                  label: 'LAST MODIFIED',
                  value: formatDateTime(updatedAt),
                  badge: formatRelative(updatedAt),
                  explanation: updatedAt != null
                      ? _formatExplanation(
                          dt: updatedAt,
                          compareWith: createdAt,
                          isCreated: false,
                        )
                      : null,
                  icon: Icons.update_rounded,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildDateHeader(BuildContext context, String dayFormatted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DayNoteTheme.surfaceHighlight(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_outlined,
            size: 16,
            color: DayNoteTheme.accent(context),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              dayFormatted,
              style: DayNoteTheme.body(context).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                color: DayNoteTheme.textPrimary(context),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: DayNoteTheme.accent(context)),
            const SizedBox(width: 6),
            Text(
              label,
              style: DayNoteTheme.caption(context).copyWith(
                fontSize: 11,
                color: DayNoteTheme.textTertiary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: DayNoteTheme.heading(context).copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: DayNoteTheme.textPrimary(context),
          ),
        ),
      ],
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
        borderRadius: BorderRadius.circular(16),
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

  static Color _priorityColor(BuildContext context, TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return DayNoteTheme.priorityHigh(context);
      case TodoPriority.medium:
        return DayNoteTheme.priorityMed(context);
      case TodoPriority.low:
        return DayNoteTheme.priorityLow(context);
      case TodoPriority.none:
        return DayNoteTheme.textSecondary(context);
    }
  }

  static Color _priorityBg(BuildContext context, TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return DayNoteTheme.priorityHighBg(context);
      case TodoPriority.medium:
        return DayNoteTheme.priorityMedBg(context);
      case TodoPriority.low:
        return DayNoteTheme.priorityLowBg(context);
      case TodoPriority.none:
        return DayNoteTheme.subtleHover(context);
    }
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
  final String? explanation;
  final IconData? icon;

  const _DetailRow({
    required this.label,
    required this.value,
    this.badge,
    this.explanation,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final accent = DayNoteTheme.accent(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: DayNoteTheme.background(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white,
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: DayNoteTheme.accentLight(context),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 16,
                color: accent,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: DayNoteTheme.caption(context).copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: DayNoteTheme.textSecondary(context),
                      ),
                    ),
                    if (badge != null && badge!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: DayNoteTheme.accentLight(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badge!,
                          style: DayNoteTheme.caption(context).copyWith(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: DayNoteTheme.body(context).copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: DayNoteTheme.textPrimary(context),
                  ),
                ),
                if (explanation != null && explanation!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    explanation!,
                    style: DayNoteTheme.caption(context).copyWith(
                      fontSize: 11,
                      color: DayNoteTheme.textTertiary(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
