import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ─── Animated Parallax Scene ─────────────────────────────────────────────

class ParallaxWorldScene extends StatefulWidget {
  const ParallaxWorldScene({
    super.key,
    required this.worldId,
    this.height = 280,
    this.showFull = false,
  });
  final String worldId;
  final double height;
  final bool showFull;

  @override
  State<ParallaxWorldScene> createState() => _ParallaxWorldSceneState();
}

class _ParallaxWorldSceneState extends State<ParallaxWorldScene>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, anim) => SizedBox(
        height: widget.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.showFull ? 0 : 28),
          child: CustomPaint(
            painter: _WorldScenePainter(
              worldId: widget.worldId,
              animValue: _ctrl.value,
            ),
            child: _WorldOverlayWidgets(
              worldId: widget.worldId,
              animValue: _ctrl.value,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Scene Painter ────────────────────────────────────────────────────────

class _WorldScenePainter extends CustomPainter {
  const _WorldScenePainter({required this.worldId, required this.animValue});
  final String worldId;
  final double animValue;

  @override
  void paint(Canvas canvas, Size size) {
    switch (worldId) {
      case 'forest':
        _paintForest(canvas, size);
      case 'ocean':
        _paintOcean(canvas, size);
      case 'animals':
        _paintJungle(canvas, size);
      case 'recycling':
        _paintCity(canvas, size);
      case 'energy':
        _paintSunCity(canvas, size);
      case 'earth':
        _paintCosmos(canvas, size);
      default:
        _paintForest(canvas, size);
    }
  }

  // ── Forest ────────────────────────────────────────────────────────────
  void _paintForest(Canvas canvas, Size size) {
    // Sky gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0D7A3A), Color(0xFF1DB954), Color(0xFF57D68D)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Sun glow
    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50)
      ..color = const Color(0xFFFFF9C4).withValues(alpha: .4);
    canvas.drawCircle(Offset(size.width * .75, size.height * .15), 60, glowPaint);

    // Ground layer
    final groundPaint = Paint()..color = const Color(0xFF0A5C2A);
    final groundPath = Path()
      ..moveTo(0, size.height * .7)
      ..quadraticBezierTo(
        size.width * .5,
        size.height * .62,
        size.width,
        size.height * .7,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(groundPath, groundPaint);

    // River
    final riverPaint = Paint()
      ..color = const Color(0xFF4FC3F7).withValues(alpha: .7)
      ..style = PaintingStyle.fill;
    final wave = sin(animValue * 2 * pi) * 4;
    final riverPath = Path()
      ..moveTo(size.width * .3, size.height * .68)
      ..quadraticBezierTo(
        size.width * .5 + wave,
        size.height * .72,
        size.width * .7,
        size.height * .68,
      )
      ..quadraticBezierTo(
        size.width * .5 + wave,
        size.height * .76,
        size.width * .3,
        size.height * .74,
      )
      ..close();
    canvas.drawPath(riverPath, riverPaint);

    // Trees (back layer)
    _drawTree(canvas, size, .1, .62, 55, const Color(0xFF0A5C2A), const Color(0xFF1DB954));
    _drawTree(canvas, size, .28, .58, 70, const Color(0xFF0A5C2A), const Color(0xFF14A04A));
    _drawTree(canvas, size, .78, .6, 60, const Color(0xFF0A5C2A), const Color(0xFF1DB954));
    _drawTree(canvas, size, .92, .55, 75, const Color(0xFF0A5C2A), const Color(0xFF14A04A));

    // Fog effect
    final fogPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: .0),
          Colors.white.withValues(alpha: .12),
          Colors.white.withValues(alpha: .0),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, size.height * .55, size.width, size.height * .25));
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * .55, size.width, size.height * .25),
      fogPaint,
    );

    // Particles (fireflies / spores)
    final particlePositions = [
      [.15, .45], [.4, .35], [.65, .4], [.85, .38], [.5, .55], [.25, .6],
    ];
    for (int i = 0; i < particlePositions.length; i++) {
      final phase = animValue * 2 * pi + i * 1.05;
      final dy = sin(phase) * 6;
      final alpha = (sin(phase) + 1) / 2 * .7 + .1;
      canvas.drawCircle(
        Offset(
          particlePositions[i][0] * size.width,
          particlePositions[i][1] * size.height + dy,
        ),
        3 + sin(phase) * 1.5,
        Paint()..color = const Color(0xFFFFF9C4).withValues(alpha: alpha),
      );
    }
  }

  void _drawTree(Canvas canvas, Size size, double xRatio, double yRatio,
      double h, Color dark, Color light) {
    final x = xRatio * size.width;
    final y = yRatio * size.height;
    final trunkPaint = Paint()..color = const Color(0xFF5D4037);
    final trunkRect = Rect.fromLTWH(x - 5, y, 10, h * .35);
    canvas.drawRect(trunkRect, trunkPaint);
    final leafPaint = Paint()
      ..shader = RadialGradient(
        colors: [light, dark],
      ).createShader(Rect.fromCircle(center: Offset(x, y - h * .15), radius: h * .45));
    canvas.drawCircle(Offset(x, y - h * .05), h * .42, leafPaint);
    canvas.drawCircle(Offset(x - h * .25, y + h * .1), h * .32, leafPaint);
    canvas.drawCircle(Offset(x + h * .25, y + h * .1), h * .32, leafPaint);
  }

  // ── Ocean ─────────────────────────────────────────────────────────────
  void _paintOcean(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0C1A3A), Color(0xFF0369A1), Color(0xFF0EA5E9)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Caustic light rays
    for (int i = 0; i < 5; i++) {
      final x = (i + .5) * size.width / 5;
      final phase = animValue * 2 * pi + i * .8;
      final alpha = (sin(phase) + 1) / 2 * .15 + .04;
      final rayPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFB3E5FC).withValues(alpha: 0),
            const Color(0xFFB3E5FC).withValues(alpha: alpha),
            const Color(0xFFB3E5FC).withValues(alpha: 0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(x - 20, 0, 40, size.height));
      canvas.drawRect(Rect.fromLTWH(x - 20, 0, 40, size.height), rayPaint);
    }

    // Coral reef bottom
    _drawCoral(canvas, size, .1, .82, const Color(0xFFFF7043));
    _drawCoral(canvas, size, .35, .78, const Color(0xFFFF8A65));
    _drawCoral(canvas, size, .65, .8, const Color(0xFFE91E63));
    _drawCoral(canvas, size, .88, .76, const Color(0xFFFF5722));

    // Sandy floor
    final sandPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFD4A574), Color(0xFFC49A6C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, size.height * .85, size.width, size.height * .15));
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * .85, size.width, size.height * .15), sandPaint);

    // Bubbles
    for (int i = 0; i < 8; i++) {
      final bx = (i * size.width / 7) + (i % 2 == 0 ? 20.0 : -20.0);
      final by = size.height * .9 - (animValue * size.height * .65 + i * size.height / 8) % (size.height * .8);
      canvas.drawCircle(
        Offset(bx, by),
        3.5 + i % 3,
        Paint()
          ..color = Colors.white.withValues(alpha: .25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  void _drawCoral(Canvas canvas, Size size, double xR, double yR, Color color) {
    final x = xR * size.width;
    final y = yR * size.height;
    final h = size.height * .12;
    final p = Paint()..color = color;
    canvas.drawRect(Rect.fromLTWH(x - 3, y - h, 6, h), p);
    for (int i = 0; i < 4; i++) {
      final angle = -pi / 2 + (i - 1.5) * .6;
      canvas.drawCircle(
        Offset(x + cos(angle) * h * .5, y - h * .6 + sin(angle) * h * .3),
        h * .18,
        p,
      );
    }
  }

  // ── Jungle ────────────────────────────────────────────────────────────
  void _paintJungle(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE65100), Color(0xFFF97316), Color(0xFF4CAF50)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Waterfall
    final wfPaint = Paint()
      ..color = const Color(0xFF4FC3F7).withValues(alpha: .55)
      ..style = PaintingStyle.fill;
    final wOffset = sin(animValue * 2 * pi) * 3;
    final wPath = Path()
      ..moveTo(size.width * .72 + wOffset, size.height * .12)
      ..lineTo(size.width * .78 + wOffset, size.height * .12)
      ..lineTo(size.width * .82, size.height * .75)
      ..lineTo(size.width * .68, size.height * .75)
      ..close();
    canvas.drawPath(wPath, wfPaint);

    // Ground
    final groundPaint = Paint()..color = const Color(0xFF2E7D32);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * .7, size.width, size.height * .3),
      groundPaint,
    );

    // Big leaves
    _drawLeaf(canvas, size, .05, .5, .3, const Color(0xFF1B5E20));
    _drawLeaf(canvas, size, .55, .45, .35, const Color(0xFF388E3C));
    _drawLeaf(canvas, size, .85, .55, .25, const Color(0xFF2E7D32));
  }

  void _drawLeaf(Canvas canvas, Size size, double xR, double yR, double scale,
      Color color) {
    final x = xR * size.width;
    final y = yR * size.height;
    final w = size.width * scale;
    final path = Path()
      ..moveTo(x, y + w * .6)
      ..quadraticBezierTo(x - w * .5, y, x, y - w * .2)
      ..quadraticBezierTo(x + w * .5, y, x, y + w * .6);
    canvas.drawPath(path, Paint()..color = color);
  }

  // ── Futuristic City (Recycling) ───────────────────────────────────────
  void _paintCity(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0D0025), Color(0xFF1A0050), Color(0xFF4A0080)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Grid lines (futuristic floor)
    final gridPaint = Paint()
      ..color = const Color(0xFF8B5CF6).withValues(alpha: .15)
      ..strokeWidth = 1;
    for (int i = 0; i < 10; i++) {
      final x = i * size.width / 9;
      canvas.drawLine(Offset(x, size.height * .6), Offset(size.width / 2, size.height), gridPaint);
    }
    for (int i = 0; i < 5; i++) {
      final t = i / 4.0;
      final y = size.height * (.6 + t * .4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Buildings
    _drawBuilding(canvas, size, .05, .75, .12, .35, const Color(0xFF6D28D9));
    _drawBuilding(canvas, size, .2, .75, .1, .5, const Color(0xFF7C3AED));
    _drawBuilding(canvas, size, .68, .75, .14, .4, const Color(0xFF8B5CF6));
    _drawBuilding(canvas, size, .84, .75, .1, .28, const Color(0xFF6D28D9));

    // Glow accents on buildings
    for (int i = 0; i < 6; i++) {
      final phase = animValue * 2 * pi + i * 1.0;
      final alpha = (sin(phase) + 1) / 2 * .5 + .2;
      canvas.drawCircle(
        Offset((i + .5) * size.width / 6, size.height * .58),
        4,
        Paint()..color = const Color(0xFF8B5CF6).withValues(alpha: alpha),
      );
    }
  }

  void _drawBuilding(Canvas canvas, Size size, double xR, double baseYR,
      double wR, double hR, Color color) {
    final x = xR * size.width;
    final baseY = baseYR * size.height;
    final w = wR * size.width;
    final h = hR * size.height;
    final p = Paint()..color = color;
    canvas.drawRect(Rect.fromLTWH(x, baseY - h, w, h), p);
    // Windows
    final winPaint = Paint()
      ..color = const Color(0xFF7DF9FF).withValues(alpha: .5);
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 2; col++) {
        canvas.drawRect(
          Rect.fromLTWH(
            x + 4 + col * (w / 2 - 2),
            baseY - h + 8 + row * (h / 4 - 4),
            w / 2 - 8,
            h / 4 - 8,
          ),
          winPaint,
        );
      }
    }
  }

  // ── Sun City (Energy) ─────────────────────────────────────────────────
  void _paintSunCity(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1A237E), Color(0xFF3949AB), Color(0xFFFFA000)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Sun
    final sunPhase = animValue * 2 * pi;
    final sunY = size.height * .22 + sin(sunPhase) * 5;
    final sunGlow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40)
      ..color = const Color(0xFFFACC15).withValues(alpha: .5);
    canvas.drawCircle(Offset(size.width * .5, sunY), 55, sunGlow);
    canvas.drawCircle(
      Offset(size.width * .5, sunY),
      38,
      Paint()..color = const Color(0xFFFACC15),
    );

    // Sun rays
    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4 + animValue * pi / 8;
      final x1 = size.width * .5 + cos(angle) * 50;
      final y1 = sunY + sin(angle) * 50;
      final x2 = size.width * .5 + cos(angle) * 75;
      final y2 = sunY + sin(angle) * 75;
      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        Paint()
          ..color = const Color(0xFFFEF08A).withValues(alpha: .7)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }

    // Solar panels (futuristic field)
    final ground = Paint()..color = const Color(0xFF1A237E);
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * .72, size.width, size.height * .28), ground);
    for (int i = 0; i < 5; i++) {
      final px = (i + .5) * size.width / 5;
      final py = size.height * .76;
      canvas.drawRect(
        Rect.fromLTWH(px - 22, py, 44, 28),
        Paint()..color = const Color(0xFF0EA5E9).withValues(alpha: .7),
      );
      canvas.drawLine(
        Offset(px, py + 28),
        Offset(px, py + 50),
        Paint()..color = const Color(0xFF475569)..strokeWidth = 3,
      );
    }
  }

  // ── Cosmos (Earth Guardian) ───────────────────────────────────────────
  void _paintCosmos(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF000212), Color(0xFF000B24), Color(0xFF011936)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Stars
    final rng = Random(42);
    for (int i = 0; i < 60; i++) {
      final starPhase = animValue * 2 * pi + i * .2;
      final alpha = (sin(starPhase) + 1) / 2 * .6 + .1;
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height * .75),
        rng.nextDouble() * 1.8 + .5,
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }

    // Nebula glow
    for (final c in [
      [.2, .25, const Color(0xFF06B6D4)],
      [.75, .4, const Color(0xFF8B5CF6)],
      [.5, .12, const Color(0xFF0EA5E9)],
    ]) {
      final xR = c[0] as double;
      final yR = c[1] as double;
      final col = c[2] as Color;
      canvas.drawCircle(
        Offset(xR * size.width, yR * size.height),
        size.width * .28,
        Paint()
          ..color = col.withValues(alpha: .08)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45),
      );
    }

    // Earth
    final earthPhase = animValue * 2 * pi;
    final earthGlow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22)
      ..color = const Color(0xFF06B6D4).withValues(alpha: .45);
    canvas.drawCircle(Offset(size.width * .5, size.height * .48), 62, earthGlow);

    final earthPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF0EA5E9), const Color(0xFF1565C0)],
        center: Alignment(-cos(earthPhase) * .3, -.3),
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * .5, size.height * .48),
        radius: 50,
      ));
    canvas.drawCircle(Offset(size.width * .5, size.height * .48), 50, earthPaint);

    // Continents (simplified)
    final landPaint = Paint()..color = const Color(0xFF1DB954).withValues(alpha: .7);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .5 - 12, size.height * .44),
        width: 28, height: 36,
      ),
      landPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .5 + 16, size.height * .52),
        width: 20, height: 28,
      ),
      landPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WorldScenePainter old) =>
      old.animValue != animValue;
}

// ─── Overlay Emoji / Animated Widgets ────────────────────────────────────

class _WorldOverlayWidgets extends StatelessWidget {
  const _WorldOverlayWidgets({required this.worldId, required this.animValue});
  final String worldId;
  final double animValue;

  @override
  Widget build(BuildContext context) {
    final emojis = _getEmojis();
    return Stack(
      fit: StackFit.expand,
      children: emojis.indexed.map((rec) {
        final (i, item) = rec;
        final dy = -14.0 * sin(animValue * 2 * 3.14159 + i * 1.1);
        return Positioned(
          left: item.x * MediaQuery.of(context).size.width,
          top: item.y * _parentHeight(context) + dy,
          child: IgnorePointer(
            child: Text(item.e, style: TextStyle(fontSize: item.size))
                .animate(
                  delay: (i * 80).ms,
                  onPlay: (c) => c.repeat(reverse: true),
                )
                .fade(begin: .45, end: .9, duration: 1800.ms),
          ),
        );
      }).toList(),
    );
  }

  double _parentHeight(BuildContext context) => 280;

  List<_EmojiPos> _getEmojis() {
    switch (worldId) {
      case 'forest':
        return [
          _EmojiPos('🦋', .62, .18, 26), _EmojiPos('🌸', .45, .08, 22),
          _EmojiPos('🐦', .82, .28, 20), _EmojiPos('🍃', .18, .22, 18),
        ];
      case 'ocean':
        return [
          _EmojiPos('🐠', .15, .42, 24), _EmojiPos('🐢', .7, .35, 28),
          _EmojiPos('🐙', .45, .55, 26), _EmojiPos('🦀', .85, .6, 20),
        ];
      case 'animals':
        return [
          _EmojiPos('🦁', .12, .35, 30), _EmojiPos('🐘', .72, .4, 28),
          _EmojiPos('🦒', .5, .22, 26), _EmojiPos('🦜', .88, .18, 22),
        ];
      case 'recycling':
        return [
          _EmojiPos('♻️', .08, .12, 24), _EmojiPos('🌱', .78, .15, 22),
          _EmojiPos('💚', .45, .2, 20), _EmojiPos('🔄', .92, .4, 18),
        ];
      case 'energy':
        return [
          _EmojiPos('⚡', .15, .1, 26), _EmojiPos('🔋', .82, .12, 22),
          _EmojiPos('💡', .45, .3, 24), _EmojiPos('🌤️', .62, .08, 28),
        ];
      case 'earth':
        return [
          _EmojiPos('🚀', .15, .12, 26), _EmojiPos('🌟', .75, .08, 24),
          _EmojiPos('💫', .5, .18, 20), _EmojiPos('🛸', .88, .3, 22),
        ];
      default:
        return [];
    }
  }
}

class _EmojiPos {
  const _EmojiPos(this.e, this.x, this.y, this.size);
  final String e;
  final double x;
  final double y;
  final double size;
}

// ─── World Header with Scene ──────────────────────────────────────────────

class WorldSceneHeader extends StatelessWidget {
  const WorldSceneHeader({
    super.key,
    required this.worldId,
    required this.title,
    required this.gradientColors,
  });
  final String worldId;
  final String title;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ParallaxWorldScene(worldId: worldId, height: 200, showFull: true),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, gradientColors[1].withValues(alpha: .9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black26, blurRadius: 6)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
