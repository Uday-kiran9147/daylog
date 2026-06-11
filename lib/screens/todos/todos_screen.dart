import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/todo_entry.dart';
import '../../providers/todo_provider.dart';
import '../../utils/date_utils.dart';

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
      appBar: AppBar(
        title: const Text('Todos'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todoProvider);
        },
        child: todosAsync.when(
          data: (todos) {
            final activeTodos = todos.where((t) => !t.isCompleted).toList();
            final completedTodos = todos.where((t) => t.isCompleted).toList();

            if (todos.isEmpty) {
              return const _EmptyTodosState();
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: activeTodos.isEmpty
                      ? const KeyedSubtree(
                          key: ValueKey('empty_pending'),
                          child: _NoPendingState(),
                        )
                      : Column(
                          key: const ValueKey('pending_list'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pending Tasks (${activeTodos.length})',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _AnimatedCard(
                              child: Column(
                                children: activeTodos
                                    .map((todo) => _TodoRow(key: ValueKey(todo.id), todo: todo))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: completedTodos.isEmpty
                      ? const SizedBox.shrink(key: ValueKey('empty_completed'))
                      : Theme(
                          key: const ValueKey('completed_list'),
                          data: theme.copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            title: Text(
                              'Completed Tasks (${completedTodos.length})',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            tilePadding: EdgeInsets.zero,
                            childrenPadding: EdgeInsets.zero,
                            initiallyExpanded: false,
                            children: [
                              _AnimatedCard(
                                child: Column(
                                  children: completedTodos
                                      .map((todo) => _TodoRow(key: ValueKey(todo.id), todo: todo))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const _AddTodoSheet(),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Add Todo'),
      ),
    );
  }
}

class _TodoRow extends ConsumerStatefulWidget {
  final TodoEntry todo;
  const _TodoRow({required this.todo, super.key});

  @override
  ConsumerState<_TodoRow> createState() => _TodoRowState();
}

class _TodoRowState extends ConsumerState<_TodoRow> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _sizeFactorAnimation;

  bool _isExiting = false;
  late bool _localCompletedValue;

  @override
  void initState() {
    super.initState();
    _localCompletedValue = widget.todo.isCompleted;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
    );

    _sizeFactorAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInOut,
    );

    // Fade and slide/grow in on creation
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant _TodoRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isExiting && widget.todo.isCompleted != oldWidget.todo.isCompleted) {
      _localCompletedValue = widget.todo.isCompleted;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleToggle() async {
    if (_isExiting) return;

    setState(() {
      _isExiting = true;
      _localCompletedValue = !_localCompletedValue;
    });

    // Animate item disappearing before updating provider
    await _animationController.reverse();

    if (mounted) {
      await ref.read(todoProvider.notifier).toggleTodoCompletion(widget.todo.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizeTransition(
      sizeFactor: _sizeFactorAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Dismissible(
          key: ValueKey(widget.todo.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: theme.colorScheme.errorContainer,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.delete, color: theme.colorScheme.onErrorContainer),
          ),
          confirmDismiss: (_) => _showDeleteConfirmDialog(context),
          onDismissed: (_) {
            ref.read(todoProvider.notifier).deleteTodo(widget.todo.id);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                _AnimatedCheckbox(
                  value: _localCompletedValue,
                  onChanged: (_) => _handleToggle(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: _AnimatedStrikeThroughText(
                              text: widget.todo.title,
                              isCompleted: _localCompletedValue,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: widget.todo.isHighPriority ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (widget.todo.isHighPriority && !_localCompletedValue) ...[
                            const SizedBox(width: 8),
                            const _PulseBadge(),
                          ],
                        ],
                      ),
                      if (widget.todo.dueDate != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 11,
                              color: dueDateColor(widget.todo.dueDate!, _localCompletedValue, theme.colorScheme),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formatDueDate(widget.todo.dueDate!),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: dueDateColor(widget.todo.dueDate!, _localCompletedValue, theme.colorScheme),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _AnimatedCheckbox({
    required this.value,
    required this.onChanged,
  });

  @override
  State<_AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<_AnimatedCheckbox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.85).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 0.85, end: 1.1).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 30),
    ]).animate(_controller);

    _checkScaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
    );

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.value
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.6),
              width: 2,
            ),
            color: widget.value
                ? theme.colorScheme.primary
                : Colors.transparent,
          ),
          child: ScaleTransition(
            scale: _checkScaleAnimation,
            child: Icon(
              Icons.check,
              size: 14,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedStrikeThroughText extends StatefulWidget {
  final String text;
  final bool isCompleted;
  final TextStyle style;

  const _AnimatedStrikeThroughText({
    required this.text,
    required this.isCompleted,
    required this.style,
  });

  @override
  State<_AnimatedStrikeThroughText> createState() => _AnimatedStrikeThroughTextState();
}

class _AnimatedStrikeThroughTextState extends State<_AnimatedStrikeThroughText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (widget.isCompleted) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedStrikeThroughText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted != oldWidget.isCompleted) {
      if (widget.isCompleted) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      style: widget.style.copyWith(
        color: widget.isCompleted
            ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
            : theme.colorScheme.onSurface,
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            foregroundPainter: _StrikeThroughPainter(
              progress: _animation.value,
              color: widget.isCompleted
                  ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                  : theme.colorScheme.primary.withValues(alpha: 0.6),
              strokeWidth: 1.5,
            ),
            child: child,
          );
        },
        child: Text(
          widget.text,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _StrikeThroughPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _StrikeThroughPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final y = size.height / 2 + 1;
    final endX = size.width * progress;

    canvas.drawLine(Offset(0, y), Offset(endX, y), paint);
  }

  @override
  bool shouldRepaint(covariant _StrikeThroughPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _PulseBadge extends StatefulWidget {
  const _PulseBadge();

  @override
  State<_PulseBadge> createState() => _PulseBadgeState();
}

class _PulseBadgeState extends State<_PulseBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.error.withValues(alpha: 0.1),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.priority_high_rounded, size: 10, color: theme.colorScheme.error),
            const SizedBox(width: 2),
            Text(
              'HIGH',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCard extends StatelessWidget {
  final Widget child;
  const _AnimatedCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: child,
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
              size: 64,
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'All clean!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'No todos listed yet. Add your tasks here to stay organized.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoPendingState extends StatelessWidget {
  const _NoPendingState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.done_all_rounded,
              size: 36,
              color: theme.colorScheme.primary.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 12),
            const Text(
              'No pending todos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Everything is done. Time to relax or add a new task!',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
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
              const Text('Add Todo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          // High priority toggle
          SwitchListTile.adaptive(
            title: Row(
              children: [
                Icon(
                  Icons.priority_high_rounded,
                  color: _isHighPriority ? theme.colorScheme.error : theme.colorScheme.outline,
                ),
                const SizedBox(width: 8),
                const Text('High Priority', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
            subtitle: const Text('Hourly reminders will trigger for this task', style: TextStyle(fontSize: 12)),
            contentPadding: EdgeInsets.zero,
            value: _isHighPriority,
            activeColor: theme.colorScheme.primary,
            activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            onChanged: (val) {
              setState(() {
                _isHighPriority = val;
              });
            },
          ),
          const Divider(height: 24, thickness: 0.5),
          // Due date picker
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Due Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      Text(
                        _dueDate == null ? 'No due date set' : formatDueDate(_dueDate!),
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
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.date_range_rounded, size: 18),
                    label: Text(_dueDate == null ? 'Set Date' : 'Change'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add Todo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
