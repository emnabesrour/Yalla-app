import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../data/world_catalog.dart';

Color _adaptiveSecondaryText(
  BuildContext context, {
  required double darkAlpha,
  required double lightAlpha,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Colors.white.withValues(alpha: isDark ? darkAlpha : lightAlpha);
}

String _dbWorldIdForBlueprint(WorldBlueprint blueprint) {
  switch (blueprint.questionWorldId) {
    case 'forest':
      return 'colors';
    case 'animals':
      return 'animals';
    case 'ocean':
      return 'numbers';
    case 'energy':
    case 'earth':
      return 'memory';
    default:
      return 'colors';
  }
}

final worldsPageDataProvider = FutureProvider.autoDispose<_WorldsPageData>((
  ref,
) async {
  final repository = ref.read(gameRepositoryProvider);
  final profile = await repository.getProfile();
  final progress = await repository.getWorldProgress();
  return _WorldsPageData.from(profile: profile, progress: progress);
});

class WorldsPage extends ConsumerWidget {
  const WorldsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundGradient = isDark
        ? const [
            Color(0xFF0F172A),
            Color(0xFF1E1B4B),
            Color(0xFF0F2027),
          ]
        : const [
            Color(0xFF4A6ED3),
            Color(0xFF4A7ACF),
            Color(0xFF4868AE),
          ];
    final worldsDataAsync = ref.watch(worldsPageDataProvider);
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

          // Star field background
          ..._buildStarField(context),

          SafeArea(
            child: worldsDataAsync.when(
              data: (data) => Column(
                children: [
                  _TopBar(
                    childName: data.childName,
                    completedWorlds: data.completedWorlds,
                    totalWorlds: data.totalWorlds,
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
                      itemCount: data.worlds.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _WorldCard(world: data.worlds[i], index: i),
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
                  onPressed: () => ref.invalidate(worldsPageDataProvider),
                  child: const Text('إعادة المحاولة'),
                ),
              ),
            ),
          ),
          const Positioned(
            left: 14,
            right: 14,
            bottom: 12,
            child: _WorldsFloatingBottomNav(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStarField(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return List.generate(20, (i) {
      final x = (i * 73.7) % w;
      final y = (i * 47.3) % h;
      return Positioned(
        left: x,
        top: y,
        child:
            Container(
                  width: 2,
                  height: 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .4),
                  ),
                )
                .animate(
                  delay: (i * 100).ms,
                  onPlay: (c) => c.repeat(reverse: true),
                )
                .fade(begin: .1, end: .8, duration: 1500.ms),
      );
    });
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.childName,
    required this.completedWorlds,
    required this.totalWorlds,
  });

  final String childName;
  final int completedWorlds;
  final int totalWorlds;

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'خريطة العوالم',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                '$childName • أنهيت $completedWorlds/$totalWorlds عوالم',
                style: TextStyle(
                  fontSize: 14,
                  color: _adaptiveSecondaryText(
                    context,
                    darkAlpha: .65,
                    lightAlpha: .9,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text('🗺️', style: TextStyle(fontSize: 32)),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -.1, end: 0);
  }
}

class _WorldCard extends StatefulWidget {
  const _WorldCard({required this.world, required this.index});
  final _WorldCardData world;
  final int index;

  @override
  State<_WorldCard> createState() => _WorldCardState();
}

class _WorldCardState extends State<_WorldCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final w = widget.world;
    return GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: w.isUnlocked
              ? () => context.go('${AppRoutes.levels}?world=${w.blueprint.id}')
              : null,
          child: AnimatedScale(
            scale: _pressed ? .97 : 1.0,
            duration: const Duration(milliseconds: 130),
            curve: Curves.easeOutBack,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: w.isUnlocked
                    ? LinearGradient(
                        colors: w.blueprint.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF334155), Color(0xFF475569)],
                      ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: w.isUnlocked
                    ? [
                        BoxShadow(
                          color: w.blueprint.gradientColors[0].withValues(alpha: .4),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [],
              ),
              child: Stack(
                children: [
                  // Sheen overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: .18),
                            Colors.transparent,
                            Colors.black.withValues(alpha: .08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),

                  // Floating bg emojis
                  ...w.blueprint.bgEmoji.indexed.map((rec) {
                    final (i, e) = rec;
                    final positions = [
                      [.72, .06],
                      [.82, .45],
                      [.88, .78],
                      [.6, .72],
                      [.52, .15],
                    ];
                    final pos = positions[i % positions.length];
                    return Positioned(
                      left: pos[0] * 280,
                      top: pos[1] * 150,
                      child: IgnorePointer(
                        child: Text(e, style: const TextStyle(fontSize: 24))
                            .animate(
                              delay: (i * 120 + widget.index * 60).ms,
                              onPlay: (c) => c.repeat(reverse: true),
                            )
                            .moveY(begin: 0, end: -8, duration: 2000.ms)
                            .fade(begin: .3, end: .55),
                      ),
                    );
                  }),

                  // Lock overlay
                  if (!w.isUnlocked)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .35),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              w.blueprint.emoji,
                              style: const TextStyle(fontSize: 44),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  alignment: WrapAlignment.end,
                                  children: [
                                    if (w.isUnlocked)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: .16,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          w.blueprint.modeLabel,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    if (w.isUnlocked)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: .25,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '${w.completedLevels}/${w.totalLevels}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    if (!w.isUnlocked)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: .2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Text(
                                          '🔒 مغلق',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '${w.blueprint.title} ${w.blueprint.emoji}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          w.blueprint.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.25,
                            color: _adaptiveSecondaryText(
                              context,
                              darkAlpha: .8,
                              lightAlpha: .95,
                            ),
                          ),
                        ),
                        if (w.isUnlocked) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: w.totalLevels == 0
                                  ? 0
                                  : w.completedLevels / w.totalLevels,
                              minHeight: 6,
                              backgroundColor: Colors.white.withValues(
                                alpha: .25,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: (widget.index * 80).ms)
        .fadeIn(duration: 380.ms)
        .scale(begin: const Offset(.9, .9), curve: Curves.easeOutBack);
  }
}

class _WorldCardData {
  const _WorldCardData({
    required this.blueprint,
    required this.completedLevels,
    required this.totalLevels,
    required this.isUnlocked,
  });

  final WorldBlueprint blueprint;
  final int completedLevels;
  final int totalLevels;
  final bool isUnlocked;
}

class _WorldsPageData {
  const _WorldsPageData({
    required this.childName,
    required this.completedWorlds,
    required this.totalWorlds,
    required this.worlds,
  });

  final String childName;
  final int completedWorlds;
  final int totalWorlds;
  final List<_WorldCardData> worlds;

  factory _WorldsPageData.from({
    required ChildProfile profile,
    required List<WorldProgress> progress,
  }) {
    final byWorldId = {for (final p in progress) p.worldId: p};
    var unlockedByFlow = true;
    final worlds = <_WorldCardData>[];

    for (final blueprint in worldCatalog) {
      final dbWorldId = _dbWorldIdForBlueprint(blueprint);
      final progressForWorld = byWorldId[dbWorldId];
      final totalLevels = progressForWorld?.totalLevels ?? blueprint.totalLevels;
      final completedLevels = progressForWorld?.completedLevels ?? 0;
      final isUnlocked = unlockedByFlow || blueprint.isUnlocked;

      worlds.add(
        _WorldCardData(
          blueprint: blueprint,
          completedLevels: completedLevels.clamp(0, totalLevels),
          totalLevels: totalLevels,
          isUnlocked: isUnlocked,
        ),
      );

      unlockedByFlow = completedLevels > 0;
    }

    final completedWorlds = worlds
        .where((w) => w.totalLevels > 0 && w.completedLevels >= w.totalLevels)
        .length;

    return _WorldsPageData(
      childName: profile.name,
      completedWorlds: completedWorlds,
      totalWorlds: worlds.length,
      worlds: worlds,
    );
  }
}

class _WorldsFloatingBottomNav extends StatelessWidget {
  const _WorldsFloatingBottomNav();

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
              _WorldsNavButton(
                label: 'الرئيسية',
                icon: Icons.home_rounded,
                active: false,
                onTap: () => context.go(AppRoutes.home),
              ),
              _WorldsNavButton(
                label: 'العوالم',
                icon: Icons.public_rounded,
                active: true,
                onTap: () => context.go(AppRoutes.worlds),
              ),
              _WorldsNavButton(
                label: 'المكافآت',
                icon: Icons.workspace_premium_rounded,
                active: false,
                onTap: () => context.go(AppRoutes.rewards),
              ),
              _WorldsNavButton(
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

class _WorldsNavButton extends StatelessWidget {
  const _WorldsNavButton({
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
