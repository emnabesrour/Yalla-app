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

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  final _nameRegex = RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$');
  final _passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{6,}$');
  late AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final success = await ref
          .read(authRepositoryProvider)
          .register(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          );
      if (!mounted) return;
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('هذا البريد الإلكتروني مستخدم بالفعل')),
        );
        return;
      }
      await ref
          .read(guestProgressSessionProvider.notifier)
          .flushToRepository(ref.read(gameRepositoryProvider));
      await ref.read(settingsControllerProvider.notifier).setGuestMode(false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء الحساب، سجل دخولك الآن')),
      );
      context.go(AppRoutes.authLogin);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _bgCtrl,
          builder: (context, _) {
            final t = _bgCtrl.value;
            final h = MediaQuery.of(context).size.height;
            final w = MediaQuery.of(context).size.width;

            return DecoratedBox(
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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ..._buildParticles(w, h),
                  SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(AppRoutes.auth);
                              }
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ).animate().fadeIn(duration: 300.ms),
                        const SizedBox(height: 8),
                        Text(
                              'إنشاء حساب جديد',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: [
                                  Shadow(color: Colors.black38, blurRadius: 8),
                                ],
                              ),
                            )
                            .animate(delay: 100.ms)
                            .fadeIn(duration: 340.ms)
                            .slideY(begin: .12, end: 0),
                        const SizedBox(height: 8),
                        Text(
                              'مرحباً بك! أدخل بياناتك لإنشاء حسابك',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white.withValues(alpha: .95),
                                fontWeight: FontWeight.w600,
                              ),
                            )
                            .animate(delay: 180.ms)
                            .fadeIn(duration: 340.ms)
                            .slideY(begin: .1, end: 0),
                        const SizedBox(height: 22),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .18),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: .34),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: .16),
                                    blurRadius: 22,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                child: Column(
                                  children: [
                                    _GlassTextField(
                                      controller: _nameController,
                                      hint: 'الاسم',
                                      icon: Icons.person_outline_rounded,
                                      textInputAction: TextInputAction.next,
                                      validator: (value) {
                                        final text = value?.trim() ?? '';
                                        if (text.isEmpty) {
                                          return 'الرجاء إدخال الاسم';
                                        }
                                        if (text.length < 3) {
                                          return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                                        }
                                        if (!_nameRegex.hasMatch(text)) {
                                          return 'الاسم يجب أن يحتوي على حروف فقط';
                                        }
                                        return null;
                                      },
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(30),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    _GlassTextField(
                                      controller: _emailController,
                                      hint: 'البريد الإلكتروني',
                                      icon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      validator: (value) {
                                        final text = value?.trim() ?? '';
                                        if (text.isEmpty) {
                                          return 'الرجاء إدخال البريد الإلكتروني';
                                        }
                                        if (!_emailRegex.hasMatch(text)) {
                                          return 'البريد الإلكتروني غير صالح';
                                        }
                                        return null;
                                      },
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                          RegExp(r'\s'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    _GlassTextField(
                                      controller: _passwordController,
                                      hint: 'كلمة المرور',
                                      icon: Icons.lock_outline_rounded,
                                      obscureText: _obscurePassword,
                                      textInputAction: TextInputAction.next,
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          );
                                        },
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: Colors.white.withValues(
                                            alpha: .78,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        final text = value ?? '';
                                        if (text.isEmpty) {
                                          return 'الرجاء إدخال كلمة المرور';
                                        }
                                        if (!_passwordRegex.hasMatch(text)) {
                                          return 'كلمة المرور: 6+ أحرف مع حرف ورقم';
                                        }
                                        return null;
                                      },
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                          RegExp(r'\s'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    _GlassTextField(
                                      controller: _confirmPasswordController,
                                      hint: 'تأكيد كلمة المرور',
                                      icon: Icons.lock_reset_outlined,
                                      obscureText: _obscureConfirmPassword,
                                      textInputAction: TextInputAction.done,
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(
                                            () => _obscureConfirmPassword =
                                                !_obscureConfirmPassword,
                                          );
                                        },
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: Colors.white.withValues(
                                            alpha: .78,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        final text = value ?? '';
                                        if (text.isEmpty) {
                                          return 'الرجاء إعادة إدخال كلمة المرور';
                                        }
                                        if (text != _passwordController.text) {
                                          return 'كلمتا المرور غير متطابقتين';
                                        }
                                        return null;
                                      },
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                          RegExp(r'\s'),
                                        ),
                                      ],
                                      onFieldSubmitted: (_) => _submit(),
                                    ),
                                    const SizedBox(height: 22),
                                    _RegisterButton(
                                      onTap: () => _submit(),
                                      isLoading: _isSubmitting,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ).animate(delay: 260.ms).fadeIn(duration: 360.ms),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildParticles(double w, double h) {
    const items = [
      ('✨', .09, .14, 18),
      ('🦋', .83, .2, 22),
      ('🍃', .12, .72, 24),
      ('🫧', .8, .76, 28),
      ('🌿', .5, .1, 22),
    ];
    return items.indexed.map((rec) {
      final (i, item) = rec;
      return Positioned(
        left: item.$2 * w,
        top: item.$3 * h,
        child: Text(item.$1, style: TextStyle(fontSize: item.$4.toDouble()))
            .animate(
              delay: (i * 120).ms,
              onPlay: (c) => c.repeat(reverse: true),
            )
            .moveY(begin: 0, end: -10, duration: 2600.ms)
            .fade(begin: .16, end: .42),
      );
    }).toList();
  }
}

class _GlassTextField extends StatelessWidget {
  const _GlassTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
    this.onFieldSubmitted,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?) validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final void Function(String)? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .17),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: .35)),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onFieldSubmitted: onFieldSubmitted,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.white, fontSize: 18),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: .72)),
          prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: .82)),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          errorStyle: const TextStyle(color: Color(0xFFFFECEC)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}

class _RegisterButton extends StatefulWidget {
  const _RegisterButton({required this.onTap, required this.isLoading});
  final VoidCallback onTap;
  final bool isLoading;

  @override
  State<_RegisterButton> createState() => _RegisterButtonState();
}

class _RegisterButtonState extends State<_RegisterButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.isLoading ? null : widget.onTap,
      child: AnimatedScale(
        scale: _pressed && !widget.isLoading ? .97 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .2),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: .95),
                      Colors.white.withValues(alpha: .83),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .86),
                  ),
                ),
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Color(0xFF204364),
                          ),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Color(0xFF204364),
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'تسجيل',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF204364),
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
