// lib/screens/timer/edit_task_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_entry.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';

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
    _category = widget.task.category;
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
      if (mounted) Navigator.pop(context);
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
          const Text('Edit Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Task Name'),
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kCategories.map((cat) {
              final selected = cat == _category;
              final catColor = categoryColor(cat);
              return Material(
                color: selected ? catColor.withValues(alpha: 0.15) : theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () => setState(() => _category = cat),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? catColor : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      capitalizeCategory(cat),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                        color: selected ? catColor : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
