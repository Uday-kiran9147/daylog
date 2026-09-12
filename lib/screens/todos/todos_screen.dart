import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/todo_entry.dart';
import '../../providers/todo_provider.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';
import '../../widgets/daylog_widgets.dart';

class TodosScreen extends ConsumerStatefulWidget {
  const TodosScreen({super.key});

  @override
  ConsumerState<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends ConsumerState<TodosScreen> {
  bool _newTodoOpen = false;
  final _newTodoController = TextEditingController();
  bool _newTodoPriority = false;

  @override
  void dispose() {
    _newTodoController.dispose();
    super.dispose();
  }

  Future<void> _addInlineTodo() async {
    final text = _newTodoController.text.trim();
    if (text.isEmpty) return;
    await ref.read(todoProvider.notifier).addTodo(text, _newTodoPriority, null);
    if (mounted) {
      setState(() {
        _newTodoController.clear();
        _newTodoPriority = false;
        _newTodoOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final todosAsync = ref.watch(todoProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(todoProvider);
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Page Header
              DaylogPageHeader(
                title: 'Action Items',
                trailing: IconButton(
                  icon: const Icon(Icons.add_rounded, size: 22),
                  onPressed: () => _openAddTodoSheet(context),
                  tooltip: 'Add action item',
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Row: Pending, Done, High Priority
                    todosAsync.when(
                      data: (todos) {
                        final pending = todos.where((t) => !t.isCompleted).length;
                        final completed = todos.where((t) => t.isCompleted).length;
                        final highPriority = todos.where((t) => !t.isCompleted && t.isHighPriority).length;

                        return Row(
                          children: [
                            Expanded(
                              child: DaylogStatCard(
                                kicker: 'Pending',
                                value: '$pending',
                                isAccent: true,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DaylogStatCard(
                                kicker: 'Done',
                                value: '$completed',
                                isAccent: false,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DaylogStatCard(
                                kicker: 'Priority',
                                value: '$highPriority',
                                isAccent: false,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const SizedBox(height: 70),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 20),

                    // Todo Columns (Pending & Done)
                    todosAsync.when(
                      data: (todos) {
                        final pendingTodos = todos.where((t) => !t.isCompleted).toList();
                        final doneTodos = todos.where((t) => t.isCompleted).toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── TO DO SECTION ────────────────────────────────
                            Row(
                              children: [
                                Text(
                                  'To do',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF332D2A) : const Color(0xFFE8DFD3),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '${pendingTodos.length}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            if (pendingTodos.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'All caught up.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                              )
                            else
                              ...pendingTodos.map((todo) => _TodoItemCard(todo: todo)),

                            // Inline New Todo Box or "+ Add item" Button
                            if (_newTodoOpen) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: theme.cardTheme.color,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.0),
                                ),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: _newTodoController,
                                      autofocus: true,
                                      textCapitalization: TextCapitalization.sentences,
                                      decoration: const InputDecoration(
                                        hintText: 'New action item',
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      ),
                                      onSubmitted: (_) => _addInlineTodo(),
                                    ),
                                    const SizedBox(height: 10),
                                    InkWell(
                                      onTap: () => setState(() => _newTodoPriority = !_newTodoPriority),
                                      borderRadius: BorderRadius.circular(999),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 150),
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _newTodoPriority
                                              ? (isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(
                                            color: _newTodoPriority
                                                ? (isDark ? DaylogColors.darkAccent : DaylogColors.accent)
                                                : theme.colorScheme.outlineVariant,
                                            width: 1.0,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.flag_rounded,
                                              size: 14,
                                              color: _newTodoPriority
                                                  ? (isDark ? DaylogColors.darkAccent : DaylogColors.accent700)
                                                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Flag high priority',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: _newTodoPriority
                                                    ? (isDark ? DaylogColors.darkAccent : DaylogColors.accent700)
                                                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => setState(() => _newTodoOpen = false),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                              side: BorderSide(color: theme.colorScheme.outlineVariant),
                                            ),
                                            child: const Text('Cancel', style: TextStyle(fontSize: 13)),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: FilledButton(
                                            onPressed: _addInlineTodo,
                                            style: FilledButton.styleFrom(
                                              backgroundColor: theme.colorScheme.primary,
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                            ),
                                            child: const Text('Add', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 6),
                              OutlinedButton.icon(
                                onPressed: () => setState(() => _newTodoOpen = true),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                                  foregroundColor: theme.colorScheme.onSurface,
                                  backgroundColor: theme.cardTheme.color,
                                  minimumSize: const Size(double.infinity, 44),
                                ),
                                icon: const Icon(Icons.add_rounded, size: 16),
                                label: const Text('Add item', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ),
                            ],

                            const SizedBox(height: 24),

                            // ── DONE SECTION ─────────────────────────────────
                            Row(
                              children: [
                                Text(
                                  'Done',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF332D2A) : const Color(0xFFE8DFD3),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '${doneTodos.length}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            if (doneTodos.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'Nothing finished yet.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                              )
                            else
                              ...doneTodos.map((todo) => _TodoItemCard(todo: todo)),

                            const SizedBox(height: 100),
                          ],
                        );
                      },
                      loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                      error: (e, _) => Text('Error loading todos: $e'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddTodoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddTodoSheet(),
    );
  }
}

/// Single Todo Card (Pending or Completed)
class _TodoItemCard extends ConsumerWidget {
  final TodoEntry todo;

  const _TodoItemCard({required this.todo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isOverdue = todo.dueDate != null &&
        todo.dueDate!.isBefore(DateTime.now()) &&
        !todo.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.85),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox toggle
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(todoProvider.notifier).toggleTodoCompletion(todo.id);
            },
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 1, right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: todo.isCompleted ? DaylogColors.sage : Colors.transparent,
                border: Border.all(
                  color: todo.isCompleted
                      ? DaylogColors.sage
                      : (isDark ? Colors.white.withValues(alpha: 0.25) : theme.colorScheme.outline),
                  width: 1.5,
                ),
              ),
              child: todo.isCompleted
                  ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                  : null,
            ),
          ),

          // Title and tags
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                    color: todo.isCompleted
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.55)
                        : theme.colorScheme.onSurface,
                  ),
                ),
                if (!todo.isCompleted && (todo.isHighPriority || todo.dueDate != null)) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (todo.isHighPriority)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.flag_rounded,
                                size: 10,
                                color: isDark ? DaylogColors.darkAccent : DaylogColors.accent700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'High priority',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? DaylogColors.darkAccent : DaylogColors.accent700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (todo.dueDate != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isOverdue
                                ? (isDark ? const Color(0xFF4D1707) : DaylogColors.accent200)
                                : (isDark ? const Color(0xFF332D2A) : const Color(0xFFE8DFD3)),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            friendlyDate(todo.dueDate!),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: isOverdue
                                  ? (isDark ? DaylogColors.accent200 : DaylogColors.accent800)
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Delete Action
          Tooltip(
            message: 'Delete',
            child: InkWell(
              onTap: () async {
                final confirmed = await showDaylogConfirmSheet(
                  context: context,
                  title: 'Delete action item?',
                  message: 'Are you sure you want to delete "${todo.title}"?',
                  confirmLabel: 'Delete',
                  isDestructive: true,
                  icon: Icons.delete_outline_rounded,
                );
                if (confirmed == true) {
                  ref.read(todoProvider.notifier).deleteTodo(todo.id);
                }
              },
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal Sheet to Add Action Item
class _AddTodoSheet extends ConsumerStatefulWidget {
  const _AddTodoSheet();

  @override
  ConsumerState<_AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends ConsumerState<_AddTodoSheet> {
  final _controller = TextEditingController();
  bool _isHighPriority = false;
  DateTime? _dueDate;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    await ref.read(todoProvider.notifier).addTodo(title, _isHighPriority, _dueDate);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'New action item',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'What needs to be done?'),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => setState(() => _isHighPriority = !_isHighPriority),
            borderRadius: BorderRadius.circular(999),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _isHighPriority
                    ? (isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _isHighPriority
                      ? (isDark ? DaylogColors.darkAccent : DaylogColors.accent)
                      : theme.colorScheme.outlineVariant,
                  width: 1.0,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flag_rounded,
                    size: 16,
                    color: _isHighPriority
                        ? (isDark ? DaylogColors.darkAccent : DaylogColors.accent700)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Flag high priority',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _isHighPriority
                          ? (isDark ? DaylogColors.darkAccent : DaylogColors.accent700)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _dueDate ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => _dueDate = picked);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    _dueDate == null ? 'Set due date' : friendlyDate(_dueDate!),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface),
                  ),
                  const Spacer(),
                  if (_dueDate != null)
                    InkWell(
                      onTap: () => setState(() => _dueDate = null),
                      child: const Icon(Icons.clear_rounded, size: 16),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: const Text('Add', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
