import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../shared/animated_assets.dart';
import '../../shared/kids_widgets.dart';

Color _adaptiveSecondaryText(
  BuildContext context, {
  required double darkAlpha,
  required double lightAlpha,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Colors.white.withValues(alpha: isDark ? darkAlpha : lightAlpha);
}

final homeDashboardProvider = FutureProvider.autoDispose<_HomeDashboardData>((
  ref,
) async {
  final repository = ref.read(gameRepositoryProvider);
  final profile = await repository.getProfile();
  final worldProgress = await repository.getWorldProgress();
  return _HomeDashboardData.from(profile: profile, worldProgress: worldProgress);
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeDashboardProvider);
    return Scaffold(
      body: Stack(
        children: [
          const CinematicGameBackground(),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: homeDataAsync.when(
                      data: (homeData) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            _TopBar(childName: homeData.childName),
                            const SizedBox(height: 12),
                            _PremiumMascotHeader(level: homeData.level),
                            const SizedBox(height: 12),
                            XPBar(
                              currentXp: homeData.currentXp,
                              maxXp: homeData.maxXp,
                              level: homeData.level,
                            ),
                            const SizedBox(height: 14),
                            _StatsRow(
                              totalStars: homeData.totalStars,
                              badges: homeData.badges,
                              completedWorlds: homeData.completedWorlds,
                              totalWorlds: homeData.totalWorlds,
                            ),
                            const SizedBox(height: 14),
                            DailyMissionCard(
                              description: homeData.dailyMissionText,
                              progress: homeData.dailyMissionProgress,
                              onTap: () => context.go(AppRoutes.worlds),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'لوحة المغامرة',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ).animate().fadeIn(duration: 300.ms),
                            const SizedBox(height: 8),
                            Text(
                              'اختر وجهتك التالية',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: _adaptiveSecondaryText(
                                      context,
                                      darkAlpha: .78,
                                      lightAlpha: .94,
                                    ),
                                  ),
                            ).animate(delay: 80.ms).fadeIn(duration: 280.ms),
                            const SizedBox(height: 14),
                            _DashboardGrid(),
                            const SizedBox(height: 110),
                          ],
                        );
                      },
                      loading: () => const _HomeLoadingState(),
                      error: (error, _) => _HomeErrorState(
                        onRetry: () => ref.invalidate(homeDashboardProvider),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 14,
            right: 14,
            bottom: 12,
            child: _FloatingBottomNav(active: _NavTab.home),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.childName});

  final String childName;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 20,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً بك 👋',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _adaptiveSecondaryText(
                      context,
                      darkAlpha: .78,
                      lightAlpha: .94,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  childName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.go(AppRoutes.settings),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: .3)),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -.1, end: 0);
  }
}

class _PremiumMascotHeader extends StatelessWidget {
  const _PremiumMascotHeader({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return Center(
          child: SizedBox(
            height: 150,
            width: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                      width: 136,
                      height: 136,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFBDA8FF).withValues(alpha: .7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(.9, .9),
                      end: const Offset(1.08, 1.08),
                      duration: 2400.ms,
                    )
                    .fade(begin: .45, end: .9),
                Positioned(
                  top: 18,
                  left: 24,
                  child: const Text('☁️', style: TextStyle(fontSize: 20))
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveX(begin: -4, end: 6, duration: 4200.ms),
                ),
                Positioned(
                  top: 28,
                  right: 20,
                  child: const Text('☁️', style: TextStyle(fontSize: 16))
                      .animate(
                        delay: 500.ms,
                        onPlay: (c) => c.repeat(reverse: true),
                      )
                      .moveX(begin: 4, end: -8, duration: 4500.ms),
                ),
                const Positioned(
                      left: 30,
                      top: 56,
                      child: Text('✨', style: TextStyle(fontSize: 14)),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(.7, .7),
                      end: const Offset(1.2, 1.2),
                      duration: 1700.ms,
                    )
                    .fade(begin: .35, end: .9),
                const Positioned(
                      right: 36,
                      top: 74,
                      child: Text('⭐', style: TextStyle(fontSize: 15)),
                    )
                    .animate(
                      delay: 300.ms,
                      onPlay: (c) => c.repeat(reverse: true),
                    )
                    .moveY(begin: 0, end: -9, duration: 1900.ms)
                    .fade(begin: .3, end: .9),
                const Positioned(
                      right: 24,
                      bottom: 35,
                      child: Text('🌟', style: TextStyle(fontSize: 13)),
                    )
                    .animate(
                      delay: 900.ms,
                      onPlay: (c) => c.repeat(reverse: true),
                    )
                    .scale(
                      begin: const Offset(.6, .6),
                      end: const Offset(1.1, 1.1),
                      duration: 1800.ms,
                    ),
                const SafeLottieAsset(
                  path: 'assets/animations/splash_leaf.json',
                  width: 180,
                  height: 130,
                ).animate().fade(begin: .0, end: .2, duration: 700.ms),
                Center(
                  child: Hero(
                    tag: 'main_eco_mascot',
                    child: PremiumEcoMascotCharacter(size: 108, level: level),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .scale(
          begin: const Offset(.6, .6),
          duration: 600.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 400.ms);
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.totalStars,
    required this.badges,
    required this.completedWorlds,
    required this.totalWorlds,
  });

  final int totalStars;
  final int badges;
  final int completedWorlds;
  final int totalWorlds;

  @override
  Widget build(BuildContext context) {
    final stats = [
      (emoji: '⭐', value: '$totalStars', label: 'نجوم'),
      (emoji: '🏆', value: '$badges', label: 'شارات'),
      (emoji: '🌍', value: '$completedWorlds/$totalWorlds', label: 'عوالم'),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 420;
        final columns = compact ? 2 : 3;
        final spacing = compact ? 8.0 : 10.0;
        final itemWidth =
            ((constraints.maxWidth - (spacing * (columns - 1))) / columns)
                .clamp(102.0, 180.0);
        return Align(
          alignment: Alignment.center,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: spacing,
            runSpacing: spacing,
            children: stats.indexed.map((rec) {
              final (i, stat) = rec;
              return SizedBox(
                width: itemWidth,
                child: _StatChip(
                  emoji: stat.emoji,
                  value: stat.value,
                  label: stat.label,
                ).animate(delay: (100 + (i * 90)).ms).fadeIn(duration: 280.ms),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.emoji,
    required this.value,
    required this.label,
  });
  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      borderRadius: 18,
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: _adaptiveSecondaryText(
                context,
                darkAlpha: .78,
                lightAlpha: .95,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItem(
        title: 'ابدأ اللعب',
        subtitle: 'ابدأ المغامرة الآن',
        icon: Icons.rocket_launch_rounded,
        color: const Color(0xFF64B86B),
        route: AppRoutes.worlds,
      ),
      _MenuItem(
        title: 'العوالم',
        subtitle: '6 عوالم سينمائية',
        icon: Icons.public_rounded,
        color: const Color(0xFF64B4FF),
        route: AppRoutes.worlds,
      ),
      _MenuItem(
        title: 'المكافآت',
        subtitle: 'جوائزك ولمعاتك',
        icon: Icons.workspace_premium_rounded,
        color: const Color(0xFFF3A954),
        route: AppRoutes.rewards,
      ),
      _MenuItem(
        title: 'ملفي',
        subtitle: 'تقدّمك وإحصاءاتك',
        icon: Icons.account_circle_rounded,
        color: const Color(0xFF9A7CFF),
        route: AppRoutes.profile,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 3 : 2;
        return GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: columns == 3 ? 1.45 : 1.2,
          ),
          itemBuilder: (context, i) {
            final item = items[i];
            return BigActionCard(
                  title: item.title,
                  subtitle: item.subtitle,
                  icon: item.icon,
                  color: item.color,
                  onTap: () => context.go(item.route),
                )
                .animate(delay: (i * 80 + 200).ms)
                .fadeIn(duration: 320.ms)
                .slideY(begin: .15, end: 0);
          },
        );
      },
    );
  }
}

enum _NavTab { home, worlds, rewards, profile }

class _FloatingBottomNav extends StatelessWidget {
  const _FloatingBottomNav({required this.active});
  final _NavTab active;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF2B245B) : const Color(0xFF355E9A))
                .withValues(alpha: isDark ? .45 : .36),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? .24 : .4),
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? const Color(0xFF5B4CCF) : const Color(0xFF4A7FD6))
                    .withValues(alpha: isDark ? .24 : .2),
                blurRadius: 22,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              _NavButton(
                label: 'الرئيسية',
                icon: Icons.home_rounded,
                active: active == _NavTab.home,
                onTap: () => context.go(AppRoutes.home),
              ),
              _NavButton(
                label: 'العوالم',
                icon: Icons.public_rounded,
                active: active == _NavTab.worlds,
                onTap: () => context.go(AppRoutes.worlds),
              ),
              _NavButton(
                label: 'المكافآت',
                icon: Icons.workspace_premium_rounded,
                active: active == _NavTab.rewards,
                onTap: () => context.go(AppRoutes.rewards),
              ),
              _NavButton(
                label: 'ملفي',
                icon: Icons.account_circle_rounded,
                active: active == _NavTab.profile,
                onTap: () => context.go(AppRoutes.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
          child: GestureDetector(
            onTap: onTap,
            child:
                AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.white.withValues(alpha: .18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF8B7DFF,
                                  ).withValues(alpha: .26),
                                  blurRadius: 12,
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: .14),
                                  blurRadius: 10,
                                  spreadRadius: .8,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                                icon,
                                size: active ? 22 : 20,
                                color: active
                                    ? Colors.white
                                    : _adaptiveSecondaryText(
                                        context,
                                        darkAlpha: .75,
                                        lightAlpha: .92,
                                      ),
                              )
                              .animate(target: active ? 1 : 0)
                              .scaleXY(
                                begin: .86,
                                end: 1.12,
                                duration: 260.ms,
                                curve: Curves.easeOutBack,
                              )
                              .then()
                              .scaleXY(begin: 1.12, end: 1, duration: 180.ms),
                          const SizedBox(height: 3),
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: active
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: active
                                  ? Colors.white
                                  : _adaptiveSecondaryText(
                                      context,
                                      darkAlpha: .8,
                                      lightAlpha: .95,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate(target: active ? 1 : 0)
                    .moveY(begin: 0, end: -2, duration: 260.ms),
          ),
        )
        .animate()
        .fadeIn(duration: 260.ms)
        .scaleXY(begin: .96, end: 1, duration: 240.ms);
  }
}

class _MenuItem {
  const _MenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
}

class _HomeDashboardData {
  const _HomeDashboardData({
    required this.childName,
    required this.totalStars,
    required this.badges,
    required this.completedWorlds,
    required this.totalWorlds,
    required this.level,
    required this.currentXp,
    required this.maxXp,
    required this.dailyMissionText,
    required this.dailyMissionProgress,
  });

  final String childName;
  final int totalStars;
  final int badges;
  final int completedWorlds;
  final int totalWorlds;
  final int level;
  final int currentXp;
  final int maxXp;
  final String dailyMissionText;
  final double dailyMissionProgress;

  factory _HomeDashboardData.from({
    required ChildProfile profile,
    required List<WorldProgress> worldProgress,
  }) {
    final totalWorlds = worldProgress.length;
    final completedWorlds = worldProgress
        .where((world) => world.totalLevels > 0 && world.completedLevels >= world.totalLevels)
        .length;

    const xpPerLevel = 120;
    final totalXp = profile.totalStars * 20;
    final currentXp = totalXp % xpPerLevel;
    final level = (totalXp ~/ xpPerLevel) + 1;

    const starsPerBadge = 10;
    final starsInBadgeCycle = profile.totalStars % starsPerBadge;
    final starsToNextBadge = starsPerBadge - starsInBadgeCycle;
    final missionProgress = starsInBadgeCycle == 0 && profile.totalStars > 0
        ? 1.0
        : starsInBadgeCycle / starsPerBadge;

    final missionText = starsInBadgeCycle == 0 && profile.totalStars > 0
        ? 'أحسنت! حصلت على شارة جديدة، واصل اللعب!'
        : 'اجمع $starsToNextBadge نجوم للحصول على الشارة التالية';

    return _HomeDashboardData(
      childName: profile.name,
      totalStars: profile.totalStars,
      badges: profile.badges,
      completedWorlds: completedWorlds,
      totalWorlds: totalWorlds,
      level: level,
      currentXp: currentXp,
      maxXp: xpPerLevel,
      dailyMissionText: missionText,
      dailyMissionProgress: missionProgress,
    );
  }
}

class _HomeLoadingState extends StatelessWidget {
  const _HomeLoadingState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 420,
      child: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

class _HomeErrorState extends StatelessWidget {
  const _HomeErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Text(
              'تعذر تحميل بيانات الصفحة',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
