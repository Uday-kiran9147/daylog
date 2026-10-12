import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/daynote_theme.dart';

class SelectedDateHeader extends StatelessWidget {
  final DateTime date;
  final bool isToday;

  const SelectedDateHeader({
    super.key,
    required this.date,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final dayFormat = DateFormat('EEEE, MMMM d');
    final yearFormat = DateFormat('y');

    final formattedDay = dayFormat.format(date);
    final formattedYear = yearFormat.format(date);
    final dividerColor = DayNoteTheme.divider(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: DayNoteTheme.background(context),
        border: Border(
          top: BorderSide(color: dividerColor, width: 1.0),
          bottom: BorderSide(color: dividerColor, width: 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                formattedDay,
                style: DayNoteTheme.selectedDate(context),
              ),
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: DayNoteTheme.accentLight(context),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.white,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    'TODAY',
                    style: DayNoteTheme.caption(context).copyWith(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: DayNoteTheme.accent(context),
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            formattedYear,
            style: DayNoteTheme.selectedYear(context),
          ),
        ],
      ),
    );
  }
}
