import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';

class DayNoteTheme {
  DayNoteTheme._();

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // Dynamic Surfaces
  static Color background(BuildContext context) =>
      isDark(context) ? DaylogColors.darkBg : DaylogColors.lightBg;

  static Color cardBackground(BuildContext context) =>
      isDark(context) ? DaylogColors.darkCard : DaylogColors.lightCard;

  static Color surfaceHighlight(BuildContext context) =>
      isDark(context) ? DaylogColors.darkSurface : Colors.white;

  static Color subtleHover(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE9ECEF);

  // Dynamic Text Colors
  static Color textPrimary(BuildContext context) =>
      isDark(context) ? DaylogColors.darkText : DaylogColors.lightText;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.65) : const Color(0xFF495057);

  static Color textTertiary(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.40) : const Color(0xFF868E96);

  static Color textDisabled(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.22) : const Color(0xFFADB5BD);

  // Separators & Accents
  static Color divider(BuildContext context) =>
      isDark(context) ? DaylogColors.darkDivider : DaylogColors.lightDivider;

  static Color border(BuildContext context) => Colors.white;

  static Color focusedBorder(BuildContext context) => Colors.white;

  static Color accent(BuildContext context) =>
      isDark(context) ? DaylogColors.darkAccent : DaylogColors.accent;

  static Color accentLight(BuildContext context) =>
      isDark(context) ? DaylogColors.darkAccent100 : DaylogColors.accent100;

  // Priority Colors
  static Color priorityHigh(BuildContext context) =>
      isDark(context) ? const Color(0xFFF87171) : const Color(0xFFDC2626);

  static Color priorityHighBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF3B1818) : const Color(0xFFFEE2E2);

  static Color priorityMed(BuildContext context) =>
      isDark(context) ? const Color(0xFFFBBF24) : const Color(0xFFD97706);

  static Color priorityMedBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF382910) : const Color(0xFFFEF3C7);

  static Color priorityLow(BuildContext context) =>
      isDark(context) ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);

  static Color priorityLowBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF132A1B) : const Color(0xFFDCFCE7);

  // Typography
  static TextStyle heading(BuildContext context) => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary(context),
        letterSpacing: -0.2,
      );

  static TextStyle monthTitle(BuildContext context) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary(context),
        letterSpacing: -0.1,
      );

  static TextStyle selectedDate(BuildContext context) => GoogleFonts.inter(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: textPrimary(context),
        letterSpacing: -0.2,
      );

  static TextStyle selectedYear(BuildContext context) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textSecondary(context),
      );

  static TextStyle sectionTitle(BuildContext context) => GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: textSecondary(context),
        letterSpacing: 1.2,
      );

  static TextStyle body(BuildContext context) => GoogleFonts.inter(
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        color: textPrimary(context),
        height: 1.5,
      );

  static TextStyle bodyDone(BuildContext context) => GoogleFonts.inter(
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        color: textTertiary(context),
        decoration: TextDecoration.lineThrough,
        decorationColor: textTertiary(context),
        height: 1.5,
      );

  static TextStyle noteText(BuildContext context) => GoogleFonts.inter(
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        color: textPrimary(context),
        height: 1.6,
      );

  static TextStyle caption(BuildContext context) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textTertiary(context),
      );

  static TextStyle button(BuildContext context) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textPrimary(context),
      );
}
