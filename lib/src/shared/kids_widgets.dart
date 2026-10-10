import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/app_colors.dart';

// ─── Gradient Scaffold Background ───────────────────────────────────────────

class KidsGradientBackground extends StatelessWidget {
  const KidsGradientBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFF0FDF4), Color(0xFFFFF7ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}

// ─── Glassmorphism Card ───────────────────────────────────────────────────

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = 24,
    this.color,
  });
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        color ??
        (isDark
            ? Colors.white.withValues(alpha: .16)
            : Colors.white.withValues(alpha: .34));
    final borderColor = isDark
        ? Colors.white.withValues(alpha: .45)
        : Colors.white.withValues(alpha: .58);
    final outerShadow = isDark
        ? const Color(0xFF31216A).withValues(alpha: .22)
        : const Color(0xFF28438A).withValues(alpha: .16);
    final innerHighlight = isDark
        ? Colors.white.withValues(alpha: .09)
        : Colors.white.withValues(alpha: .2);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 1.3),
            boxShadow: [
              BoxShadow(
                color: outerShadow,
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: innerHighlight,
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Big Action Card (Home Menu) ─────────────────────────────────────────

class BigActionCard extends StatefulWidget {
  const BigActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.subtitle,
  });
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? subtitle;

  @override
  State<BigActionCard> createState() => _BigActionCardState();
}

class _BigActionCardState extends State<BigActionCard> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final depth = _pressed ? 6.0 : (_hovered ? 16.0 : 12.0);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? .96 : (_hovered ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_hovered ? -0.015 : 0)
              ..rotateY(_hovered ? 0.02 : 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.color, widget.color.withValues(alpha: .8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? .22 : .34),
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(
                    alpha: _pressed ? .2 : (_hovered ? .5 : .38),
                  ),
                  blurRadius: depth + 10,
                  offset: Offset(0, depth * .55),
                ),
                BoxShadow(
                  color: Colors.white.withValues(
                    alpha: _hovered
                        ? (isDark ? .14 : .22)
                        : (isDark ? .08 : .16),
                  ),
                  blurRadius: _hovered ? 14 : 8,
                  spreadRadius: _hovered ? 1.5 : .5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                splashColor: Colors.white.withValues(alpha: .2),
                highlightColor: Colors.white.withValues(alpha: .07),
                onTap: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(
                                  alpha: isDark ? .24 : .32,
                                ),
                                Colors.transparent,
                                Colors.black.withValues(
                                  alpha: isDark ? .07 : .03,
                                ),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 18,
                        top: 14,
                        child: const Text('✨', style: TextStyle(fontSize: 11))
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .fade(begin: .2, end: .7, duration: 1600.ms),
                      ),
                      Positioned(
                        left: 14,
                        bottom: 14,
                        child: const Text('🍃', style: TextStyle(fontSize: 12))
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .moveY(begin: 0, end: -4, duration: 2200.ms)
                            .fade(begin: .18, end: .45),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final veryCompact = width < 170;
                          final compact = width < 230;
                          final iconSize = compact ? 44.0 : 52.0;
                          return Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.title,
                                      style: TextStyle(
                                        fontSize: compact ? 16 : 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (widget.subtitle != null &&
                                        !veryCompact) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.subtitle!,
                                        style: TextStyle(
                                          fontSize: compact ? 12 : 13,
                                          height: 1.25,
                                          color: Colors.white.withValues(
                                            alpha: .86,
                                          ),
                                        ),
                                        maxLines: compact ? 1 : 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (!veryCompact) ...[
                                const SizedBox(width: 8),
                                Container(
                                      width: iconSize,
                                      height: iconSize,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: .28,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: .3,
                                          ),
                                        ),
                                      ),
                                      child: Icon(
                                        widget.icon,
                                        size: compact ? 24 : 28,
                                        color: Colors.white,
                                      ),
                                    )
                                    .animate(
                                      onPlay: (c) => c.repeat(reverse: true),
                                    )
                                    .moveY(
                                      begin: 0,
                                      end: -2,
                                      duration: 1900.ms,
                                    ),
                                if (!compact) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    isRtl
                                        ? Icons.arrow_back_ios_new_rounded
                                        : Icons.arrow_forward_ios_rounded,
                                    size: 18,
                                    color: Colors.white.withValues(alpha: .75),
                                  ),
                                ],
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 320.ms).slideY(begin: .12, end: 0);
  }
}

// ─── XP Progress Bar ─────────────────────────────────────────────────────

class XPBar extends StatelessWidget {
  const XPBar({
    super.key,
    required this.currentXp,
    required this.maxXp,
    required this.level,
  });
  final int currentXp;
  final int maxXp;
  final int level;

  @override
  Widget build(BuildContext context) {
    final ratio = (currentXp / maxXp).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .35)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.xpColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'المستوى $level',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          Container(
                            height: 12,
                            color: Colors.white.withValues(alpha: .24),
                          ),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: ratio),
                            duration: const Duration(milliseconds: 1100),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) {
                              return FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: value,
                                child: Container(
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFFCD34D),
                                        Color(0xFFF59E0B),
                                        Color(0xFFFCD34D),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child:
                                    Container(
                                          width: constraints.maxWidth * .18,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white.withValues(
                                                  alpha: 0,
                                                ),
                                                Colors.white.withValues(
                                                  alpha: .6,
                                                ),
                                                Colors.white.withValues(
                                                  alpha: 0,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .animate(onPlay: (c) => c.repeat())
                                        .moveX(
                                          begin: -constraints.maxWidth * .3,
                                          end: constraints.maxWidth * 1.25,
                                          duration: 1800.ms,
                                          curve: Curves.linear,
                                        ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$currentXp/$maxXp',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'الخبرة',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: .75),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: List.generate(3, (i) {
              return Padding(
                padding: EdgeInsets.only(left: i == 2 ? 0 : 4),
                child: const Text('✨', style: TextStyle(fontSize: 9))
                    .animate(
                      delay: (i * 180).ms,
                      onPlay: (c) => c.repeat(reverse: true),
                    )
                    .moveY(begin: 0, end: -3, duration: 900.ms)
                    .fade(begin: .25, end: .75),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Star Row ─────────────────────────────────────────────────────────────

class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.count, this.size = 28});
  final int count;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < count;
        return Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              color: filled ? AppColors.starColor : Colors.white38,
              size: size,
            )
            .animate(delay: (i * 80).ms)
            .scale(
              begin: const Offset(.5, .5),
              duration: 280.ms,
              curve: Curves.easeOutBack,
            );
      }),
    );
  }
}

// ─── Floating Particle ────────────────────────────────────────────────────

class FloatingParticle extends StatelessWidget {
  const FloatingParticle({
    super.key,
    required this.emoji,
    required this.x,
    required this.y,
    required this.size,
    this.delay = 0,
  });
  final String emoji;
  final double x;
  final double y;
  final double size;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: IgnorePointer(
        child: Text(emoji, style: TextStyle(fontSize: size))
            .animate(delay: delay.ms, onPlay: (c) => c.repeat(reverse: true))
            .moveY(
              begin: 0,
              end: -9,
              duration: 3600.ms,
              curve: Curves.easeInOut,
            )
            .fade(begin: .35, end: .68),
      ),
    );
  }
}

// ─── World Card ───────────────────────────────────────────────────────────

class WorldCard extends StatefulWidget {
  const WorldCard({
    super.key,
    required this.title,
    required this.emoji,
    required this.gradientColors,
    required this.isUnlocked,
    required this.completedLevels,
    required this.totalLevels,
    required this.onTap,
    this.delay = 0,
  });
  final String title;
  final String emoji;
  final List<Color> gradientColors;
  final bool isUnlocked;
  final int completedLevels;
  final int totalLevels;
  final VoidCallback onTap;
  final int delay;

  @override
  State<WorldCard> createState() => _WorldCardState();
}

class _WorldCardState extends State<WorldCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.isUnlocked ? widget.onTap : null,
          child: AnimatedScale(
            scale: _pressed ? .95 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutBack,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: widget.isUnlocked
                    ? LinearGradient(
                        colors: widget.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFCBD5E1), Color(0xFF94A3B8)],
                      ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: widget.isUnlocked
                    ? [
                        BoxShadow(
                          color: widget.gradientColors[0].withValues(alpha: .4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: .15),
                            Colors.transparent,
                            Colors.black.withValues(alpha: .08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  if (!widget.isUnlocked)
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.emoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                        const Spacer(),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: widget.totalLevels == 0
                                ? 0
                                : widget.completedLevels / widget.totalLevels,
                            minHeight: 7,
                            backgroundColor: Colors.white.withValues(
                              alpha: .25,
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.completedLevels}/${widget.totalLevels} مستوى',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: .8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: widget.delay.ms)
        .fadeIn(duration: 380.ms)
        .scale(begin: const Offset(.88, .88), curve: Curves.easeOutBack);
  }
}

// ─── Level Node (Game Map) ────────────────────────────────────────────────

class LevelNode extends StatefulWidget {
  const LevelNode({
    super.key,
    required this.number,
    required this.stars,
    required this.isUnlocked,
    required this.isCurrent,
    required this.color,
    required this.onTap,
    this.delay = 0,
    this.size = 72,
    this.icon,
  });
  final int number;
  final int stars;
  final bool isUnlocked;
  final bool isCurrent;
  final Color color;
  final VoidCallback onTap;
  final int delay;
  final double size;
  final String? icon;

  @override
  State<LevelNode> createState() => _LevelNodeState();
}

class _LevelNodeState extends State<LevelNode> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.isUnlocked ? widget.onTap : null,
          child: AnimatedScale(
            scale: _pressed ? .92 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutBack,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isCurrent)
                  const Text(
                        '▼',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(begin: -4, end: 4, duration: 700.ms),
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.isUnlocked
                        ? LinearGradient(
                            colors: [
                              widget.color.withValues(alpha: .9),
                              widget.color,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF94A3B8), Color(0xFF64748B)],
                          ),
                    boxShadow: [
                      if (widget.isCurrent)
                        BoxShadow(
                          color: widget.color.withValues(alpha: .7),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      BoxShadow(
                        color: widget.isUnlocked
                            ? widget.color.withValues(alpha: .35)
                            : Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: widget.isCurrent
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                  ),
                  child: Center(
                    child: widget.isUnlocked
                        ? Text(
                            widget.icon ?? '${widget.number}',
                            style: TextStyle(
                              fontSize: widget.icon == null ? 26 : 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    return Icon(
                      i < widget.stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 16,
                      color: i < widget.stars
                          ? AppColors.starColor
                          : Colors.white38,
                    );
                  }),
                ),
              ],
            ),
          ),
        )
        .animate(delay: widget.delay.ms)
        .scale(
          begin: const Offset(.5, .5),
          duration: 350.ms,
          curve: Curves.easeOutBack,
        );
  }
}

// ─── Daily Mission Card ───────────────────────────────────────────────────

class DailyMissionCard extends StatelessWidget {
  const DailyMissionCard({
    super.key,
    required this.onTap,
    this.title = 'مهمة اليوم',
    this.description = 'العب 3 مستويات واجمع ١٥ نجمة',
    this.progress = .4,
  });
  final VoidCallback onTap;
  final String title;
  final String description;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        borderRadius: 28,
        color: const Color(0xFFFB923C).withValues(alpha: .26),
        child: Row(
          children: [
            const Text('🎯', style: TextStyle(fontSize: 38)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: .9),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: .05, end: safeProgress),
                    duration: const Duration(milliseconds: 1300),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 9,
                          backgroundColor: Colors.white.withValues(alpha: .25),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 22,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: .1, end: 0);
  }
}

// ─── Floating Bubbles Background ─────────────────────────────────────────

class FloatingBubblesBg extends StatelessWidget {
  const FloatingBubblesBg({super.key});

  static final _rand = Random(42);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const emojis = ['🍃', '🌿', '✨', '⭐', '☁️'];
    return Stack(
      children: List.generate(6, (i) {
        final x = _rand.nextDouble() * size.width;
        final y = _rand.nextDouble() * size.height;
        final emojiSize = 14.0 + _rand.nextDouble() * 12;
        final emoji = emojis[i % emojis.length];
        return FloatingParticle(
          emoji: emoji,
          x: x,
          y: y,
          size: emojiSize,
          delay: i * 200,
        );
      }),
    );
  }
}

class CinematicGameBackground extends StatelessWidget {
  const CinematicGameBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final gradientColors = isDark
        ? const [
            Color(0xFF15112E),
            Color(0xFF2A2362),
            Color(0xFF244A78),
            Color(0xFF2F7267),
          ]
        : const [
            Color(0xFF4F6FD6),
            Color(0xFF4C8DC6),
            Color(0xFF56A7B0),
            Color(0xFF6FB28D),
          ];
    final glowA = isDark ? const Color(0xFFB58DFF) : const Color(0xFFD2B5FF);
    final glowB = isDark ? const Color(0xFF5CC8FF) : const Color(0xFF86D7FF);
    final glowC = isDark ? const Color(0xFFFFC96E) : const Color(0xFFFFD991);
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(top: -120, left: -50, child: _softGlow(glowA, 230)),
        Positioned(
          top: size.height * .25,
          right: -60,
          child: _softGlow(glowB, 180),
        ),
        Positioned(
          bottom: -100,
          left: size.width * .2,
          child: _softGlow(glowC, 210),
        ),
        Positioned(
          top: size.height * .08,
          left: size.width * .1,
          child:
              Container(
                    width: 130,
                    height: 240,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: .12),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(begin: -6, end: 8, duration: 5600.ms),
        ),
        const FloatingBubblesBg(),
        ..._floatingLeaves(size),
        ..._floatingStars(size),
        ..._floatingButterflies(size),
      ],
    );
  }

  static Widget _softGlow(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: .34), Colors.transparent],
          ),
        ),
      ),
    );
  }

  static List<Widget> _floatingLeaves(Size size) {
    final leaves = ['🍃', '🌿', '🍀'];
    return List.generate(3, (i) {
      return Positioned(
        left: size.width * (.1 + (i * .22)),
        top: size.height * (.16 + (i.isEven ? .08 : .24)),
        child: IgnorePointer(
          child:
              Text(
                    leaves[i % leaves.length],
                    style: const TextStyle(fontSize: 18),
                  )
                  .animate(
                    delay: (300 * i).ms,
                    onPlay: (c) => c.repeat(reverse: true),
                  )
                  .moveY(begin: 0, end: -18, duration: (2200 + i * 300).ms)
                  .moveX(begin: -4, end: 8, duration: (2600 + i * 280).ms)
                  .fade(begin: .25, end: .8),
        ),
      );
    });
  }

  static List<Widget> _floatingStars(Size size) {
    return List.generate(4, (i) {
      return Positioned(
        right: size.width * (.08 + (i * .12)),
        top: size.height * (.08 + (i * .09)),
        child: IgnorePointer(
          child: const Text('✨', style: TextStyle(fontSize: 14))
              .animate(
                delay: (200 * i).ms,
                onPlay: (c) => c.repeat(reverse: true),
              )
              .scale(
                begin: const Offset(.7, .7),
                end: const Offset(1.15, 1.15),
                duration: (1900 + i * 120).ms,
              )
              .fade(begin: .2, end: .75),
        ),
      );
    });
  }

  static List<Widget> _floatingButterflies(Size size) {
    return [
      Positioned(
        left: size.width * .08,
        top: size.height * .45,
        child: IgnorePointer(
          child: const Text('🦋', style: TextStyle(fontSize: 18))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveX(begin: 0, end: 24, duration: 4200.ms)
              .moveY(begin: 0, end: -10, duration: 2600.ms)
              .fade(begin: .45, end: .75),
        ),
      ),
    ];
  }
}

// ─── Avatar Circle ────────────────────────────────────────────────────────

class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    super.key,
    required this.emoji,
    this.radius = 36,
    this.color,
  });
  final String emoji;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            color ?? const Color(0xFF7C3AED),
            (color ?? const Color(0xFF7C3AED)).withValues(alpha: .7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (color ?? const Color(0xFF7C3AED)).withValues(alpha: .35),
            blurRadius: 14,
          ),
        ],
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: radius * .9)),
      ),
    );
  }
}

class PremiumAvatarBadge extends StatelessWidget {
  const PremiumAvatarBadge({
    super.key,
    this.level = 4,
    this.size = 108,
    this.emoji = '🧒',
  });

  final int level;
  final double size;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    final badgeFont = (size * 0.17).clamp(11.0, 18.0);
    return SizedBox(
      width: size + 16,
      height: size + 16,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C4BFF), Color(0xFF4A35D7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A35D7).withValues(alpha: .24),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(emoji, style: TextStyle(fontSize: size * .45)),
              ),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: size * .11,
                vertical: size * .045,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF4BE1F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .16),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'مستوى $level',
                style: TextStyle(
                  fontSize: badgeFont,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
