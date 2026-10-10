import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../data/services/guest_progress_session.dart';
import '../../data/services/providers.dart';
import '../settings/settings_controller.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key, this.showLoginInitially = false});
  final bool showLoginInitially;

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage>
    with SingleTickerProviderStateMixin {
  bool _showLogin = false;
  late AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _showLogin = widget.showLoginInitially;
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgCtrl,
        builder: (context2, notUsed) {
          final t = _bgCtrl.value;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [Color(0xFF4F46E5), Color(0xFF14B8A6)],
                begin: Alignment.lerp(
                  Alignment.topLeft,
                  Alignment.topCenter,
                  t,
                )!,
                end: Alignment.lerp(
                  Alignment.bottomRight,
                  Alignment.bottomLeft,
                  t,
                )!,
              ),
            ),
            child: _showLogin
                ? _LoginPanel(onBack: () => setState(() => _showLogin = false))
                : _WelcomePanel(
                    onGuest: () {
                      ref.read(guestProgressSessionProvider.notifier).clear();
                      ref
                          .read(settingsControllerProvider.notifier)
                          .setGuestMode(true);
                      context.go(AppRoutes.home);
                    },
                    onLogin: () => setState(() => _showLogin = true),
                    onRegister: () => context.go(AppRoutes.register),
                  ),
          );
        },
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({
    required this.onGuest,
    required this.onLogin,
    required this.onRegister,
  });
  final VoidCallback onGuest;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Floating bg emojis
        ..._buildParticles(w, h),

        SafeArea(
          child: Column(
            children: [
              SizedBox(height: h * .07),

              // Hero mascot
              Container(
                    width: 124,
                    height: 124,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: .15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .36),
                        width: 2.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .14),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: .2),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🧒', style: TextStyle(fontSize: 66)),
                    ),
                  )
                  .animate()
                  .scale(
                    begin: const Offset(.35, .35),
                    duration: 700.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 500.ms),

              SizedBox(height: h * .035),

              const Text(
                    'أهلاً وسهلاً!',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black38, blurRadius: 8)],
                    ),
                  )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 420.ms)
                  .slideY(begin: .14, end: 0),

              const SizedBox(height: 12),

              Text(
                    'انضم إلى مغامرة الطبيعة اليوم',
                    style: TextStyle(
                      fontSize: 19,
                      color: Colors.white.withValues(alpha: .96),
                      fontWeight: FontWeight.w500,
                      shadows: const [
                        Shadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                  )
                  .animate(delay: 320.ms)
                  .fadeIn(duration: 420.ms)
                  .slideY(begin: .12, end: 0),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    _AuthButton(
                          label: 'ابدأ كضيف',
                          icon: Icons.flash_on_rounded,
                          isPrimary: true,
                          textColor: const Color(0xFF204364),
                          onTap: onGuest,
                        )
                        .animate(delay: 420.ms)
                        .fadeIn(duration: 360.ms)
                        .slideY(begin: .16, end: 0),

                    const SizedBox(height: 12),

                    _AuthButton(
                          label: 'تسجيل الدخول',
                          icon: Icons.key_rounded,
                          isPrimary: false,
                          textColor: Colors.white,
                          onTap: onLogin,
                        )
                        .animate(delay: 520.ms)
                        .fadeIn(duration: 360.ms)
                        .slideY(begin: .16, end: 0),

                    const SizedBox(height: 12),

                    _AuthButton(
                          label: 'إنشاء حساب جديد',
                          icon: Icons.auto_awesome_rounded,
                          isPrimary: false,
                          textColor: Colors.white,
                          onTap: onRegister,
                        )
                        .animate(delay: 620.ms)
                        .fadeIn(duration: 360.ms)
                        .slideY(begin: .16, end: 0),

                    const SizedBox(height: 26),

                    Text(
                      '🔒 تطبيق آمن للأطفال',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .75),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: h * .06),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildParticles(double w, double h) {
    const items = [
      ('🍃', .08, .08, 28),
      ('✨', .82, .12, 20),
      ('🦋', .74, .32, 22),
      ('🫧', .1, .74, 30),
      ('🌿', .87, .66, 24),
    ];
    return items.indexed.map((rec) {
      final (i, item) = rec;
      return Positioned(
        left: item.$2 * w,
        top: item.$3 * h,
        child: IgnorePointer(
          child: Text(item.$1, style: TextStyle(fontSize: item.$4.toDouble()))
              .animate(
                delay: (i * 150).ms,
                onPlay: (c) => c.repeat(reverse: true),
              )
              .moveY(
                begin: 0,
                end: -10,
                duration: 2700.ms,
                curve: Curves.easeInOut,
              )
              .fade(begin: .16, end: .42),
        ),
      );
    }).toList();
  }
}

class _LoginPanel extends ConsumerStatefulWidget {
  const _LoginPanel({required this.onBack});
  final VoidCallback onBack;

  @override
  ConsumerState<_LoginPanel> createState() => _LoginPanelState();
}

class _LoginPanelState extends ConsumerState<_LoginPanel> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final success = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      if (!mounted) return;
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('بيانات الدخول غير صحيحة')),
        );
        return;
      }
      await ref
          .read(guestProgressSessionProvider.notifier)
          .flushToRepository(ref.read(gameRepositoryProvider));
      await ref.read(settingsControllerProvider.notifier).setGuestMode(false);
      if (!mounted) return;
      context.go(AppRoutes.home);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            GestureDetector(
              onTap: widget.onBack,
              child: const Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'رجوع',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'مرحباً مجدداً! 👋',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ).animate().fadeIn(duration: 350.ms),
            const SizedBox(height: 6),
            Text(
              'سجّل دخولك للمتابعة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: .8),
              ),
            ),
            const SizedBox(height: 36),
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  _GlassTextField(
                    controller: _emailController,
                    hint: 'البريد الإلكتروني',
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) {
                        return 'الرجاء إدخال البريد الإلكتروني';
                      }
                      if (!_emailRegex.hasMatch(text)) {
                        return 'صيغة البريد الإلكتروني غير صحيحة';
                      }
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _GlassTextField(
                    controller: _passwordController,
                    hint: 'كلمة المرور',
                    icon: Icons.lock_outline,
                    obscure: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _login(),
                    validator: (value) {
                      final text = value ?? '';
                      if (text.isEmpty) {
                        return 'الرجاء إدخال كلمة المرور';
                      }
                      if (text.length < 6) {
                        return 'كلمة المرور قصيرة جداً';
                      }
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'نسيت كلمة المرور؟',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .75),
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 28),
            _AuthButton(
              label: 'تسجيل الدخول',
              icon: Icons.login_rounded,
              isPrimary: true,
              textColor: const Color(0xFF204364),
              onTap: _isLoading ? () {} : () => _login(),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 12),
              const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  const _GlassTextField({
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
  });
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: .35)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onFieldSubmitted: onSubmitted,
        validator: validator,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: .6)),
          prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: .7)),
          errorStyle: const TextStyle(color: Color(0xFFFFEFEF)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}

class _AuthButton extends StatefulWidget {
  const _AuthButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.textColor,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool isPrimary;
  final Color textColor;
  final VoidCallback onTap;

  @override
  State<_AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<_AuthButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? .96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutBack,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.isPrimary
                    ? Colors.black.withValues(alpha: .2)
                    : Colors.black.withValues(alpha: .12),
                blurRadius: widget.isPrimary ? 18 : 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                decoration: BoxDecoration(
                  gradient: widget.isPrimary
                      ? LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: .94),
                            Colors.white.withValues(alpha: .82),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: .24),
                            Colors.white.withValues(alpha: .14),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: widget.isPrimary ? .8 : .45,
                    ),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.icon, color: widget.textColor, size: 23),
                      const SizedBox(width: 8),
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: widget.textColor,
                          shadows: widget.isPrimary
                              ? null
                              : [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: .22),
                                    blurRadius: 4,
                                  ),
                                ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
