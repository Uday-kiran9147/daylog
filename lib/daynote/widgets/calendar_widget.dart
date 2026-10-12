import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/day_entry.dart';
import '../theme/daynote_theme.dart';
import 'month_year_picker_sheet.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final Set<String> datesWithContent;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final Function(int year, int month) onMonthYearChanged;
  final VoidCallback onGoToToday;
  final VoidCallback? onOpenAccount;

  const CalendarWidget({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.datesWithContent,
    required this.onDateSelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onMonthYearChanged,
    required this.onGoToToday,
    this.onOpenAccount,
  });

  void _openMonthYearPicker(BuildContext context) {
    MonthYearPickerSheet.show(
      context,
      initialMonth: currentMonth,
      onSelected: onMonthYearChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthFormat = DateFormat('MMMM yyyy');
    final monthTitle = monthFormat.format(currentMonth);
    final dividerColor = DayNoteTheme.divider(context);
    final highlightBg = DayNoteTheme.surfaceHighlight(context);

    return Container(
      color: DayNoteTheme.background(context),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month Header with Selector Chip & Stepper Group
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Month & Year Selector Chip
                Flexible(
                  child: InkWell(
                    onTap: () => _openMonthYearPicker(context),
                    borderRadius: BorderRadius.circular(8),
                    splashColor: DayNoteTheme.subtleHover(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: highlightBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: dividerColor,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              monthTitle,
                              style: DayNoteTheme.monthTitle(context).copyWith(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: DayNoteTheme.accent(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Month Stepper Navigation Button Group ( ‹  › )
                Container(
                  decoration: BoxDecoration(
                    color: highlightBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: dividerColor,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: onPreviousMonth,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(7)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                          child: Icon(
                            Icons.chevron_left_rounded,
                            size: 20,
                            color: DayNoteTheme.textPrimary(context),
                          ),
                        ),
                      ),
                      Container(
                        width: 1.0,
                        height: 18.0,
                        color: dividerColor,
                      ),
                      InkWell(
                        onTap: onNextMonth,
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(7)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: DayNoteTheme.textPrimary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Swipeable calendar grid area
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if ((details.primaryVelocity ?? 0) < -200) {
                onNextMonth();
              } else if ((details.primaryVelocity ?? 0) > 200) {
                onPreviousMonth();
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Days of week header (Mon - Sun)
                _buildWeekdaysHeader(context),
                const SizedBox(height: 4),
                // Monthly calendar days matrix
                _buildDaysGrid(context),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildWeekdaysHeader(BuildContext context) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays.map((day) {
          final isWeekend = day == 'Sat' || day == 'Sun';
          return Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  day,
                  style: DayNoteTheme.caption(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: isWeekend
                        ? DayNoteTheme.accent(context)
                        : DayNoteTheme.textTertiary(context),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDaysGrid(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      currentMonth.year,
      currentMonth.month,
    );

    // Monday is 1, Sunday is 7 in Dart DateTime
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday; // 1=Mon, 7=Sun
    final leadingEmptyDays = firstWeekday - 1;

    final prevMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
    final daysInPrevMonth = DateUtils.getDaysInMonth(prevMonth.year, prevMonth.month);

    final totalGridCells = ((leadingEmptyDays + daysInMonth) / 7).ceil() * 7;

    final now = DateTime.now();
    final todayNormalized = DateTime(now.year, now.month, now.day);
    final selectedNormalized = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    final List<Widget> dayRows = [];
    List<Widget> currentRowCells = [];

    for (int i = 0; i < totalGridCells; i++) {
      final isLeading = i < leadingEmptyDays;
      final isCurrent = i >= leadingEmptyDays && i < leadingEmptyDays + daysInMonth;

      DateTime cellDate;
      bool isOtherMonth = false;

      if (isLeading) {
        final dayNum = daysInPrevMonth - (leadingEmptyDays - i - 1);
        cellDate = DateTime(prevMonth.year, prevMonth.month, dayNum);
        isOtherMonth = true;
      } else if (isCurrent) {
        final dayNum = i - leadingEmptyDays + 1;
        cellDate = DateTime(currentMonth.year, currentMonth.month, dayNum);
        isOtherMonth = false;
      } else {
        final nextMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
        final dayNum = i - (leadingEmptyDays + daysInMonth) + 1;
        cellDate = DateTime(nextMonth.year, nextMonth.month, dayNum);
        isOtherMonth = true;
      }

      final cellNormalized = DateTime(cellDate.year, cellDate.month, cellDate.day);
      final isSelected = cellNormalized == selectedNormalized;
      final isToday = cellNormalized == todayNormalized;
      final dateKey = DayEntry.formatDateKey(cellDate);
      final hasContent = datesWithContent.contains(dateKey);

      currentRowCells.add(
        Expanded(
          child: _buildDayCell(
            context: context,
            date: cellDate,
            isSelected: isSelected,
            isToday: isToday,
            isOtherMonth: isOtherMonth,
            hasContent: hasContent,
          ),
        ),
      );

      if ((i + 1) % 7 == 0) {
        dayRows.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.from(currentRowCells),
          ),
        );
        currentRowCells.clear();
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: dayRows,
    );
  }

  Widget _buildDayCell({
    required BuildContext context,
    required DateTime date,
    required bool isSelected,
    required bool isToday,
    required bool isOtherMonth,
    required bool hasContent,
  }) {
    Color textColor;
    FontWeight fontWeight;

    final primary = DayNoteTheme.textPrimary(context);
    final accent = DayNoteTheme.accent(context);
    final disabled = DayNoteTheme.textDisabled(context);
    final bg = DayNoteTheme.background(context);

    if (isSelected) {
      textColor = bg;
      fontWeight = FontWeight.w700;
    } else if (isOtherMonth) {
      textColor = disabled;
      fontWeight = FontWeight.w400;
    } else if (isToday) {
      textColor = accent;
      fontWeight = FontWeight.w700;
    } else {
      textColor = primary;
      fontWeight = FontWeight.w500;
    }

    return InkWell(
      onTap: () => onDateSelected(date),
      borderRadius: BorderRadius.circular(20),
      splashColor: DayNoteTheme.subtleHover(context),
      highlightColor: DayNoteTheme.subtleHover(context),
      child: Container(
        height: 42,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Selected highlight or Today ring
            if (isSelected)
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
              )
            else if (isToday)
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.4,
                  ),
                ),
              ),

            // Date Number Text
            Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${date.day}',
                  style: DayNoteTheme.body(context).copyWith(
                    fontSize: 13.5,
                    fontWeight: fontWeight,
                    color: textColor,
                  ),
                ),
              ),
            ),

            // Tiny visual indicator dot underneath the date
            if (hasContent)
              Positioned(
                bottom: 3.5,
                child: Container(
                  width: 3.8,
                  height: 3.8,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? bg.withValues(alpha: 0.9)
                        : accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
