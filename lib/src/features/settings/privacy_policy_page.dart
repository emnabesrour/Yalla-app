import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../shared/kids_widgets.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const CinematicGameBackground(),
          SafeArea(
            child: Column(
              children: [
                _TopBar(onBack: () => context.go(AppRoutes.settings)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: const GlassCard(
                      borderRadius: 20,
                      child: Text(
                        '''
نحن نحترم خصوصية الأطفال والأولياء.

1) البيانات التي نجمعها:
- اسم الطفل لعرضه داخل التطبيق.
- التقدم في المراحل والنجوم والشارات.

2) كيفية الاستخدام:
- تحسين تجربة اللعب وتتبع التقدم.
- لا نبيع البيانات لأي طرف ثالث.

3) الحماية:
- يتم حفظ البيانات محليا على جهازك.
- يمكنك مسح البيانات بإعادة تثبيت التطبيق.

4) تواصل:
- لأي استفسار حول الخصوصية، تواصل مع فريق الدعم.
                        ''',
                        style: TextStyle(
                          fontSize: 20,
                          height: 1.7,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ).animate().fadeIn(duration: 280.ms),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
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
            'سياسة الخصوصية',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          const Text('🔒', style: TextStyle(fontSize: 28)),
        ],
      ),
    ).animate().fadeIn(duration: 260.ms).slideY(begin: -.08, end: 0);
  }
}
