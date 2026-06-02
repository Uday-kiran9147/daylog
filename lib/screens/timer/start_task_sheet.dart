// lib/screens/timer/start_task_sheet.dart
import 'package:daylog/models/task_entry.dart';
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
  bool _userChangedCategory = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_userChangedCategory) return;

    final text = _controller.text.toLowerCase();
    
    // Auto-detect category based on keywords
    String? detected;
    if (RegExp(r'\b(backend|api|server|db|database|docker|sql|postgres|mysql|graphql|node|deno|go|rust|golang|django|python|spring)\b').hasMatch(text)) {
      detected = 'backend';
    } else if (RegExp(r'\b(mobile|flutter|ios|android|app|swift|kotlin|dart|java|objc|flutterw|apk|ipa|flutterflow|widget|screen|view|ui)\b').hasMatch(text)) {
      detected = 'mobile';
    } else if (RegExp(r'\b(content|write|blog|video|post|tweet|social|design|figma|youtube|article|newsletter|script|edit|podcast)\b').hasMatch(text)) {
      detected = 'content';
    } else if (RegExp(r'\b(job|apply|interview|resume|cv|portfolio|hr|recruiter|hunt|career|linkedin|jobseek|application)\b').hasMatch(text)) {
      detected = 'job hunt';
    }

    if (detected != null && detected != _category) {
      setState(() {
        _category = detected!;
      });
    }
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
    final recentAsync = ref.watch(recentTasksProvider);

    // Filter recent tasks for quick suggestion matching
    final query = _controller.text.trim().toLowerCase();
    List<TaskEntry> suggestions = [];
    if (recentAsync.hasValue) {
      final allRecent = recentAsync.value ?? [];
      final seen = <String>{};
      final uniqueRecent = <TaskEntry>[];
      for (final t in allRecent) {
        if (!seen.contains(t.title)) {
          seen.add(t.title);
          uniqueRecent.add(t);
        }
      }

      if (query.isEmpty) {
        suggestions = uniqueRecent.take(3).toList();
      } else {
        suggestions = uniqueRecent
            .where((t) => t.title.toLowerCase().contains(query))
            .take(3)
            .toList();
      }
    }

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
          
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              query.isEmpty ? 'Recent tasks' : 'Suggested tasks',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestions.map((t) {
                return ActionChip(
                  avatar: CircleAvatar(
                    radius: 5,
                    backgroundColor: categoryColor(t.category),
                  ),
                  label: Text(t.title, style: const TextStyle(fontSize: 12)),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    _controller.text = t.title;
                    _category = t.category;
                    _userChangedCategory = true;
                    _start();
                  },
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 16),
          Text(
            'Category',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 6),
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
                  onTap: () {
                    setState(() {
                      _category = cat;
                      _userChangedCategory = true;
                    });
                  },
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
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) {
                final isEnabled = value.text.trim().isNotEmpty;
                return FilledButton(
                  onPressed: isEnabled ? _start : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Start Timer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
