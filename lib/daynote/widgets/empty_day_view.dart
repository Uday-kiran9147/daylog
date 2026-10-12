import 'package:flutter/material.dart';
import '../theme/daynote_theme.dart';

class EmptyDayView extends StatelessWidget {
  final VoidCallback onAddTodo;
  final VoidCallback onAddNote;

  const EmptyDayView({
    super.key,
    required this.onAddTodo,
    required this.onAddNote,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Simple, clean empty message
          Text(
            'Nothing planned for this day.',
            style: DayNoteTheme.body(context).copyWith(
              fontSize: 14.5,
              color: DayNoteTheme.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Action buttons
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              _buildActionButton(
                context,
                label: '+ Add Todo',
                onTap: onAddTodo,
              ),
              _buildActionButton(
                context,
                label: '+ Add Note',
                onTap: onAddNote,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    final highlightBg = DayNoteTheme.surfaceHighlight(context);
    final dividerColor = DayNoteTheme.divider(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      splashColor: DayNoteTheme.subtleHover(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 9.0),
        decoration: BoxDecoration(
          color: highlightBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: dividerColor,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: DayNoteTheme.button(context).copyWith(
            fontSize: 13,
            color: DayNoteTheme.textPrimary(context),
          ),
        ),
      ),
    );
  }
}
