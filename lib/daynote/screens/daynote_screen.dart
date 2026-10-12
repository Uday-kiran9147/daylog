import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/daynote_providers.dart';
import '../theme/daynote_theme.dart';
import '../widgets/account_sheet.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/daynote_app_bar.dart';
import '../widgets/empty_day_view.dart';
import '../widgets/note_section.dart';
import '../widgets/onboarding_dialog.dart';
import '../widgets/selected_date_header.dart';
import '../widgets/todo_section.dart';

class DayNoteScreen extends ConsumerStatefulWidget {
  const DayNoteScreen({super.key});

  @override
  ConsumerState<DayNoteScreen> createState() => _DayNoteScreenState();
}

class _DayNoteScreenState extends ConsumerState<DayNoteScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _forceShowTodoInput = false;
  bool _forceFocusNote = false;
  bool _hasCheckedOnboarding = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _checkAndShowOnboarding() {
    final vm = ref.read(dayNoteViewModelProvider);
    if (vm.shouldShowOnboarding && !_hasCheckedOnboarding && mounted) {
      _hasCheckedOnboarding = true;
      OnboardingDialog.show(
        context,
        onStartBlank: () {
          if (!mounted) return;
          ref.read(dayNoteViewModelProvider).dismissOnboarding(loadSampleData: false);
        },
        onStartWithSample: () {
          if (!mounted) return;
          ref.read(dayNoteViewModelProvider).dismissOnboarding(loadSampleData: true);
        },
      );
    }
  }

  void _showWalkthroughManual() {
    OnboardingDialog.show(
      context,
      onStartBlank: () {
        if (!mounted) return;
        ref.read(dayNoteViewModelProvider).dismissOnboarding(loadSampleData: false);
      },
      onStartWithSample: () {
        if (!mounted) return;
        ref.read(dayNoteViewModelProvider).dismissOnboarding(loadSampleData: true);
      },
    );
  }

  void _scrollToContent() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          280.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(dayNoteViewModelProvider);
    final authViewModel = ref.watch(dayNoteAuthProvider);

    // Check onboarding once VM is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowOnboarding();
    });

    if (vm.isLoading) {
      return Scaffold(
        backgroundColor: DayNoteTheme.background(context),
        body: Center(
          child: CircularProgressIndicator(
            color: DayNoteTheme.accent(context),
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    final entry = vm.currentEntry;
    final hasTodos = entry.todos.isNotEmpty;
    final hasNotes = entry.note.trim().isNotEmpty;
    final isEmptyDay = !hasTodos && !hasNotes && !_forceShowTodoInput && !_forceFocusNote;

    final bg = DayNoteTheme.background(context);
    final dividerColor = DayNoteTheme.divider(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                children: [
                  // Refined Top App Bar
                  DaynoteAppBar(
                    authViewModel: authViewModel,
                    onGoToToday: vm.goToToday,
                    isTodaySelected: vm.isSelectedDateToday,
                  ),

                  // Main Scrollable Content
                  Expanded(
                    child: CustomScrollView(
                      controller: _scrollController,
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        // 1 & 2: Month & Calendar Grid
                        SliverToBoxAdapter(
                          child: CalendarWidget(
                            currentMonth: vm.currentMonth,
                            selectedDate: vm.selectedDate,
                            datesWithContent: vm.datesWithContent,
                            onDateSelected: (date) {
                              setState(() {
                                _forceShowTodoInput = false;
                                _forceFocusNote = false;
                              });
                              vm.selectDate(date);
                            },
                            onPreviousMonth: vm.previousMonth,
                            onNextMonth: vm.nextMonth,
                            onMonthYearChanged: vm.setMonthYear,
                            onGoToToday: vm.goToToday,
                            onOpenAccount: () => AccountSheet.show(
                              context,
                              authViewModel: authViewModel,
                              onOpenWalkthrough: _showWalkthroughManual,
                            ),
                          ),
                        ),

                        // 3: Selected Date Separator & Prominent Date Header
                        SliverToBoxAdapter(
                          child: SelectedDateHeader(
                            date: vm.selectedDate,
                            isToday: vm.isSelectedDateToday,
                          ),
                        ),

                        // 4: Daily Content (Empty State or Todos & Notes)
                        if (isEmptyDay) ...[
                          SliverToBoxAdapter(
                            child: EmptyDayView(
                              onAddTodo: () {
                                setState(() {
                                  _forceShowTodoInput = true;
                                });
                                _scrollToContent();
                              },
                              onAddNote: () {
                                setState(() {
                                  _forceFocusNote = true;
                                });
                                _scrollToContent();
                              },
                            ),
                          ),
                        ] else ...[
                          // TODO Section (Shown if has todos or if user clicked Add Todo)
                          SliverToBoxAdapter(
                            child: TodoSection(
                              todos: entry.todos,
                              isAddingInitial: _forceShowTodoInput,
                              onAddTodo: (text, priority) {
                                vm.addTodo(text, priority: priority);
                                setState(() {
                                  _forceShowTodoInput = false;
                                });
                              },
                              onToggleTodo: vm.toggleTodo,
                              onUpdateTodo: vm.updateTodoText,
                              onUpdatePriority: vm.updateTodoPriority,
                              onDeleteTodo: vm.deleteTodo,
                              onCancelAdd: () {
                                setState(() {
                                  _forceShowTodoInput = false;
                                });
                              },
                            ),
                          ),

                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Divider(height: 1, color: dividerColor),
                            ),
                          ),

                          // NOTES Section (Shown always when not empty or when activated)
                          SliverToBoxAdapter(
                            child: NoteSection(
                              key: ValueKey('note_${entry.dateKey}'),
                              dateKey: entry.dateKey,
                              note: entry.note,
                              autoFocus: _forceFocusNote,
                              onNoteChanged: vm.onNoteChanged,
                            ),
                          ),
                        ],

                        // Extra bottom padding so dock and keyboard never occlude inputs
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 140),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
