import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../shared/animated_assets.dart';
import '../../shared/kids_widgets.dart';

Color _profileSecondaryText(
  BuildContext context, {
  double darkAlpha = .72,
  double lightAlpha = .92,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Colors.white.withValues(alpha: isDark ? darkAlpha : lightAlpha);
}

Color _profileSurface(BuildContext context, {double darkAlpha = .1, double lightAlpha = .26}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Colors.white.withValues(alpha: isDark ? darkAlpha : lightAlpha);
}

Color _profileBorder(BuildContext context, {double darkAlpha = .2, double lightAlpha = .38}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Colors.white.withValues(alpha: isDark ? darkAlpha : lightAlpha);
}

final profilePageDataProvider = FutureProvider.autoDispose<_ProfilePageData>((
  ref,
) async {
  final repository = ref.read(gameRepositoryProvider);
  final profile = await repository.getProfile();
  final worldProgress = await repository.getWorldProgress();
  return _ProfilePageData.from(profile: profile, worldProgress: worldProgress);
});

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(profilePageDataProvider);
    return Scaffold(
      body: Stack(
        children: [
          const CinematicGameBackground(),
          SafeArea(
            child: dataAsync.when(
              data: (data) {
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            _ProfileTopBar(),
                            const SizedBox(height: 22),
                            _ProfileHero(data: data),
                            const SizedBox(height: 22),
                            _StatsSection(data: data),
                            const SizedBox(height: 22),
                            _WorldProgress(worlds: data.worlds),
                            const SizedBox(height: 22),
                            _RecentBadges(badges: data.recentBadges),
                            const SizedBox(height: 34),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (_, _) => Center(
                child: FilledButton(
                  onPressed: () => ref.invalidate(profilePageDataProvider),
                  child: const Text('إعادة المحاولة'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.go(AppRoutes.home),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _profileSurface(context, darkAlpha: .15, lightAlpha: .3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _profileBorder(context, darkAlpha: .25, lightAlpha: .45),
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'ملفي الشخصي',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.data});

  final _ProfilePageData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: .45),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'main_eco_mascot',
            child: PremiumEcoMascotCharacter(size: 96, level: data.level),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.childName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '🏆 المستوى ${data.level}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: data.currentXp / data.maxXp,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: .25),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFBBF24),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.currentXp} / ${data.maxXp} XP',
                  style: TextStyle(
                    fontSize: 12,
                    color: _profileSecondaryText(context, darkAlpha: .75, lightAlpha: .95),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 380.ms).slideY(begin: .1, end: 0);
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.data});

  final _ProfilePageData data;

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('⭐', '${data.totalStars}', 'نجوم'),
      ('🏆', '${data.badges}', 'شارات'),
      ('🌍', '${data.completedWorlds}', 'عوالم'),
      ('🎮', '${data.playedGames}', 'لعبة'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;
        final columns = compact ? 2 : 4;
        const spacing = 10.0;
        final itemWidth =
            ((constraints.maxWidth - (spacing * (columns - 1))) / columns)
                .clamp(112.0, 180.0);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: stats.indexed.map((rec) {
            final (i, stat) = rec;
            return SizedBox(
              width: itemWidth,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                decoration: BoxDecoration(
                  color: _profileSurface(context, darkAlpha: .12, lightAlpha: .28),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _profileBorder(context, darkAlpha: .2, lightAlpha: .38),
                  ),
                ),
                child: Column(
                  children: [
                    Text(stat.$1, style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 4),
                    Text(
                      stat.$2,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      stat.$3,
                      style: TextStyle(
                        fontSize: 11,
                        color: _profileSecondaryText(
                          context,
                          darkAlpha: .65,
                          lightAlpha: .9,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: (i * 60).ms).fadeIn(duration: 300.ms),
            );
          }).toList(),
        );
      },
    );
  }
}

class _WorldProgress extends StatelessWidget {
  const _WorldProgress({required this.worlds});

  final List<_WorldProgressRow> worlds;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _profileSurface(context, darkAlpha: .1, lightAlpha: .26),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _profileBorder(context, darkAlpha: .2, lightAlpha: .38),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🗺️ تقدّمي في العوالم',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...worlds.indexed.map((rec) {
            final (i, world) = rec;
            final progress = world.totalLevels == 0
                ? 0.0
                : world.completedLevels / world.totalLevels;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '${world.emoji} ${world.title}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${world.completedLevels}/${world.totalLevels}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _profileSecondaryText(
                            context,
                            darkAlpha: .7,
                            lightAlpha: .92,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: _profileSurface(
                        context,
                        darkAlpha: .15,
                        lightAlpha: .32,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(world.color),
                    ),
                  ),
                ],
              ).animate(delay: (i * 50).ms).fadeIn(duration: 280.ms),
            );
          }),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 380.ms);
  }
}

class _RecentBadges extends StatelessWidget {
  const _RecentBadges({required this.badges});

  final List<_BadgeInfo> badges;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _profileSurface(context, darkAlpha: .1, lightAlpha: .26),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _profileBorder(context, darkAlpha: .2, lightAlpha: .38),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '🏅 آخر الشارات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go(AppRoutes.rewards),
                child: Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontSize: 14,
                    color: _profileSecondaryText(context, darkAlpha: .65, lightAlpha: .9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 10.0;
              final itemWidth = ((constraints.maxWidth - (spacing * 2)) / 3)
                  .clamp(90.0, 200.0);
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: badges.indexed.map((rec) {
                  final (i, badge) = rec;
                  return SizedBox(
                    width: itemWidth,
                    child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _profileSurface(
                              context,
                              darkAlpha: .12,
                              lightAlpha: .28,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _profileBorder(
                                context,
                                darkAlpha: .2,
                                lightAlpha: .38,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(badge.emoji, style: const TextStyle(fontSize: 32)),
                              const SizedBox(height: 6),
                              Text(
                                badge.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate(delay: (i * 80).ms)
                        .fadeIn(duration: 300.ms)
                        .scale(
                          begin: const Offset(.8, .8),
                          curve: Curves.easeOutBack,
                        ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn(duration: 380.ms);
  }
}

class _WorldProgressRow {
  const _WorldProgressRow({
    required this.worldId,
    required this.title,
    required this.emoji,
    required this.color,
    required this.completedLevels,
    required this.totalLevels,
  });

  final String worldId;
  final String title;
  final String emoji;
  final Color color;
  final int completedLevels;
  final int totalLevels;
}

class _BadgeInfo {
  const _BadgeInfo({required this.emoji, required this.title});

  final String emoji;
  final String title;
}

class _ProfilePageData {
  const _ProfilePageData({
    required this.childName,
    required this.totalStars,
    required this.badges,
    required this.completedWorlds,
    required this.playedGames,
    required this.level,
    required this.currentXp,
    required this.maxXp,
    required this.worlds,
    required this.recentBadges,
  });

  final String childName;
  final int totalStars;
  final int badges;
  final int completedWorlds;
  final int playedGames;
  final int level;
  final int currentXp;
  final int maxXp;
  final List<_WorldProgressRow> worlds;
  final List<_BadgeInfo> recentBadges;

  factory _ProfilePageData.from({
    required ChildProfile profile,
    required List<WorldProgress> worldProgress,
  }) {
    const worldMeta = {
      'colors': ('عالم الألوان', '🎨', Color(0xFF22C55E)),
      'animals': ('عالم الحيوانات', '🐼', Color(0xFFF97316)),
      'numbers': ('عالم الأرقام', '🔢', Color(0xFF0EA5E9)),
      'memory': ('عالم الذاكرة', '🧠', Color(0xFF8B5CF6)),
    };

    final worlds = worldProgress.map((row) {
      final meta = worldMeta[row.worldId];
      return _WorldProgressRow(
        worldId: row.worldId,
        title: meta?.$1 ?? row.worldId,
        emoji: meta?.$2 ?? '🌍',
        color: meta?.$3 ?? const Color(0xFF06B6D4),
        completedLevels: row.completedLevels,
        totalLevels: row.totalLevels,
      );
    }).toList();

    final completedWorlds = worlds
        .where((w) => w.totalLevels > 0 && w.completedLevels >= w.totalLevels)
        .length;
    final playedGames = worlds.fold<int>(0, (sum, w) => sum + w.completedLevels);

    const xpPerLevel = 120;
    final totalXp = profile.totalStars * 20;
    final currentXp = totalXp % xpPerLevel;
    final level = (totalXp ~/ xpPerLevel) + 1;

    final badges = <_BadgeInfo>[
      if (profile.totalStars >= 10) const _BadgeInfo(emoji: '🌟', title: 'جامع النجوم'),
      if (profile.totalStars >= 25) const _BadgeInfo(emoji: '🏆', title: 'مغامر متقدم'),
      if (completedWorlds >= 1) const _BadgeInfo(emoji: '🗺️', title: 'رحالة العوالم'),
      if (completedWorlds >= 2) const _BadgeInfo(emoji: '👑', title: 'بطل التقدم'),
    ];

    final recentBadges = badges.isEmpty
        ? const [ _BadgeInfo(emoji: '✨', title: 'ابدأ أول شارة') ]
        : badges.reversed.take(3).toList();

    return _ProfilePageData(
      childName: profile.name,
      totalStars: profile.totalStars,
      badges: profile.badges,
      completedWorlds: completedWorlds,
      playedGames: playedGames,
      level: level,
      currentXp: currentXp,
      maxXp: xpPerLevel,
      worlds: worlds,
      recentBadges: recentBadges,
    );
  }
}
