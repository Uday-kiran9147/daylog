import 'package:flutter/material.dart';
import '../theme/daynote_theme.dart';

class MonthYearPickerSheet extends StatefulWidget {
  final DateTime initialMonth;
  final Function(int year, int month) onSelected;

  const MonthYearPickerSheet({
    super.key,
    required this.initialMonth,
    required this.onSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required DateTime initialMonth,
    required Function(int year, int month) onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: DayNoteTheme.cardBackground(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => MonthYearPickerSheet(
        initialMonth: initialMonth,
        onSelected: onSelected,
      ),
    );
  }

  @override
  State<MonthYearPickerSheet> createState() => _MonthYearPickerSheetState();
}

class _MonthYearPickerSheetState extends State<MonthYearPickerSheet> {
  late int _selectedYear;
  late int _selectedMonth;
  bool _isSelectingYearList = false;

  final List<String> _months = const [
    'January', 'February', 'March',
    'April', 'May', 'June',
    'July', 'August', 'September',
    'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialMonth.year;
    _selectedMonth = widget.initialMonth.month;
  }

  void _selectMonth(int month) {
    widget.onSelected(_selectedYear, month);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dividerColor = DayNoteTheme.divider(context);
    final highlightBg = DayNoteTheme.surfaceHighlight(context);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                const SizedBox(height: 14),

                // Top Bar: Title & Close
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NAVIGATE CALENDAR',
                      style: DayNoteTheme.sectionTitle(context).copyWith(
                        fontSize: 14,
                        letterSpacing: 1.5,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20, color: DayNoteTheme.textSecondary(context)),
                      onPressed: () => Navigator.of(context).pop(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Year selector header bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: highlightBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: dividerColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, color: DayNoteTheme.textPrimary(context)),
                        tooltip: 'Previous Year',
                        onPressed: () {
                          setState(() {
                            _selectedYear--;
                          });
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isSelectingYearList = !_isSelectingYearList;
                          });
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$_selectedYear',
                                style: DayNoteTheme.monthTitle(context).copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                _isSelectingYearList
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                                size: 20,
                                color: DayNoteTheme.accent(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right, color: DayNoteTheme.textPrimary(context)),
                        tooltip: 'Next Year',
                        onPressed: () {
                          setState(() {
                            _selectedYear++;
                          });
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Year List Grid OR Month Matrix
                if (_isSelectingYearList)
                  SizedBox(
                    height: 220,
                    child: _buildYearsGrid(),
                  )
                else
                  _buildMonthsGrid(now),

                const SizedBox(height: 16),

                // Footer actions: Jump to Today
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: DayNoteTheme.textPrimary(context),
                          side: BorderSide(color: dividerColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          final today = DateTime.now();
                          widget.onSelected(today.year, today.month);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Jump to Today (${_months[now.month - 1]} ${now.year})',
                          style: DayNoteTheme.button(context).copyWith(
                            color: DayNoteTheme.accent(context),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYearsGrid() {
    final currentYear = DateTime.now().year;
    final years = List.generate(25, (index) => (currentYear - 12) + index);
    final highlightBg = DayNoteTheme.surfaceHighlight(context);
    final primary = DayNoteTheme.textPrimary(context);
    final bg = DayNoteTheme.background(context);

    return GridView.builder(
      shrinkWrap: true,
      itemCount: years.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.8,
      ),
      itemBuilder: (context, index) {
        final year = years[index];
        final isSelected = year == _selectedYear;
        final isCurrentYear = year == DateTime.now().year;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedYear = year;
              _isSelectingYearList = false;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? primary
                  : (isCurrentYear ? DayNoteTheme.subtleHover(context) : highlightBg),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? primary : Colors.white,
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$year',
                style: DayNoteTheme.body(context).copyWith(
                  color: isSelected ? bg : primary,
                  fontWeight: isSelected || isCurrentYear ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthsGrid(DateTime now) {
    final highlightBg = DayNoteTheme.surfaceHighlight(context);
    final primary = DayNoteTheme.textPrimary(context);
    final bg = DayNoteTheme.background(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.1,
      ),
      itemBuilder: (context, index) {
        final monthIndex = index + 1;
        final isSelected =
            _selectedYear == widget.initialMonth.year && monthIndex == _selectedMonth;
        final isCurrentMonth =
            _selectedYear == now.year && monthIndex == now.month;

        return InkWell(
          onTap: () => _selectMonth(monthIndex),
          borderRadius: BorderRadius.circular(8),
          splashColor: DayNoteTheme.subtleHover(context),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? primary : highlightBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? primary : Colors.white,
                width: isCurrentMonth && !isSelected ? 1.4 : 1.0,
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _months[index],
                style: DayNoteTheme.body(context).copyWith(
                  color: isSelected ? bg : primary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
