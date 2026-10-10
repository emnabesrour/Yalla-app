import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;
    if (!mounted) return;
    context.go(seen ? AppRoutes.auth : AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context2, notUsed) {
          final t = _bgController.value;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.lerp(
                    const Color(0xFF0A7A3A),
                    const Color(0xFF1B5E20),
                    t,
                  )!,
                  Color.lerp(
                    const Color(0xFF1DB954),
                    const Color(0xFF2E7D32),
                    t,
                  )!,
                  Color.lerp(
                    const Color(0xFF0EA5E9),
                    const Color(0xFF0369A1),
                    t,
                  )!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: _SplashContent(),
          );
        },
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Soft blurred circles for depth
        const _AmbientOrb(
          x: .06,
          y: .12,
          size: 170,
          color: Color(0xFF86EFAC),
          delay: 0,
        ),
        const _AmbientOrb(
          x: .72,
          y: .22,
          size: 210,
          color: Color(0xFF7DD3FC),
          delay: 500,
        ),
        const _AmbientOrb(
          x: .28,
          y: .72,
          size: 180,
          color: Color(0xFFA78BFA),
          delay: 300,
        ),

        // Floating nature particles
        const _FloatingNatureIcon(
          icon: '☁️',
          x: .08,
          y: .08,
          size: 32,
          delay: 0,
          movement: _IconMovement.driftX,
        ),
        const _FloatingNatureIcon(
          icon: '🌸',
          x: .82,
          y: .05,
          size: 30,
          delay: 400,
          movement: _IconMovement.floatY,
        ),
        const _FloatingNatureIcon(
          icon: '🦋',
          x: .73,
          y: .2,
          size: 26,
          delay: 800,
          movement: _IconMovement.flutter,
        ),
        const _FloatingNatureIcon(
          icon: '🍃',
          x: .12,
          y: .35,
          size: 25,
          delay: 600,
          movement: _IconMovement.floatY,
        ),
        const _FloatingNatureIcon(
          icon: '🐦',
          x: .6,
          y: .32,
          size: 23,
          delay: 200,
          movement: _IconMovement.driftX,
        ),
        const _FloatingNatureIcon(
          icon: '🌊',
          x: .04,
          y: .72,
          size: 34,
          delay: 900,
          movement: _IconMovement.floatY,
        ),
        const _FloatingNatureIcon(
          icon: '☀️',
          x: .78,
          y: .72,
          size: 31,
          delay: 300,
          movement: _IconMovement.floatY,
        ),
        const _FloatingNatureIcon(
          icon: '🫧',
          x: .88,
          y: .44,
          size: 26,
          delay: 700,
          movement: _IconMovement.floatY,
        ),
        const _FloatingNatureIcon(
          icon: '✨',
          x: .45,
          y: .15,
          size: 20,
          delay: 100,
          movement: _IconMovement.shimmer,
        ),
        const _FloatingNatureIcon(
          icon: '🌱',
          x: .35,
          y: .82,
          size: 24,
          delay: 500,
          movement: _IconMovement.floatY,
        ),

        // Main content
        SafeArea(
          child: Column(
            children: [
              SizedBox(height: h * .09),

              const _EarthHeroOrb()
                  .animate()
                  .scale(
                    begin: const Offset(.35, .35),
                    duration: 900.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 700.ms),

              SizedBox(height: h * .035),

              ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .32),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .16),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'يلّا! 🌿',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 58,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1,
                                shadows: [
                                  Shadow(color: Colors.black26, blurRadius: 8),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'مغامرة الطبيعة',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 29,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: .5,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'اكتشف عالم الطبيعة وحافظ على كوكبنا',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: .84),
                                fontWeight: FontWeight.w500,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .animate(delay: 260.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: .14, end: 0),

              const Spacer(),

              _EcoLoadingIndicator()
                  .animate(delay: 1000.ms)
                  .fadeIn(duration: 400.ms),

              SizedBox(height: h * .07),
            ],
          ),
        ),
      ],
    );
  }
}

enum _IconMovement { floatY, driftX, flutter, shimmer }

class _FloatingNatureIcon extends StatelessWidget {
  const _FloatingNatureIcon({
    required this.icon,
    required this.x,
    required this.y,
    required this.size,
    required this.delay,
    required this.movement,
  });
  final String icon;
  final double x;
  final double y;
  final double size;
  final int delay;
  final _IconMovement movement;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final text = Text(icon, style: TextStyle(fontSize: size));
    final animation = switch (movement) {
      _IconMovement.floatY =>
        text
            .animate(delay: delay.ms, onPlay: (c) => c.repeat(reverse: true))
            .moveY(
              begin: 0,
              end: -12,
              duration: 2600.ms,
              curve: Curves.easeInOut,
            )
            .fade(begin: .35, end: .78),
      _IconMovement.driftX =>
        text
            .animate(delay: delay.ms, onPlay: (c) => c.repeat(reverse: true))
            .moveX(
              begin: -7,
              end: 9,
              duration: 3600.ms,
              curve: Curves.easeInOut,
            )
            .fade(begin: .38, end: .78),
      _IconMovement.flutter =>
        text
            .animate(delay: delay.ms, onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: 0, end: -8, duration: 2000.ms)
            .moveX(begin: -4, end: 5, duration: 2000.ms)
            .fade(begin: .35, end: .85),
      _IconMovement.shimmer =>
        text
            .animate(delay: delay.ms, onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(.7, .7),
              end: const Offset(1.1, 1.1),
              duration: 1800.ms,
            )
            .fade(begin: .28, end: .8),
    };
    return Positioned(
      left: x * w,
      top: y * h,
      child: IgnorePointer(child: animation),
    );
  }
}

class _AmbientOrb extends StatelessWidget {
  const _AmbientOrb({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.delay,
  });

  final double x;
  final double y;
  final double size;
  final Color color;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Positioned(
      left: x * w,
      top: y * h,
      child:
          Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: .16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: .28),
                      blurRadius: 60,
                      spreadRadius: 6,
                    ),
                  ],
                ),
              )
              .animate(delay: delay.ms, onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(.9, .9),
                end: const Offset(1.08, 1.08),
                duration: 3600.ms,
              )
              .fade(begin: .28, end: .6),
    );
  }
}

class _EarthHeroOrb extends StatefulWidget {
  const _EarthHeroOrb();

  @override
  State<_EarthHeroOrb> createState() => _EarthHeroOrbState();
}

class _EarthHeroOrbState extends State<_EarthHeroOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final pulse = .92 + (sin(_controller.value * pi * 2) * .05);
        return Transform.scale(
          scale: pulse,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0x99FFFFFF), Color(0x22FFFFFF)],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: .55),
                width: 2.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7DD3FC).withValues(alpha: .42),
                  blurRadius: 34,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: .14),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Center(
              child: Transform.rotate(
                angle: _controller.value * pi * 2,
                child: const Text('🌍', style: TextStyle(fontSize: 82)),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EcoLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const Text('🍃', style: TextStyle(fontSize: 14)),
                ],
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .rotate(begin: -.06, end: .06, duration: 1400.ms),
          const SizedBox(width: 10),
          Text(
            'جاري تجهيز المغامرة...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .9),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
