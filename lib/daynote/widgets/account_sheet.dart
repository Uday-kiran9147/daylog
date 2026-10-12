import 'package:flutter/material.dart';
import '../screens/auth_screen.dart';
import '../theme/daynote_theme.dart';
import '../viewmodels/auth_viewmodel.dart';

class AccountSheet extends StatelessWidget {
  final AuthViewModel authViewModel;
  final VoidCallback? onOpenWalkthrough;

  const AccountSheet({
    super.key,
    required this.authViewModel,
    this.onOpenWalkthrough,
  });

  static Future<void> show(
    BuildContext context, {
    required AuthViewModel authViewModel,
    VoidCallback? onOpenWalkthrough,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: DayNoteTheme.cardBackground(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => AccountSheet(
        authViewModel: authViewModel,
        onOpenWalkthrough: onOpenWalkthrough,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authViewModel.currentUser;
    final isAuthenticated = authViewModel.isAuthenticated;
    final email = user?.email ?? 'Offline Journal';
    final initial = isAuthenticated && email.isNotEmpty ? email[0].toUpperCase() : 'D';
    final dividerColor = DayNoteTheme.divider(context);
    final highlightBg = DayNoteTheme.surfaceHighlight(context);
    final primary = DayNoteTheme.textPrimary(context);
    final accent = DayNoteTheme.accent(context);
    final bg = DayNoteTheme.background(context);

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

                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DAYNOTE ACCOUNT',
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

                const SizedBox(height: 14),

                // User Info Card
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: highlightBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: dividerColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initial,
                          style: DayNoteTheme.heading(context).copyWith(
                            color: bg,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAuthenticated ? 'Signed in as' : 'Storage mode',
                              style: DayNoteTheme.caption(context).copyWith(
                                fontSize: 11,
                                color: DayNoteTheme.textTertiary(context),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isAuthenticated ? email : 'Local Offline Storage',
                              style: DayNoteTheme.body(context).copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              softWrap: true,
                            ),
                            if (!isAuthenticated)
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  'Your notes are saved securely on this device.',
                                  style: DayNoteTheme.caption(context).copyWith(
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // If not authenticated, show Sign In button
                if (!isAuthenticated) ...[
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: bg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    icon: const Icon(Icons.cloud_sync_outlined, size: 18),
                    label: Text(
                      'Sign In / Register for Cloud Sync',
                      style: DayNoteTheme.button(context).copyWith(
                        color: bg,
                        fontSize: 13.5,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      AuthScreen.show(context, authViewModel);
                    },
                  ),
                  const SizedBox(height: 10),
                ],

                if (onOpenWalkthrough != null) ...[
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DayNoteTheme.textPrimary(context),
                      side: BorderSide(color: dividerColor, width: 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    icon: Icon(Icons.help_outline, size: 18, color: accent),
                    label: Text(
                      'How to Use Daynote',
                      style: DayNoteTheme.button(context).copyWith(
                        color: DayNoteTheme.textPrimary(context),
                        fontSize: 13.5,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onOpenWalkthrough?.call();
                    },
                  ),
                  const SizedBox(height: 10),
                ],

                // Sign Out Button (if authenticated)
                if (isAuthenticated) ...[
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DayNoteTheme.priorityHigh(context),
                      side: BorderSide(color: DayNoteTheme.priorityHigh(context).withValues(alpha: 0.5), width: 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    icon: const Icon(Icons.logout, size: 18),
                    label: Text(
                      'Sign Out',
                      style: DayNoteTheme.button(context).copyWith(
                        color: DayNoteTheme.priorityHigh(context),
                        fontSize: 13.5,
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await authViewModel.signOut();
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
