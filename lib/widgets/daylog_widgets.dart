// lib/widgets/daylog_widgets.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// App bar / Page Header matching Daylog.dc.html
class DaylogPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final Widget? trailing;

  const DaylogPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showBackButton) ...[
            InkWell(
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Icon(Icons.chevron_left_rounded, size: 24, color: theme.colorScheme.onSurface),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Stat Card with kicker label (and optional icon) and large 27-32px numeric display
class DaylogStatCard extends StatelessWidget {
  final String kicker;
  final String value;
  final IconData? icon;
  final bool isAccent;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const DaylogStatCard({
    super.key,
    required this.kicker,
    required this.value,
    this.icon,
    this.isAccent = false,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isAccent
        ? (isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100)
        : theme.cardTheme.color ?? theme.colorScheme.surfaceContainer;

    final kickerColor = isAccent
        ? (isDark ? DaylogColors.darkAccent : DaylogColors.accent700)
        : theme.colorScheme.onSurface.withValues(alpha: 0.65);

    final valueColor = isAccent
        ? (isDark ? DaylogColors.darkAccent800 : DaylogColors.accent800)
        : theme.colorScheme.onSurface;

    Widget card = Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAccent
              ? (isDark ? DaylogColors.darkAccent.withValues(alpha: 0.3) : DaylogColors.accent.withValues(alpha: 0.2))
              : theme.colorScheme.outlineVariant,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: kickerColor),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  kicker,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: kickerColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: valueColor,
                letterSpacing: -0.5,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: card,
      );
    }
    return card;
  }
}

/// Category Tag / Badge Pill
class CategoryTag extends StatelessWidget {
  final String category;
  final bool isDark;

  const CategoryTag({
    super.key,
    required this.category,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final info = getCategoryInfo(category);
    final bg = isDark ? info.darkBg : info.lightBg;
    final fg = isDark ? info.darkFg : info.lightFg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        capitalizeCategory(category),
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

/// Circular Icon Tile for 2-column Category Breakdown
class CategoryTileCard extends StatelessWidget {
  final String category;
  final String durationLabel;
  final String countLabel;
  final VoidCallback? onTap;

  const CategoryTileCard({
    super.key,
    required this.category,
    required this.durationLabel,
    required this.countLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = getCategoryInfo(category);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: info.tileColor,
                shape: BoxShape.circle,
              ),
              child: Icon(info.icon, size: 22, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              capitalizeCategory(category),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '$durationLabel · $countLabel',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashed Inactive Focus Session Card
class DashedStartSessionCard extends StatelessWidget {
  final VoidCallback onTap;

  const DashedStartSessionCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: theme.colorScheme.outlineVariant,
          strokeWidth: 1.5,
          gap: 6.0,
          dash: 6.0,
          radius: 28.0,
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? DaylogColors.darkAccent100 : DaylogColors.accent100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 22,
                  color: isDark ? DaylogColors.darkAccent : DaylogColors.accent700,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start a focus session',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Track what you work on next',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.dash,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = (distance + dash < metric.length) ? dash : metric.length - distance;
        final extractPath = metric.extractPath(distance, distance + length);
        canvas.drawPath(extractPath, paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color || radius != oldDelegate.radius;
}

/// Pulsing Recording Dot
class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;
  final bool isPaused;

  const PulsingDot({
    super.key,
    required this.color,
    this.size = 7.0,
    this.isPaused = false,
  });

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _animation = Tween<double>(begin: 0.5, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (!widget.isPaused) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PulsingDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPaused) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPaused) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      );
    }
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => Container(
        width: widget.size * _animation.value,
        height: widget.size * _animation.value,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.4 + (0.6 * (_animation.value - 0.5) / 0.75)),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Custom Organic Track & Knob Switch Toggle
class DaylogSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const DaylogSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final trackColor = value
        ? (isDark ? DaylogColors.darkAccent : DaylogColors.accent)
        : (isDark ? const Color(0xFF4A4440) : const Color(0xFFD6C8B8));

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 46,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pulsing Ring Floating Action Button
class PulsingRingFab extends StatefulWidget {
  final VoidCallback onPressed;

  const PulsingRingFab({super.key, required this.onPressed});

  @override
  State<PulsingRingFab> createState() => _PulsingRingFabState();
}

class _PulsingRingFabState extends State<PulsingRingFab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return SizedBox(
      width: 58,
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale = 1.0 + (_controller.value * 0.7);
              final opacity = (1.0 - _controller.value) * 0.45;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: opacity),
                  ),
                ),
              );
            },
          ),
          Material(
            color: accentColor,
            shape: const CircleBorder(),
            elevation: 6,
            child: InkWell(
              onTap: widget.onPressed,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 56,
                height: 56,
                child: Icon(Icons.add_rounded, size: 28, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating Toast Pill
void showDaylogToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF201E1D),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      margin: const EdgeInsets.only(left: 32, right: 32, bottom: 92),
      duration: const Duration(milliseconds: 2200),
    ),
  );
}
