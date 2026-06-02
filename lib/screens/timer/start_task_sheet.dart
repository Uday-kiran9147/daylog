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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('new task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'what are you working on?'),
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _start(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kCategories.map((cat) {
              final selected = cat == _category;
              return GestureDetector(
                onTap: () => setState(() => _category = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected ? categoryColor(cat).withOpacity(0.15) : const Color(0xFFF1F1EF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? categoryColor(cat) : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                      color: selected ? categoryColor(cat) : const Color(0xFF5F5E5A),
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
                backgroundColor: const Color(0xFF1D9E75),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('start timer', style: TextStyle(fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
