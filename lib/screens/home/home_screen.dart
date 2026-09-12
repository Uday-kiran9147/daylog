import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../models/task_entry.dart';
import '../../providers/task_provider.dart';
import '../../services/ad_service.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';
import '../../widgets/daylog_widgets.dart';
import '../timer/start_task_sheet.dart';
import '../timer/edit_task_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onOpenTimerModal;

  const HomeScreen({super.key, this.onOpenTimerModal});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    // Preload interstitial for home transitions
    AdService.instance.preloadInterstitialAd(placement: 'home_screen_interstitial');
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      const size = AdSize.banner;

      _bannerAd?.dispose();
      _bannerAd = null;
      _isBannerLoaded = false;

      AdService.instance.createBannerAd(
        placement: 'home_screen_banner',
        size: size,
        onAdLoaded: (loadedAd) {
          if (mounted) {
            setState(() {
              _bannerAd = loadedAd;
              _isBannerLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint('[HomeScreen] Banner ad failed to load: $error');
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isBannerLoaded = false;
            });
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStr = 'Today · ${friendlyDate(now)}';
    final activeAsync = ref.watch(activeTaskProvider);
    final todayTasksAsync = ref.watch(todayTasksProvider);
    final recentAsync = ref.watch(recentTasksProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(todayTasksProvider);
            ref.invalidate(todayTotalSecondsProvider);
            ref.invalidate(recentTasksProvider);
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              if (_isBannerLoaded && _bannerAd != null)
                Center(
                  child: Container(
                    alignment: Alignment.center,
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
              DaylogPageHeader(
                title: 'DayLog',
                subtitle: todayStr,
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Active / Inactive Focus Session Hero
                    activeAsync.when(
                      data: (active) => active != null
                          ? _ActiveSessionHero(
                              task: active,
                              onOpenModal: widget.onOpenTimerModal)
                          : DashedStartSessionCard(
                              onTap: () => _openStartSheet(context, ref),
                            ),
                      loading: () => const SizedBox(height: 140),
                      error: (_, __) => DashedStartSessionCard(
                        onTap: () => _openStartSheet(context, ref),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Quick Stats Row
                    const _TodayStatsRow(),

                    const SizedBox(height: 22),

                    // Quick Start Recent Tasks
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

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick start',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: chips.take(4).map((t) {
                                return InkWell(
                                  onTap: () async {
                                    await ref
                                        .read(activeTaskProvider.notifier)
                                        .startTask(t.title, t.category);
                                    widget.onOpenTimerModal?.call();
                                  },
                                  borderRadius: BorderRadius.circular(999),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardTheme.color,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outlineVariant,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Text(
                                      t.title,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 22),
                          ],
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    // ── TODAY'S DETAILED LOGS SECTION ────────────────────────
                    todayTasksAsync.when(
                      data: (tasks) {
                        final active = activeAsync.valueOrNull;
                        final allTasks = <TaskEntry>[...tasks];
                        if (active != null &&
                            !allTasks.any((t) => t.id == active.id)) {
                          allTasks.insert(0, active);
                        }

                        // Sort most recent first
                        allTasks
                            .sort((a, b) => b.startedAt.compareTo(a.startedAt));
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Today's logs",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.75),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF332D2A)
                                        : const Color(0xFFE8DFD3),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '${allTasks.length}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.75),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (allTasks.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 24, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardTheme.color,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant,
                                      width: 1.0),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 32,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.35),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No focus sessions logged yet today.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Start a session above to track your work.',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.45),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ...allTasks.map(
                                (task) => _TaskDetailLogCard(
                                  task: task,
                                  onTap: () {
                                    if (task.isRunning) {
                                      widget.onOpenTimerModal?.call();
                                    } else {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) =>
                                            EditTaskSheet(task: task),
                                      );
                                    }
                                  },
                                  onRestart: () async {
                                    await ref
                                        .read(activeTaskProvider.notifier)
                                        .startTask(task.title, task.category);
                                    widget.onOpenTimerModal?.call();
                                  },
                                ),
                              ),
                          ],
                        );
                      },
                      loading: () => const Center(
                          child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator())),
                      error: (e, _) => Text('Error: $e'),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openStartSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StartTaskSheet(
        onTaskStarted: (_) => widget.onOpenTimerModal?.call(),
      ),
    );
  }
}

/// Detailed Task Log Item Card on Home Screen
class _TaskDetailLogCard extends StatelessWidget {
  final TaskEntry task;
  final VoidCallback onTap;
  final VoidCallback onRestart;

  const _TaskDetailLogCard({
    required this.task,
    required this.onTap,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final catInfo = getCategoryInfo(task.category);
    final timeRangeText = formatTimeRange(task.startedAt, task.stoppedAt);
    final isHighlighted = task.isRunning;

    final card = Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isHighlighted
            ? (isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100)
            : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlighted
              ? (isDark
                  ? DaylogColors.darkAccent.withValues(alpha: 0.55)
                  : DaylogColors.accent.withValues(alpha: 0.40))
              : (isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.85)),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                ? (isDark
                    ? DaylogColors.darkAccent.withValues(alpha: 0.25)
                    : DaylogColors.accent.withValues(alpha: 0.15))
                : Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: isHighlighted ? 18 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Category Icon with Circle Background
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? catInfo.darkBg : catInfo.lightBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  catInfo.icon,
                  size: 20,
                  color: isDark ? catInfo.darkFg : catInfo.lightFg,
                ),
              ),
              const SizedBox(width: 12),

              // Title, Category Tag, and Time Range
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        CategoryTag(category: task.category, isDark: isDark),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            timeRangeText,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.55),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Duration & Status / Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (task.isRunning)
                    _TickingCardActiveBadge(task: task, isDark: isDark)
                  else
                    Text(
                      formatDuration(task.durationSeconds),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.2,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  const SizedBox(height: 2),
                  if (!task.isRunning)
                    InkWell(
                      onTap: onRestart,
                      borderRadius: BorderRadius.circular(999),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.replay_rounded,
                              size: 13,
                              color: isDark
                                  ? DaylogColors.darkAccent
                                  : DaylogColors.accent700,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Restart',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? DaylogColors.darkAccent
                                    : DaylogColors.accent700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return isHighlighted ? RepaintBoundary(child: card) : card;
  }
}

/// Isolated Leaf for Active Running Task Card Duration Badge
class _TickingCardActiveBadge extends ConsumerWidget {
  final TaskEntry task;
  final bool isDark;

  const _TickingCardActiveBadge({
    required this.task,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!task.isPaused) {
      ref.watch(appTickerProvider);
    }
    final durationSec = task.currentElapsedSeconds;
    final durationText = formatDuration(durationSec);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? DaylogColors.darkAccent : DaylogColors.accent700,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PulsingDot(color: Colors.white, size: 6, isPaused: task.isPaused),
          const SizedBox(width: 6),
          Text(
            durationText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Active Session Hero Card
class _ActiveSessionHero extends ConsumerWidget {
  final TaskEntry task;
  final VoidCallback? onOpenModal;

  const _ActiveSessionHero({required this.task, this.onOpenModal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final heroColor =
        isDark ? DaylogColors.darkAccent : theme.colorScheme.primary;

    return RepaintBoundary(
      child: InkWell(
        onTap: onOpenModal,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: heroColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.32),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: heroColor.withValues(alpha: isDark ? 0.45 : 0.30),
                blurRadius: 28,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top indicator row: Pulsing dot + LIVE/PAUSED + Category Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.32),
                        width: 0.9,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PulsingDot(
                            color: Colors.white,
                            size: 7,
                            isPaused: task.isPaused),
                        const SizedBox(width: 7),
                        Text(
                          task.isPaused ? 'PAUSED' : 'FOCUSING',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CategoryTag(category: task.category, isDark: false),
                ],
              ),
              const SizedBox(height: 14),

              // Task Name
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Elapsed Clock (Isolated ticking leaf)
              _HeroTickingClock(task: task),
              const SizedBox(height: 14),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        if (task.isPaused) {
                          ref.read(activeTaskProvider.notifier).resumeActive();
                        } else {
                          ref.read(activeTaskProvider.notifier).pauseActive();
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.22),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: Icon(
                        task.isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        size: 18,
                      ),
                      label: Text(
                        task.isPaused ? 'Resume' : 'Pause',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        ref.read(activeTaskProvider.notifier).stopActive();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: DaylogColors.accent700,
                        elevation: 4,
                        shadowColor: Colors.black.withValues(alpha: 0.25),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.stop_rounded, size: 18),
                      label: const Text(
                        'Stop',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Isolated Leaf for Hero Big Clock
class _HeroTickingClock extends ConsumerWidget {
  final TaskEntry task;

  const _HeroTickingClock({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!task.isPaused) {
      ref.watch(appTickerProvider);
    }
    final elapsed = task.currentElapsedSeconds;

    return Text(
      formatTimer(elapsed),
      style: const TextStyle(
        fontSize: 46,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.5,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// Today Summary Stats Row
class _TodayStatsRow extends ConsumerWidget {
  const _TodayStatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(todayTasksProvider);
    final active = ref.watch(activeTaskProvider).valueOrNull;

    final taskCount = tasksAsync.when(
      data: (t) => (t.length +
              (active != null && !t.any((x) => x.id == active.id) ? 1 : 0))
          .toString(),
      loading: () => '--',
      error: (_, __) => '--',
    );

    return Row(
      children: [
        const Expanded(
          child: _TickingTrackedTodayCard(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DaylogStatCard(
            kicker: 'Tasks logged',
            value: taskCount,
            icon: Icons.check_circle_outline_rounded,
            isAccent: false,
          ),
        ),
      ],
    );
  }
}

/// Isolated Leaf for Tracked Today Stat Card
class _TickingTrackedTodayCard extends ConsumerWidget {
  const _TickingTrackedTodayCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeTaskProvider).valueOrNull;
    if (active != null && !active.isPaused) {
      ref.watch(appTickerProvider);
    }

    final totalAsync = ref.watch(todayTotalSecondsProvider);
    final baseSeconds = totalAsync.valueOrNull ?? 0;
    final activeSeconds = active != null ? active.currentElapsedSeconds : 0;
    final totalSec = baseSeconds + activeSeconds;

    return DaylogStatCard(
      kicker: 'Tracked today',
      value: formatDuration(totalSec),
      icon: Icons.access_time_rounded,
      isAccent: true,
    );
  }
}
