import 'package:flutter/material.dart';
import '../theme/daynote_theme.dart';

class OnboardingDialog extends StatefulWidget {
  final VoidCallback onStartBlank;
  final VoidCallback onStartWithSample;

  const OnboardingDialog({
    super.key,
    required this.onStartBlank,
    required this.onStartWithSample,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onStartBlank,
    required VoidCallback onStartWithSample,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => OnboardingDialog(
        onStartBlank: () {
          Navigator.of(ctx).pop();
          onStartBlank();
        },
        onStartWithSample: () {
          Navigator.of(ctx).pop();
          onStartWithSample();
        },
      ),
    );
  }

  @override
  State<OnboardingDialog> createState() => _OnboardingDialogState();
}

class _OnboardingDialogState extends State<OnboardingDialog> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _steps = [
    {
      'icon': Icons.calendar_today_outlined,
      'title': 'The Daily Calendar',
      'subtitle': 'One single page, organized one day at a time',
      'description':
          'Tap any day on the monthly calendar grid to open that day instantly. Days with notes or tasks are marked with a subtle ink dot (•).',
    },
    {
      'icon': Icons.checklist_rounded,
      'title': 'Prioritized Daily Tasks',
      'subtitle': 'Focus on what matters most today',
      'description':
          'Add checklist items and set priority levels (High, Medium, Low) with a single tap. Tick tasks off as you go throughout your day.',
    },
    {
      'icon': Icons.edit_note_rounded,
      'title': 'Quiet Writing Surface',
      'subtitle': 'Distraction-free daily journaling',
      'description':
          'Record your reflections, journal entries, and thoughts on the warm paper surface. Everything is auto-saved as you type.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor = DayNoteTheme.divider(context);
    final primary = DayNoteTheme.textPrimary(context);
    final bg = DayNoteTheme.background(context);
    final accent = DayNoteTheme.accent(context);

    return Dialog(
      backgroundColor: DayNoteTheme.cardBackground(context),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: dividerColor, width: 1.2),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Brand Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'D',
                      style: DayNoteTheme.button(context).copyWith(
                        color: bg,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'WELCOME TO DAYNOTE',
                    style: DayNoteTheme.sectionTitle(context).copyWith(
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Walkthrough Carousel
              SizedBox(
                height: 250,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: DayNoteTheme.surfaceHighlight(context),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: dividerColor),
                            ),
                            child: Icon(
                              step['icon'] as IconData,
                              size: 26,
                              color: accent,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            step['title'] as String,
                            style: DayNoteTheme.heading(context).copyWith(
                              fontSize: 17.5,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            step['subtitle'] as String,
                            style: DayNoteTheme.caption(context).copyWith(
                              color: accent,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            step['description'] as String,
                            style: DayNoteTheme.body(context).copyWith(
                              fontSize: 13,
                              color: DayNoteTheme.textSecondary(context),
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Page Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _steps.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == index ? 16 : 6,
                    height: 5,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? accent
                          : dividerColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Divider(height: 1, color: dividerColor),
              const SizedBox(height: 16),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: bg,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: widget.onStartWithSample,
                  child: Text(
                    'Explore with Sample Entries',
                    style: DayNoteTheme.button(context).copyWith(
                      color: bg,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: DayNoteTheme.textSecondary(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: widget.onStartBlank,
                  child: Text(
                    'Start with Blank Journal',
                    style: DayNoteTheme.button(context).copyWith(
                      color: DayNoteTheme.textSecondary(context),
                      fontSize: 13,
                    ),
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
