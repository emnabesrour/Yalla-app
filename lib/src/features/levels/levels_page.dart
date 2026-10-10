import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../data/world_catalog.dart';
import '../../shared/kids_widgets.dart';
import '../../shared/world_painters.dart';

String _dbWorldIdForBlueprint(WorldBlueprint world) {
  switch (world.questionWorldId) {
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

class _LevelNodeData {
  const _LevelNodeData({
    required this.number,
    required this.dbLevelId,
    required this.stars,
    required this.isUnlocked,
    required this.isCurrent,
    required this.isBoss,
  });

  final int number;
  final int dbLevelId;
  final int stars;
  final bool isUnlocked;
  final bool isCurrent;
  final bool isBoss;
}

class LevelsPage extends ConsumerWidget {
  const LevelsPage({super.key, this.worldId = 'forest_rescue'});
  final String worldId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final world = worldById(worldId);
    final dbWorldId = _dbWorldIdForBlueprint(world);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [...world.gradientColors, const Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Floating bg emojis
          ..._buildBgEmojis(context, world.bgEmoji),

          SafeArea(
            child: FutureBuilder<List<LevelModel>>(
              future: ref.read(gameRepositoryProvider).getLevelsByWorld(dbWorldId),
              builder: (context, snapshot) {
                final models = snapshot.data ?? const <LevelModel>[];
                final unlockedModels = models.indexed.map((rec) {
                  final (i, model) = rec;
                  final isWildlifeSecondLevel =
                      world.id == 'wildlife_alba' && i == 1;
                  return (model: model, isUnlocked: model.isUnlocked || isWildlifeSecondLevel);
                }).toList();
                final firstCurrentIndex = models.indexWhere(
                  (m) => m.isUnlocked && m.stars == 0,
                );
                final currentIndex = firstCurrentIndex == -1 &&
                        world.id == 'wildlife_alba'
                    ? 1
                    : firstCurrentIndex;
                final levels = unlockedModels.indexed.map((rec) {
                  final (i, model) = rec;
                  return _LevelNodeData(
                    number: i + 1,
                    dbLevelId: model.model.id,
                    stars: model.model.stars,
                    isUnlocked: model.isUnlocked,
                    isCurrent: currentIndex == -1
                        ? i == (models.length - 1)
                        : i == currentIndex,
                    isBoss: i == models.length - 1,
                  );
                }).toList();
                final stars = levels.fold<int>(0, (sum, item) => sum + item.stars);
                final maxStars = levels.isEmpty ? 0 : levels.length * 3;

                return Column(
                  children: [
                    WorldSceneHeader(
                      worldId: world.sceneWorldId,
                      title: '${world.emoji} ${world.title}',
                      gradientColors: world.gradientColors,
                    ),
                    _LevelsTopBar(
                      title: world.title,
                      emoji: world.emoji,
                      modeLabel: world.modeLabel,
                      stars: stars,
                      maxStars: maxStars,
                    ),
                    Expanded(
                      child: snapshot.connectionState == ConnectionState.waiting
                          ? const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            )
                          : _LevelMap(
                              levels: levels,
                              worldColor: world.gradientColors[0],
                              worldId: world.id,
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBgEmojis(BuildContext context, List<String> emojis) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return emojis.indexed.map((rec) {
      final (i, e) = rec;
      final positions = [
        [.05, .08],
        [.85, .05],
        [.9, .4],
        [.08, .65],
        [.78, .7],
      ];
      final pos = positions[i % positions.length];
      return Positioned(
        left: pos[0] * w,
        top: pos[1] * h,
        child: IgnorePointer(
          child: Text(e, style: const TextStyle(fontSize: 32))
              .animate(
                delay: (i * 150).ms,
                onPlay: (c) => c.repeat(reverse: true),
              )
              .moveY(begin: 0, end: -14, duration: 2200.ms)
              .fade(begin: .25, end: .5),
        ),
      );
    }).toList();
  }
}

class _LevelsTopBar extends StatelessWidget {
  const _LevelsTopBar({
    required this.title,
    required this.emoji,
    required this.modeLabel,
    required this.stars,
    required this.maxStars,
  });
  final String title;
  final String emoji;
  final String modeLabel;
  final int stars;
  final int maxStars;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go(AppRoutes.worlds),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: .3)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '$emoji $title',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      modeLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFDE047),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$stars/$maxStars',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _LevelMap extends StatelessWidget {
  const _LevelMap({
    required this.levels,
    required this.worldColor,
    required this.worldId,
  });
  final List<_LevelNodeData> levels;
  final Color worldColor;
  final String worldId;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final positions = _buildPositions(w, levels.length);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        height: (levels.length * 105).toDouble().clamp(620, 1300),
        child: Stack(
          children: [
            // Connecting path
            Positioned.fill(
              child: CustomPaint(
                painter: _PathPainter(
                  worldColor: worldColor,
                  positions: positions,
                ),
              ),
            ),

            // Level nodes
            ...levels.indexed.map((rec) {
              final (i, level) = rec;
              final pos = positions[i];
              return Positioned(
                left: pos.dx - (level.isBoss ? 44 : 36),
                top: pos.dy,
                child: Builder(
                  builder: (context) => LevelNode(
                    number: level.number,
                    stars: level.stars,
                    isUnlocked: level.isUnlocked,
                    isCurrent: level.isCurrent,
                    color: worldColor,
                    delay: i * 100,
                    size: level.isBoss ? 88 : 72,
                    icon: level.isBoss ? '👑' : null,
                    onTap: () => context.go(
                      '${AppRoutes.game}?level=${level.number}&world=$worldId&dbLevelId=${level.dbLevelId}',
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  List<Offset> _buildPositions(double width, int count) {
    final centerX = width * .5;
    final lane = width * .26;
    const startY = 36.0;
    const stepY = 100.0;
    return List.generate(count, (i) {
      final swing = (i % 4 == 0 || i % 4 == 3) ? 0 : (i.isEven ? lane : -lane);
      final y = startY + (count - 1 - i) * stepY;
      return Offset(centerX + swing, y);
    });
  }
}

class _PathPainter extends CustomPainter {
  const _PathPainter({required this.worldColor, required this.positions});
  final Color worldColor;
  final List<Offset> positions;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = worldColor.withValues(alpha: .3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: .35)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(positions[0].dx, positions[0].dy);
    for (int i = 1; i < positions.length; i++) {
      final prev = positions[i - 1];
      final curr = positions[i];
      final cp = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
      path.quadraticBezierTo(prev.dx, prev.dy, cp.dx, cp.dy);
    }

    canvas.drawPath(path, paint);

    // Draw dashes
    final dashPath = _createDashedPath(path, 12, 6);
    canvas.drawPath(dashPath, dashPaint);
  }

  Path _createDashedPath(Path source, double dashLen, double gapLen) {
    final result = Path();
    for (final metric in source.computeMetrics()) {
      double d = 0;
      bool draw = true;
      while (d < metric.length) {
        if (draw) {
          result.addPath(metric.extractPath(d, d + dashLen), Offset.zero);
        }
        d += draw ? dashLen : gapLen;
        draw = !draw;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) => true;
}
