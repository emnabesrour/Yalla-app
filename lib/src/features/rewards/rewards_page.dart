import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';

Color _adaptiveSecondaryText(
  BuildContext context, {
  required double darkAlpha,
  required double lightAlpha,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Colors.white.withValues(alpha: isDark ? darkAlpha : lightAlpha);
}

class _Badge {
  const _Badge({
    required this.emoji,
    required this.name,
    required this.description,
    required this.earned,
    required this.color,
  });
  final String emoji;
  final String name;
  final String description;
  final bool earned;
  final Color color;
}

final rewardsPageDataProvider = FutureProvider.autoDispose<_RewardsPageData>((
  ref,
) async {
  final repository = ref.read(gameRepositoryProvider);
  final profile = await repository.getProfile();
  final worldProgress = await repository.getWorldProgress();
  return _RewardsPageData.from(profile: profile, worldProgress: worldProgress);
});

class RewardsPage extends ConsumerWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundGradient = isDark
        ? const [
            Color(0xFF1A0533),
            Color(0xFF2D1B69),
            Color(0xFF0F2027),
          ]
        : const [
            Color(0xFF4E66C7),
            Color(0xFF5B6EC9),
            Color(0xFF4B7AA8),
          ];
    final rewardsDataAsync = ref.watch(rewardsPageDataProvider);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: backgroundGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: rewardsDataAsync.when(
              data: (data) => Column(
                children: [
                  _TopBar(childName: data.childName),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          _TotalStarsCard(data: data),
                          const SizedBox(height: 24),
                          const Text(
                            '🏅 شاراتي',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ).animate().fadeIn(duration: 300.ms),
                          const SizedBox(height: 14),
                          _BadgeGrid(badges: data.badgesList),
                          const SizedBox(height: 24),
                          const Text(
                            '🎁 الجوائز المتاحة',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
                          const SizedBox(height: 14),
                          _UnlockablesSection(totalStars: data.totalStars),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (_, _) => Center(
                child: FilledButton(
                  onPressed: () => ref.invalidate(rewardsPageDataProvider),
                  child: const Text('إعادة المحاولة'),
                ),
              ),
            ),
          ),
          const Positioned(
            left: 14,
            right: 14,
            bottom: 12,
            child: _RewardsFloatingBottomNav(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go(AppRoutes.home),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: .25)),
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
            'مكافآتي',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Text(
            childName,
            style: TextStyle(
              color: _adaptiveSecondaryText(
                context,
                darkAlpha: .8,
                lightAlpha: .95,
              ),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          const Text('🎁', style: TextStyle(fontSize: 32)),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _TotalStarsCard extends StatelessWidget {
  const _TotalStarsCard({required this.data});

  final _RewardsPageData data;

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: .4),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 52)),
              const SizedBox(width: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${data.totalStars}',
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  Text(
                    'نجمة مجموعة',
                    style: TextStyle(
                      fontSize: 15,
                      color: _adaptiveSecondaryText(
                        context,
                        darkAlpha: .85,
                        lightAlpha: .98,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '🏆 ${data.badges} شارة',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '🌍 ${data.completedWorlds}/${data.totalWorlds} عوالم',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 380.ms)
        .scale(begin: const Offset(.9, .9), curve: Curves.easeOutBack);
  }
}

class _BadgeGrid extends StatelessWidget {
  const _BadgeGrid({required this.badges});

  final List<_Badge> badges;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: .85,
      ),
      itemCount: badges.length,
      itemBuilder: (_, i) => _BadgeCard(badge: badges[i], index: i),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge, required this.index});
  final _Badge badge;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
          decoration: BoxDecoration(
            color: badge.earned
                ? badge.color.withValues(alpha: .2)
                : Colors.white.withValues(alpha: .06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: badge.earned
                  ? badge.color.withValues(alpha: .5)
                  : Colors.white.withValues(alpha: .12),
              width: 1.5,
            ),
            boxShadow: badge.earned
                ? [
                    BoxShadow(
                      color: badge.color.withValues(alpha: .25),
                      blurRadius: 12,
                    ),
                  ]
                : [],
          ),
          child: Stack(
            children: [
              if (!badge.earned)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      badge.emoji,
                      style: TextStyle(fontSize: badge.earned ? 40 : 34),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      badge.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: badge.earned ? Colors.white : Colors.white38,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (!badge.earned)
                      const Icon(
                        Icons.lock_rounded,
                        color: Colors.white38,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(delay: (index * 60).ms)
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(.8, .8), curve: Curves.easeOutBack);
  }
}

class _UnlockablesSection extends StatelessWidget {
  const _UnlockablesSection({required this.totalStars});

  final int totalStars;

  static const _items = [
    ('🦊', 'ثعلب الطبيعة', '50 ⭐'),
    ('🐬', 'دولفين البحر', '80 ⭐'),
    ('🦁', 'أسد الغابة', '100 ⭐'),
    ('🦄', 'وحيد القرن السحري', '150 ⭐'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _items.indexed.map((rec) {
        final (i, item) = rec;
        final requiredStars = int.parse(item.$3.split(' ').first);
        final canAfford = totalStars >= requiredStars;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: canAfford ? .14 : .07),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: canAfford ? .3 : .12),
              ),
            ),
            child: Column(
              children: [
                Text(item.$1, style: const TextStyle(fontSize: 36)),
                const SizedBox(height: 6),
                Text(
                  item.$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: canAfford ? Colors.white : Colors.white38,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: canAfford
                        ? const Color(0xFFF59E0B).withValues(alpha: .3)
                        : Colors.white.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.$3,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: canAfford ? Colors.white : Colors.white38,
                    ),
                  ),
                ),
              ],
            ),
          ).animate(delay: (i * 70).ms).fadeIn(duration: 300.ms),
        );
      }).toList(),
    );
  }
}

class _RewardsPageData {
  const _RewardsPageData({
    required this.childName,
    required this.totalStars,
    required this.badges,
    required this.completedWorlds,
    required this.totalWorlds,
    required this.badgesList,
  });

  final String childName;
  final int totalStars;
  final int badges;
  final int completedWorlds;
  final int totalWorlds;
  final List<_Badge> badgesList;

  factory _RewardsPageData.from({
    required ChildProfile profile,
    required List<WorldProgress> worldProgress,
  }) {
    final totalWorlds = worldProgress.length;
    final completedWorlds = worldProgress
        .where((w) => w.totalLevels > 0 && w.completedLevels >= w.totalLevels)
        .length;

    final badgesList = [
      _Badge(
        emoji: '🌟',
        name: 'جامع النجوم',
        description: 'اجمع 10 نجوم',
        earned: profile.totalStars >= 10,
        color: const Color(0xFFF59E0B),
      ),
      _Badge(
        emoji: '🏆',
        name: 'مغامر متقدم',
        description: 'اجمع 25 نجمة',
        earned: profile.totalStars >= 25,
        color: const Color(0xFF0EA5E9),
      ),
      _Badge(
        emoji: '⚡',
        name: 'سريع البرق',
        description: 'اجمع 40 نجمة',
        earned: profile.totalStars >= 40,
        color: const Color(0xFFF59E0B),
      ),
      _Badge(
        emoji: '🌍',
        name: 'رحالة العوالم',
        description: 'أكمل عالما واحدا',
        earned: completedWorlds >= 1,
        color: const Color(0xFF1DB954),
      ),
      _Badge(
        emoji: '🗺️',
        name: 'مستكشف العوالم',
        description: 'أكمل نصف العوالم',
        earned: totalWorlds > 0 && completedWorlds >= (totalWorlds / 2).ceil(),
        color: const Color(0xFF8B5CF6),
      ),
      _Badge(
        emoji: '👑',
        name: 'بطل البيئة',
        description: 'أكمل كل العوالم',
        earned: totalWorlds > 0 && completedWorlds == totalWorlds,
        color: const Color(0xFF06B6D4),
      ),
    ];

    return _RewardsPageData(
      childName: profile.name,
      totalStars: profile.totalStars,
      badges: profile.badges,
      completedWorlds: completedWorlds,
      totalWorlds: totalWorlds,
      badgesList: badgesList,
    );
  }
}

class _RewardsFloatingBottomNav extends StatelessWidget {
  const _RewardsFloatingBottomNav();

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
              _RewardsNavButton(
                label: 'الرئيسية',
                icon: Icons.home_rounded,
                active: false,
                onTap: () => context.go(AppRoutes.home),
              ),
              _RewardsNavButton(
                label: 'العوالم',
                icon: Icons.public_rounded,
                active: false,
                onTap: () => context.go(AppRoutes.worlds),
              ),
              _RewardsNavButton(
                label: 'المكافآت',
                icon: Icons.workspace_premium_rounded,
                active: true,
                onTap: () => context.go(AppRoutes.rewards),
              ),
              _RewardsNavButton(
                label: 'ملفي',
                icon: Icons.account_circle_rounded,
                active: false,
                onTap: () => context.go(AppRoutes.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardsNavButton extends StatelessWidget {
  const _RewardsNavButton({
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              decoration: BoxDecoration(
                color: active
                    ? Colors.white.withValues(alpha: .18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: const Color(0xFF8B7DFF).withValues(alpha: .26),
                          blurRadius: 12,
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
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
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
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 260.ms)
        .scaleXY(begin: .96, end: 1, duration: 240.ms);
  }
}
