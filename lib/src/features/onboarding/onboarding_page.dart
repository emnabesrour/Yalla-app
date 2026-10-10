import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_routes.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(
      emoji: '🌍',
      title: 'كوكبنا يحتاجك!',
      subtitle: 'تعلّم حماية الطبيعة\nوكن بطل البيئة',
      gradient: [Color(0xFF1DB954), Color(0xFF0A7A3A)],
    ),
    _Slide(
      emoji: '🎮',
      title: 'العب وتعلّم',
      subtitle: 'مغامرات ممتعة في 6 عوالم\nمليئة بالألعاب',
      gradient: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
    ),
    _Slide(
      emoji: '🏆',
      title: 'اجمع النجوم!',
      subtitle: 'اكسب نجومًا وشارات\nوافتح عوالم جديدة',
      gradient: [Color(0xFFF59E0B), Color(0xFFEF4444)],
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (mounted) context.go(AppRoutes.auth);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 60),
                  _PageIndicators(length: _slides.length, active: _page),
                  TextButton(
                    onPressed: _finish,
                    child: const Text(
                      'تخطى',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: GestureDetector(
              onTap: () {
                if (_page < _slides.length - 1) {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                  );
                } else {
                  _finish();
                }
              },
              child: Container(
                height: 62,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: .94),
                      Colors.white.withValues(alpha: .84),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .85),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _slides[_page].gradient[0].withValues(alpha: .3),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, .15),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: Text(
                          _page < _slides.length - 1
                              ? 'التالي ▶'
                              : 'ابدأ المغامرة! 🚀',
                          key: ValueKey(_page),
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: _slides[_page].gradient[0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: slide.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: w * .08,
            top: h * .16,
            child: _BlurCircle(
              size: 120,
              color: Colors.white.withValues(alpha: .12),
              delay: 0,
            ),
          ),
          Positioned(
            right: w * .05,
            top: h * .3,
            child: _BlurCircle(
              size: 150,
              color: Colors.white.withValues(alpha: .08),
              delay: 320,
            ),
          ),
          const _FloatingDecor(icon: '🍃', x: .1, y: .2, delay: 0),
          const _FloatingDecor(icon: '✨', x: .84, y: .26, delay: 220),
          const _FloatingDecor(icon: '🦋', x: .74, y: .52, delay: 420),
          const _FloatingDecor(icon: '🫧', x: .2, y: .64, delay: 650),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: h * .07),
              Container(
                    width: 136,
                    height: 136,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: .16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .36),
                        width: 2.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .12),
                          blurRadius: 22,
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: .2),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        slide.emoji,
                        style: const TextStyle(fontSize: 82),
                      ),
                    ),
                  )
                  .animate()
                  .scale(
                    begin: const Offset(.4, .4),
                    duration: 700.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 500.ms),
              SizedBox(height: h * .05),
              Text(
                    slide.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.15,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 6)],
                    ),
                  )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: .2, end: 0),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  slide.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white.withValues(alpha: .84),
                    fontWeight: FontWeight.w500,
                    height: 1.42,
                  ),
                ),
              ).animate(delay: 350.ms).fadeIn(duration: 400.ms),
              const Spacer(),
              SizedBox(height: h * .15),
            ],
          ),
        ],
      ),
    );
  }
}

class _Slide {
  const _Slide({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradient;
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({
    required this.size,
    required this.color,
    required this.delay,
  });

  final double size;
  final Color color;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        )
        .animate(delay: delay.ms, onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(.94, .94),
          end: const Offset(1.08, 1.08),
          duration: 3600.ms,
        )
        .fade(begin: .2, end: .42);
  }
}

class _FloatingDecor extends StatelessWidget {
  const _FloatingDecor({
    required this.icon,
    required this.x,
    required this.y,
    required this.delay,
  });

  final String icon;
  final double x;
  final double y;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Positioned(
      left: x * w,
      top: y * h,
      child:
          IgnorePointer(
                child: Text(
                  icon,
                  style: const TextStyle(
                    fontSize: 26,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                  ),
                ),
              )
              .animate(delay: delay.ms, onPlay: (c) => c.repeat(reverse: true))
              .moveY(
                begin: 0,
                end: -10,
                duration: 2300.ms,
                curve: Curves.easeInOut,
              )
              .fade(begin: .22, end: .58),
    );
  }
}

class _PageIndicators extends StatelessWidget {
  const _PageIndicators({required this.length, required this.active});
  final int length;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(length, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          width: isActive ? 30 : 9,
          height: 9,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isActive ? .95 : .34),
            borderRadius: BorderRadius.circular(99),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: .28),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
