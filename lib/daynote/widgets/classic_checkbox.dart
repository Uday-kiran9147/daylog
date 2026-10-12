import 'package:flutter/material.dart';
import '../theme/daynote_theme.dart';

class ClassicCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ClassicCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primary = DayNoteTheme.textPrimary(context);
    final secondary = DayNoteTheme.textSecondary(context);
    final bg = DayNoteTheme.background(context);

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(4),
      splashColor: DayNoteTheme.subtleHover(context),
      highlightColor: DayNoteTheme.subtleHover(context),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          width: 19,
          height: 19,
          decoration: BoxDecoration(
            color: value ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: value ? primary : secondary,
              width: 1.3,
            ),
          ),
          alignment: Alignment.center,
          child: value
              ? Icon(
                  Icons.check,
                  size: 13,
                  color: bg,
                )
              : null,
        ),
      ),
    );
  }
}
