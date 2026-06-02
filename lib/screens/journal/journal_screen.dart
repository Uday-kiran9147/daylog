// lib/screens/journal/journal_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/journal_provider.dart';
import '../../providers/task_provider.dart';
import '../../utils/date_utils.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _q1 = TextEditingController();
  final _q2 = TextEditingController();
  final _q3 = TextEditingController();
  bool _saved = false;

  @override
  void dispose() {
    _q1.dispose(); _q2.dispose(); _q3.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_q1.text.trim().isEmpty) return;
    await ref.read(journalNotifierProvider.notifier).save(
      shipped: _q1.text.trim(),
      blockers: _q2.text.trim(),
      tomorrow: _q3.text.trim(),
    );
    setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    final journalAsync = ref.watch(journalNotifierProvider);
    final totalAsync = ref.watch(todayTotalSecondsProvider);

    return journalAsync.when(
      data: (existing) {
        // pre-fill if entry exists
        if (existing != null && !_saved) {
          _q1.text = existing.shipped;
          _q2.text = existing.blockers;
          _q3.text = existing.tomorrow;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('journal'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    friendlyDate(DateTime.now()),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF5F5E5A)),
                  ),
                ),
              ),
            ],
          ),
          body: _saved
              ? _SavedView(entry: existing)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    totalAsync.when(
                      data: (s) => s > 0
                          ? Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F1EF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${formatDuration(s)} tracked today',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF5F5E5A)),
                              ),
                            )
                          : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    _QuestionCard(
                      number: '01 / 03',
                      question: 'what did you do today?',
                      controller: _q1,
                      hint: 'features, fixes, progress…',
                    ),
                    const SizedBox(height: 10),
                    _QuestionCard(
                      number: '02 / 03',
                      question: 'what slowed you down?',
                      controller: _q2,
                      hint: 'blockers, bugs, distractions…',
                    ),
                    const SizedBox(height: 10),
                    _QuestionCard(
                      number: '03 / 03',
                      question: 'what\'s the priority tomorrow?',
                      controller: _q3,
                      hint: 'top 1-2 things to tackle…',
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1D9E75),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text('save journal entry', style: TextStyle(fontSize: 15)),
                    ),
                  ],
                ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String number;
  final String question;
  final TextEditingController controller;
  final String hint;

  const _QuestionCard({
    required this.number,
    required this.question,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x22000000), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: const TextStyle(fontSize: 11, color: Color(0xFF888780))),
          const SizedBox(height: 4),
          Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFB4B2A9)),
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedView extends StatelessWidget {
  final dynamic entry;
  const _SavedView({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFE1F5EE),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.check_rounded, color: Color(0xFF1D9E75), size: 28),
            ),
            const SizedBox(height: 16),
            const Text('journal saved', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            const Text('see you tomorrow', style: TextStyle(fontSize: 14, color: Color(0xFF888780))),
          ],
        ),
      ),
    );
  }
}
