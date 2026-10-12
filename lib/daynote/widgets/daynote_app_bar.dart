import 'package:flutter/material.dart';
import '../theme/daynote_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'account_sheet.dart';

class DaynoteAppBar extends StatelessWidget {
  final AuthViewModel? authViewModel;
  final VoidCallback onGoToToday;
  final bool isTodaySelected;
  final VoidCallback? onOpenWalkthrough;

  const DaynoteAppBar({
    super.key,
    this.authViewModel,
    required this.onGoToToday,
    this.isTodaySelected = true,
    this.onOpenWalkthrough,
  });

  @override
  Widget build(BuildContext context) {
    final user = authViewModel?.currentUser;
    final isAuthenticated = authViewModel?.isAuthenticated ?? false;
    final email = user?.email ?? '';
    final initial = isAuthenticated && email.isNotEmpty ? email[0].toUpperCase() : 'D';

    final dividerColor = DayNoteTheme.divider(context);
    final highlightBg = DayNoteTheme.surfaceHighlight(context);
    final primary = DayNoteTheme.textPrimary(context);
    final accent = DayNoteTheme.accent(context);
    final bg = DayNoteTheme.background(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          bottom: BorderSide(
            color: dividerColor,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Brand Logo & Title
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'D',
                    style: DayNoteTheme.button(context).copyWith(
                      color: bg,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    'DAYLOG',
                    style: DayNoteTheme.body(context).copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: 2.0,
                      color: primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Right: Today Shortcut & Account
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Jump to Today Pill Button
              InkWell(
                onTap: onGoToToday,
                borderRadius: BorderRadius.circular(999),
                splashColor: DayNoteTheme.subtleHover(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isTodaySelected ? highlightBg : DayNoteTheme.accentLight(context),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.today_outlined,
                        size: 14,
                        color: isTodaySelected ? DayNoteTheme.textSecondary(context) : accent,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Today',
                        style: DayNoteTheme.caption(context).copyWith(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isTodaySelected ? primary : accent,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Account Avatar / Sync Button
              if (authViewModel != null) ...[
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => AccountSheet.show(
                    context,
                    authViewModel: authViewModel!,
                    onOpenWalkthrough: onOpenWalkthrough,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  splashColor: DayNoteTheme.subtleHover(context),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: highlightBg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: isAuthenticated
                        ? Text(
                            initial,
                            style: DayNoteTheme.body(context).copyWith(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: primary,
                            ),
                          )
                        : Icon(
                            Icons.cloud_queue_rounded,
                            size: 16,
                            color: DayNoteTheme.textSecondary(context),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
