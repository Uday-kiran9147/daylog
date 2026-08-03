// lib/screens/todos/todos_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/todo_entry.dart';
import '../../providers/todo_provider.dart';
import '../../utils/date_utils.dart';
import '../../widgets/notion_widgets.dart';

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
              // Compact Header
              NotionPageHeader(
                icon: Icons.check_box_rounded,
                title: 'Action Items',
                subtitle: 'Manage priorities, deadlines, and quick tasks.',
                trailingActions: IconButton(
                  icon: const Icon(Icons.add_rounded, size: 20),
                  tooltip: 'Add Action Item',
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const _AddTodoSheet(),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic Stats Row
                    todosAsync.when(
                      data: (todos) {
                        final pending = todos.where((t) => !t.isCompleted).length;
                        final completed = todos.where((t) => t.isCompleted).length;
                        final highPriority = todos.where((t) => !t.isCompleted && t.isHighPriority).length;

                        return Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: 'Pending',
                                value: '$pending',
                                icon: Icons.pending_actions_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatCard(
                                label: 'Completed',
                                value: '$completed',
                                icon: Icons.task_alt_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatCard(
                                label: 'High Priority',
                                value: '$highPriority',
                                icon: Icons.priority_high_rounded,
                                isWarning: highPriority > 0,
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 20),

                    // Vertical Action Items Board
                    const _TodosKanbanBoardSection(),

                    const SizedBox(height: 80),
                  ],
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
        label: const Text('Add Task', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isWarning;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isWarning ? theme.colorScheme.error : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isWarning
            ? theme.colorScheme.errorContainer.withValues(alpha: 0.2)
            : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isWarning
              ? theme.colorScheme.error.withValues(alpha: 0.3)
              : theme.colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isWarning ? theme.colorScheme.error : theme.colorScheme.onSurface,
                ),
              ),
              Icon(icon, size: 14, color: color.withValues(alpha: 0.8)),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isWarning ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Vertically Scrolling Action Items Kanban Board
class _TodosKanbanBoardSection extends ConsumerWidget {
  const _TodosKanbanBoardSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoProvider);

    return todosAsync.when(
      data: (todos) {
        final pending = todos.where((t) => !t.isCompleted).toList();
        final completed = todos.where((t) => t.isCompleted).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildColumn(
                      context,
                      ref,
                      title: 'To Do',
                      count: pending.length,
                      color: Theme.of(context).colorScheme.primary,
                      items: pending,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildColumn(
                      context,
                      ref,
                      title: 'Done',
                      count: completed.length,
                      color: Colors.green,
                      items: completed,
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _buildColumn(
                  context,
                  ref,
                  title: 'To Do',
                  count: pending.length,
                  color: Theme.of(context).colorScheme.primary,
                  items: pending,
                ),
                const SizedBox(height: 16),
                _buildColumn(
                  context,
                  ref,
                  title: 'Done',
                  count: completed.length,
                  color: Colors.green,
                  items: completed,
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading tasks: $e')),
    );
  }

  Widget _buildColumn(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required int count,
    required Color color,
    required List<TodoEntry> items,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  title == 'To Do' ? 'No pending tasks!' : 'No completed tasks yet.',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
            )
          else
            Column(
              children: items.map((todo) => _buildTodoCard(context, ref, todo)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTodoCard(BuildContext context, WidgetRef ref, TodoEntry todo) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: todo.isHighPriority && !todo.isCompleted
              ? theme.colorScheme.error.withValues(alpha: 0.5)
              : theme.colorScheme.outlineVariant,
          width: todo.isHighPriority && !todo.isCompleted ? 1.0 : 0.5,
        ),
      ),
      child: InkWell(
        onTap: () => ref.read(todoProvider.notifier).toggleTodoCompletion(todo.id),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Checkbox(
                value: todo.isCompleted,
                onChanged: (_) => ref.read(todoProvider.notifier).toggleTodoCompletion(todo.id),
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                        color: todo.isCompleted
                            ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    if (todo.dueDate != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 11,
                            color: todo.dueDate!.isBefore(DateTime.now()) && !todo.isCompleted
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            friendlyDate(todo.dueDate!),
                            style: TextStyle(
                              fontSize: 10,
                              color: todo.dueDate!.isBefore(DateTime.now()) && !todo.isCompleted
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (todo.isHighPriority && !todo.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'HIGH',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
                onPressed: () => ref.read(todoProvider.notifier).deleteTodo(todo.id),
              ),
            ],
          ),
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

  Future<void> _submit() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    await ref.read(todoProvider.notifier).addTodo(
      title,
      _isHighPriority,
      _dueDate,
    );

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
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'What needs to be done?',
              prefixIcon: Icon(Icons.playlist_add_check_rounded),
            ),
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.text,
            onSubmitted: (_) => _submit(),
          ),
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
            value: _isHighPriority,
            onChanged: (val) => setState(() => _isHighPriority = val),
            activeTrackColor: theme.colorScheme.error,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.calendar_today_rounded,
              color: _dueDate != null ? theme.colorScheme.primary : theme.colorScheme.outline,
            ),
            title: Text(
              _dueDate == null ? 'Set Due Date' : friendlyDate(_dueDate!),
              style: TextStyle(
                fontSize: 14,
                fontWeight: _dueDate != null ? FontWeight.bold : FontWeight.normal,
                color: _dueDate != null ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              ),
            ),
            trailing: _dueDate != null
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () => setState(() => _dueDate = null),
                  )
                : null,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _dueDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() => _dueDate = picked);
              }
            },
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Add Task', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
