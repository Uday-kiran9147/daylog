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
      isDark(context) ? DaylogColors.darkSurface : const Color(0xFFFFFDF9);

  static Color subtleHover(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFEFE9DC);

  // Dynamic Text Colors
  static Color textPrimary(BuildContext context) =>
      isDark(context) ? DaylogColors.darkText : DaylogColors.lightText;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.65) : const Color(0xFF5F5953);

  static Color textTertiary(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.40) : const Color(0xFF948D85);

  static Color textDisabled(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.22) : const Color(0xFFC7C0B7);

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
      isDark(context) ? DaylogColors.darkAccent : const Color(0xFFB84533);

  static Color priorityHighBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF3D251C) : const Color(0xFFF9EAE7);

  static Color priorityMed(BuildContext context) =>
      isDark(context) ? const Color(0xFFE5A158) : const Color(0xFF9E6523);

  static Color priorityMedBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF3B2814) : const Color(0xFFFAF1E4);

  static Color priorityLow(BuildContext context) =>
      isDark(context) ? const Color(0xFF7CB88F) : const Color(0xFF4A7C59);

  static Color priorityLowBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF162D1C) : const Color(0xFFECF3EE);

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
