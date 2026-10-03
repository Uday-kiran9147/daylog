// lib/widgets/focus_victory_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_entry.dart';
import '../providers/journal_provider.dart';
import '../services/ad_service.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';
import 'daylog_widgets.dart';

/// Celebratory modal shown when a focus session ends, allowing 1-tap logging into daily reflection.
class FocusVictoryModal extends ConsumerStatefulWidget {
  final TaskEntry task;
  final int completedSeconds;
  final VoidCallback? onDismiss;

  const FocusVictoryModal({
    super.key,
    required this.task,
    required this.completedSeconds,
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required TaskEntry task,
    required int completedSeconds,
    VoidCallback? onDismiss,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => FocusVictoryModal(
        task: task,
        completedSeconds: completedSeconds,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  ConsumerState<FocusVictoryModal> createState() => _FocusVictoryModalState();
}

class _FocusVictoryModalState extends ConsumerState<FocusVictoryModal> {
  bool _isLogged = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final formattedTime = formatDuration(widget.completedSeconds);

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1B18) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Celebration Icon with Glow
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? DaylogColors.darkAccent : DaylogColors.accent,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? DaylogColors.darkAccent : DaylogColors.accent)
                          .withValues(alpha: 0.30),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 30)),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Focus Session Complete!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Every focused block compounds into mastery.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Stats summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF28231E) : const Color(0xFFFAF7F2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                    width: 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.task.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        CategoryTag(category: widget.task.category, isDark: isDark),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? DaylogColors.darkAccent : DaylogColors.accent700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 1-Tap Reflection Append Button
              InkWell(
                onTap: _isLogged
                    ? null
                    : () async {
                        HapticFeedback.mediumImpact();
                        final textToAppend = 'Completed $formattedTime focus sprint on "${widget.task.title}" (${widget.task.category})';
                        await ref.read(journalNotifierProvider.notifier).appendAccomplishment(textToAppend);
                        setState(() => _isLogged = true);
                        if (mounted && context.mounted) {
                          showDaylogToast(context, '✨ Added to today\'s reflection journal!');
                        }
                      },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _isLogged
                        ? const Color(0xFF1E3A2B).withValues(alpha: isDark ? 0.6 : 0.15)
                        : (isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isLogged
                          ? const Color(0xFF5B8266)
                          : (isDark ? DaylogColors.darkAccent : DaylogColors.accent),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isLogged ? Icons.check_circle_rounded : Icons.auto_stories_rounded,
                        size: 18,
                        color: _isLogged
                            ? const Color(0xFF75A082)
                            : (isDark ? DaylogColors.darkAccent : DaylogColors.accent700),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _isLogged
                              ? 'Logged in Today\'s Reflection'
                              : 'Add to Today\'s Reflection',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _isLogged
                                ? const Color(0xFF75A082)
                                : (isDark ? DaylogColors.darkAccent : DaylogColors.accent700),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Done Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pop();
                    widget.onDismiss?.call();
                    AdService.instance.showInterstitialAd(placement: 'timer_complete');
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: isDark ? DaylogColors.darkAccent : theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
