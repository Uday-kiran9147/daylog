// lib/screens/timer/start_task_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';

class StartTaskSheet extends ConsumerStatefulWidget {
  const StartTaskSheet({super.key});

  @override
  ConsumerState<StartTaskSheet> createState() => _StartTaskSheetState();
}

class _StartTaskSheetState extends ConsumerState<StartTaskSheet> {
  final _controller = TextEditingController();
  String _category = 'backend';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    await ref.read(activeTaskProvider.notifier).startTask(title, _category);
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
          const Text('New Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'What are you working on?'),
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _start(),
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
                        fontSize: 13,
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
              onPressed: _start,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Start Timer', style: TextStyle(fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
