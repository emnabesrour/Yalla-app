import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

// ─── Mascot Mood ──────────────────────────────────────────────────────────

enum MascotMood { idle, happy, wrong, excited, calm }

// ─── Mascot (painted fallback; no native Rive on desktop) ────────────────

class RiveMascot extends StatelessWidget {
  const RiveMascot({super.key, this.mood = MascotMood.idle, this.size = 120});
  final MascotMood mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _PainterMascotFallback(mood: mood, size: size);
  }
}

class _PainterMascotFallback extends StatelessWidget {
  const _PainterMascotFallback({required this.mood, required this.size});
  final MascotMood mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: .5),
                blurRadius: size * .35,
                spreadRadius: size * .05,
              ),
            ],
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: CustomPaint(
            painter: _MascotPainter(
              mood: mood,
              blinkAmount: mood == MascotMood.calm ? .65 : 0,
            ),
            child: const SizedBox.expand(),
          ),
        )
        .animate(key: ValueKey(mood))
        .scale(
          begin: const Offset(.7, .7),
          duration: 350.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 250.ms);
  }
}

class PremiumEcoMascotCharacter extends StatefulWidget {
  const PremiumEcoMascotCharacter({super.key, this.size = 120, this.level = 4});

  final double size;
  final int level;

  @override
  State<PremiumEcoMascotCharacter> createState() =>
      _PremiumEcoMascotCharacterState();
}

class _PremiumEcoMascotCharacterState extends State<PremiumEcoMascotCharacter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _blink = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _scheduleBlink();
  }

  void _scheduleBlink() {
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      setState(() => _blink = true);
      Future.delayed(const Duration(milliseconds: 180), () {
        if (!mounted) return;
        setState(() => _blink = false);
        _scheduleBlink();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final floating = (t - 0.5).abs();
        final y = -6 + (floating * 12);
        final scale = 1 + ((0.5 - floating) * 0.04);
        return Transform.translate(
          offset: Offset(0, y),
          child: Transform.scale(
            scale: scale,
            child: SizedBox(
              width: s,
              height: s,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: s * 1.08,
                    height: s * 1.08,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFBDA8FF).withValues(alpha: .42),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: s,
                    height: s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C66FF), Color(0xFF4D35CC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4D35CC).withValues(alpha: .38),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: _MascotPainter(
                        mood: MascotMood.happy,
                        blinkAmount: _blink ? .95 : 0,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -6,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: s * .14,
                        vertical: s * .05,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4BE1F),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                      child: Text(
                        'مستوى ${widget.level}',
                        style: TextStyle(
                          fontSize: (s * .115).clamp(11.0, 15.0),
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MascotPainter extends CustomPainter {
  const _MascotPainter({required this.mood, this.blinkAmount = 0});
  final MascotMood mood;
  final double blinkAmount;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final faceR = size.width * .26;

    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFBFA9FF).withValues(alpha: .45),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * .48));
    canvas.drawCircle(center, size.width * .48, auraPaint);

    final hoodPaint = Paint()
      ..shader =
          const LinearGradient(
            colors: [Color(0xFF6D5AF8), Color(0xFF4C2FCF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(
            Rect.fromCenter(
              center: center,
              width: size.width * .72,
              height: size.width * .78,
            ),
          );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + size.height * .04),
          width: size.width * .72,
          height: size.width * .78,
        ),
        Radius.circular(size.width * .34),
      ),
      hoodPaint,
    );

    final facePaint = Paint()..color = const Color(0xFFFFD6A6);
    canvas.drawCircle(
      Offset(center.dx, center.dy - size.height * .01),
      faceR,
      facePaint,
    );

    final eyePaint = Paint()
      ..color = const Color(0xFF2C1250)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * .032;
    final blink = (1.0 - (blinkAmount * .9)).clamp(.05, 1.0);
    final eyeY = center.dy - size.height * .03;
    canvas.drawLine(
      Offset(center.dx - faceR * .42, eyeY),
      Offset(center.dx - faceR * .12, eyeY + (size.height * .015 * blink)),
      eyePaint,
    );
    canvas.drawLine(
      Offset(center.dx + faceR * .12, eyeY + (size.height * .015 * blink)),
      Offset(center.dx + faceR * .42, eyeY),
      eyePaint,
    );

    final smilePaint = Paint()
      ..color = const Color(0xFF2C1250)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .028
      ..strokeCap = StrokeCap.round;
    final smileRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + faceR * .26),
      width: faceR * 1.0,
      height: faceR * .78,
    );
    final smileSweep = mood == MascotMood.wrong ? .8 : 1.4;
    canvas.drawArc(smileRect, .3, smileSweep, false, smilePaint);

    final leafPaint = Paint()..color = const Color(0xFF22C55E);
    final leafPath = Path()
      ..moveTo(center.dx + size.width * .21, center.dy + size.height * .18)
      ..quadraticBezierTo(
        center.dx + size.width * .3,
        center.dy + size.height * .12,
        center.dx + size.width * .23,
        center.dy + size.height * .05,
      )
      ..quadraticBezierTo(
        center.dx + size.width * .17,
        center.dy + size.height * .12,
        center.dx + size.width * .21,
        center.dy + size.height * .18,
      );
    canvas.drawPath(leafPath, leafPaint);
  }

  @override
  bool shouldRepaint(covariant _MascotPainter oldDelegate) {
    return oldDelegate.mood != mood;
  }
}

// ─── Safe Lottie Asset ────────────────────────────────────────────────────

class SafeLottieAsset extends StatelessWidget {
  const SafeLottieAsset({
    super.key,
    required this.path,
    this.width = 120,
    this.height = 120,
    this.repeat = true,
  });
  final String path;
  final double width;
  final double height;
  final bool repeat;

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      path,
      width: width,
      height: height,
      repeat: repeat,
      errorBuilder: (ctx, err, trace) => SizedBox(width: width, height: height),
      frameBuilder: (ctx, child, composition) {
        if (composition == null) {
          return SizedBox(width: width, height: height);
        }
        return child;
      },
    );
  }
}

// ─── Bounce Mascot Button ─────────────────────────────────────────────────

class BounceMascotButton extends StatefulWidget {
  const BounceMascotButton({
    super.key,
    required this.label,
    required this.emoji,
    required this.onTap,
    this.color = const Color(0xFF7C3AED),
    this.width = double.infinity,
  });
  final String label;
  final String emoji;
  final VoidCallback onTap;
  final Color color;
  final double width;

  @override
  State<BounceMascotButton> createState() => _BounceMascotButtonState();
}

class _BounceMascotButtonState extends State<BounceMascotButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? .94 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutBack,
        child: Container(
          width: widget.width,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.color, widget.color.withValues(alpha: .8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _pressed ? .2 : .42),
                blurRadius: _pressed ? 8 : 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
