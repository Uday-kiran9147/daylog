// lib/screens/timer/start_task_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_entry.dart';
import '../../providers/task_provider.dart';
import '../../providers/todo_provider.dart';
import '../../providers/user_settings_provider.dart';
import '../../utils/constants.dart';

class StartTaskSheet extends ConsumerStatefulWidget {
  final ValueChanged<TaskEntry>? onTaskStarted;

  const StartTaskSheet({super.key, this.onTaskStarted});

  @override
  ConsumerState<StartTaskSheet> createState() => _StartTaskSheetState();
}

class _StartTaskSheetState extends ConsumerState<StartTaskSheet> {
  final _controller = TextEditingController();
  String? _detectedCategory;
  String? _selectedCategory;

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
    final text = _controller.text.toLowerCase();
    if (text.trim().isEmpty) {
      if (_detectedCategory != null) setState(() => _detectedCategory = null);
      return;
    }

    String? found;
    for (final entry in kCategoryData.entries) {
      if (entry.value.keywords.any((kw) => text.contains(kw.toLowerCase()))) {
        found = entry.key;
        break;
      }
    }

    if (found != _detectedCategory) {
      setState(() => _detectedCategory = found);
    }
  }

  Future<void> _start(String title, [String? category]) async {
    final t = title.trim();
    if (t.isEmpty) return;
    final userCats = ref.read(userCategoriesProvider);
    final fallbackCat = userCats.isNotEmpty ? userCats.first : 'Development';
    final cat = category ?? _selectedCategory ?? _detectedCategory ?? fallbackCat;
    final task = await ref.read(activeTaskProvider.notifier).startTask(t, cat);
    if (mounted) {
      Navigator.of(context).pop();
      widget.onTaskStarted?.call(task);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final recentAsync = ref.watch(recentTasksProvider);
    final userCategories = ref.watch(userCategoriesProvider);

    final effectiveCat = _selectedCategory ?? _detectedCategory ?? (userCategories.isNotEmpty ? userCategories.first : 'Development');

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
          // Grab handle
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

          // Title
          Text(
            'New focus session',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),

          // Scrollable content area
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input field
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(fontSize: 15, color: theme.colorScheme.onSurface),
                    decoration: const InputDecoration(
                      hintText: 'What are you working on?',
                    ),
                    onSubmitted: (val) => _start(val),
                  ),

                  // Category Chips Row
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: userCategories.map((cat) {
                        final isSelected = effectiveCat.toLowerCase() == cat.toLowerCase();
                        final info = getCategoryInfo(cat);
                        final bg = isDark ? info.darkBg : info.lightBg;
                        final fg = isDark ? info.darkFg : info.lightFg;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => setState(() => _selectedCategory = cat),
                            borderRadius: BorderRadius.circular(999),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? bg : theme.cardTheme.color,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark ? DaylogColors.darkAccent : DaylogColors.accent)
                                      : theme.colorScheme.outlineVariant,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(info.icon, size: 14, color: isSelected ? fg : theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                  const SizedBox(width: 6),
                                  Text(
                                    capitalizeCategory(cat),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? fg : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Action items quick-start
                  ref.watch(todoProvider).when(
                    data: (todos) {
                      final pending = todos
                          .where((t) => !t.isCompleted)
                          .toList()
                        ..sort((a, b) {
                          if (a.isHighPriority && !b.isHighPriority) return -1;
                          if (!a.isHighPriority && b.isHighPriority) return 1;
                          return 0;
                        });
                      if (pending.isEmpty) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From your action items',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: pending.take(4).map((todo) {
                                return InkWell(
                                  onTap: () {
                                    _controller.text = todo.title;
                                    _start(todo.title);
                                  },
                                  borderRadius: BorderRadius.circular(999),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: isDark ? DaylogColors.darkAccent : DaylogColors.accent,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (todo.isHighPriority) ...[
                                          Icon(
                                            Icons.flag_rounded,
                                            size: 12,
                                            color: isDark ? DaylogColors.darkAccent : DaylogColors.accent700,
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                        Flexible(
                                          child: Text(
                                            todo.title,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: isDark ? DaylogColors.darkAccent : DaylogColors.accent700,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  // Quick start recent chips
                  recentAsync.when(
                    data: (tasks) {
                      final uniqueTitles = <String>{};
                      final chips = <TaskEntry>[];
                      for (final t in tasks) {
                        if (!uniqueTitles.contains(t.title)) {
                          uniqueTitles.add(t.title);
                          chips.add(t);
                        }
                      }

                      if (chips.isEmpty) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: chips.take(4).map((t) {
                            return InkWell(
                              onTap: () {
                                _controller.text = t.title;
                                _detectedCategory = t.category;
                                _start(t.title, t.category);
                              },
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.cardTheme.color,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.0),
                                ),
                                child: Text(
                                  t.title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Action buttons: Cancel & Start
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1.0),
                    foregroundColor: theme.colorScheme.onSurface,
                    backgroundColor: theme.cardTheme.color,
                  ),
                  child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) {
                    final isEnabled = value.text.trim().isNotEmpty;
                    return FilledButton(
                      onPressed: isEnabled ? () => _start(value.text) : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Start', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
