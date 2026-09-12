// lib/screens/timer/edit_task_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_entry.dart';
import '../../providers/task_provider.dart';
import '../../providers/user_settings_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/daylog_widgets.dart';

class EditTaskSheet extends ConsumerStatefulWidget {
  final TaskEntry task;
  const EditTaskSheet({super.key, required this.task});

  @override
  ConsumerState<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends ConsumerState<EditTaskSheet> {
  late final TextEditingController _controller;
  late String _category;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task.title);
    _category = widget.task.category.isEmpty ? 'Development' : widget.task.category;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    final updated = widget.task
      ..title = title
      ..category = _category;

    try {
      await ref.read(activeTaskProvider.notifier).updateTask(updated);
      if (mounted) {
        Navigator.pop(context);
        showDaylogToast(context, 'Task updated');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDaylogConfirmSheet(
      context: context,
      title: 'Delete focus task?',
      message: 'Are you sure you want to delete "${widget.task.title}"?',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );

    if (confirmed != true) return;

    try {
      await ref.read(activeTaskProvider.notifier).deleteTask(widget.task.id);
      if (mounted) {
        Navigator.pop(context);
        showDaylogToast(context, 'Task deleted');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete task: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit Task',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                onPressed: _delete,
                tooltip: 'Delete task',
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Task Name'),
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 14),
          Text(
            'Category',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: () {
              final userCats = ref.watch(userCategoriesProvider);
              final set = <String>{...userCats};
              if (!set.contains(_category)) set.add(_category);
              return set.map((cat) {
                final selected = cat.toLowerCase() == _category.toLowerCase();
                final info = getCategoryInfo(cat);
                final bg = isDark ? info.darkBg : info.lightBg;
                final fg = isDark ? info.darkFg : info.lightFg;

                return InkWell(
                  onTap: () => setState(() => _category = cat),
                  borderRadius: BorderRadius.circular(999),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? bg : theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: selected
                            ? (isDark ? DaylogColors.darkAccent : DaylogColors.accent)
                            : theme.colorScheme.outlineVariant,
                        width: selected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(info.icon, size: 14, color: selected ? fg : theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                        const SizedBox(width: 6),
                        Text(
                          capitalizeCategory(cat),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                            color: selected ? fg : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList();
            }(),
          ),
          const SizedBox(height: 24),
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
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
