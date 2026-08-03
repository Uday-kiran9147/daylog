// lib/screens/todos/todos_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/todo_entry.dart';
import '../../providers/todo_provider.dart';
import '../../utils/date_utils.dart';
import '../../widgets/notion_widgets.dart';

Future<bool?> _showDeleteConfirmDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Todo?'),
      content: const Text('Are you sure you want to delete this todo? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

class TodosScreen extends ConsumerWidget {
  const TodosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(todoProvider);
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Modern Compact Header
              const NotionPageHeader(
                icon: Icons.task_alt_rounded,
                title: 'Action Items & Todos',
                subtitle: 'Manage daily focus tasks, high-priority items, and deadlines.',
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: todosAsync.when(
                  data: (todos) {
                    final activeTodos = todos.where((t) => !t.isCompleted).toList();
                    final completedTodos = todos.where((t) => t.isCompleted).toList();

                    if (todos.isEmpty) {
                      return const _EmptyTodosState();
                    }

                    // Vertical Grid Kanban Board View (To Do vs Done)
                    return _TodosKanbanBoardSection(
                      activeTodos: activeTodos,
                      completedTodos: completedTodos,
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (err, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Failed to load todos: $err',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const _AddTodoSheet(),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Add Todo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

/// Vertically Scrolling Kanban Columns (To Do vs Done)
class _TodosKanbanBoardSection extends ConsumerWidget {
  final List<TodoEntry> activeTodos;
  final List<TodoEntry> completedTodos;

  const _TodosKanbanBoardSection({
    required this.activeTodos,
    required this.completedTodos,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth > 550;

        if (useTwoColumns) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildKanbanColumn(
                  context,
                  ref,
                  title: 'To Do',
                  tagLabel: 'TO DO',
                  tagBg: theme.colorScheme.primaryContainer,
                  tagFg: theme.colorScheme.primary,
                  items: activeTodos,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildKanbanColumn(
                  context,
                  ref,
                  title: 'Done',
                  tagLabel: 'DONE',
                  tagBg: theme.colorScheme.surfaceContainer,
                  tagFg: theme.colorScheme.onSurfaceVariant,
                  items: completedTodos,
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            _buildKanbanColumn(
              context,
              ref,
              title: 'To Do',
              tagLabel: 'TO DO',
              tagBg: theme.colorScheme.primaryContainer,
              tagFg: theme.colorScheme.primary,
              items: activeTodos,
            ),
            const SizedBox(height: 16),
            _buildKanbanColumn(
              context,
              ref,
              title: 'Done',
              tagLabel: 'DONE',
              tagBg: theme.colorScheme.surfaceContainer,
              tagFg: theme.colorScheme.onSurfaceVariant,
              items: completedTodos,
            ),
            const SizedBox(height: 80),
          ],
        );
      },
    );
  }

  Widget _buildKanbanColumn(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String tagLabel,
    required Color tagBg,
    required Color tagFg,
    required List<TodoEntry> items,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NotionTag(label: tagLabel, customBg: tagBg, customText: tagFg),
              Text(
                '${items.length} items',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No items in $title',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                ),
              ),
            )
          else
            Column(
              children: items.map((todo) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => ref.read(todoProvider.notifier).toggleTodoCompletion(todo.id),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                todo.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                size: 18,
                                color: todo.isCompleted ? theme.colorScheme.primary : theme.colorScheme.outline,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  todo.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                    color: todo.isCompleted ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if ((todo.isHighPriority && !todo.isCompleted) || todo.dueDate != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (todo.isHighPriority && !todo.isCompleted) ...[
                                  const NotionTag(
                                    label: 'HIGH PRIORITY',
                                    customBg: Color(0xFFFFECEB),
                                    customText: Color(0xFFEB5757),
                                    icon: Icons.priority_high_rounded,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                if (todo.dueDate != null) ...[
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 11,
                                    color: dueDateColor(todo.dueDate!, todo.isCompleted, theme.colorScheme),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    formatDueDate(todo.dueDate!),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: dueDateColor(todo.dueDate!, todo.isCompleted, theme.colorScheme),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _EmptyTodosState extends StatelessWidget {
  const _EmptyTodosState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 56,
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Action Items Yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Add your todos here to track work items and stay organized.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

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

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    await ref.read(todoProvider.notifier).addTodo(title, _isHighPriority, _dueDate);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Add Action Item', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            title: Row(
              children: [
                Icon(
                  Icons.priority_high_rounded,
                  color: _isHighPriority ? theme.colorScheme.error : theme.colorScheme.outline,
                ),
                const SizedBox(width: 8),
                const Text('High Priority', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
            subtitle: const Text('Hourly reminder will notify until completed', style: TextStyle(fontSize: 12)),
            contentPadding: EdgeInsets.zero,
            value: _isHighPriority,
            activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.3),
            onChanged: (val) {
              setState(() {
                _isHighPriority = val;
              });
            },
          ),
          const Divider(height: 24, thickness: 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Due Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      Text(
                        _dueDate == null ? 'No date set' : formatDueDate(_dueDate!),
                        style: TextStyle(
                          fontSize: 12,
                          color: _dueDate == null
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.primary,
                          fontWeight: _dueDate == null ? FontWeight.normal : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  if (_dueDate != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _dueDate = null;
                        });
                      },
                      child: Text(
                        'Clear',
                        style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.date_range_rounded, size: 16),
                    label: Text(_dueDate == null ? 'Set Date' : 'Change', style: const TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) {
                final isEnabled = value.text.trim().isNotEmpty;
                return FilledButton(
                  onPressed: isEnabled ? _submit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Add Todo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
