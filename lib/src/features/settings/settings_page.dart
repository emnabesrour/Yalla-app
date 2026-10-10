import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../shared/kids_widgets.dart';
import 'settings_controller.dart';

Color _settingsSecondaryText(
  BuildContext context, {
  double darkAlpha = .58,
  double lightAlpha = .9,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Colors.white.withValues(alpha: isDark ? darkAlpha : lightAlpha);
}

Color _settingsSurface(
  BuildContext context, {
  double darkAlpha = .1,
  double lightAlpha = .26,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Colors.white.withValues(alpha: isDark ? darkAlpha : lightAlpha);
}

Color _settingsBorder(
  BuildContext context, {
  double darkAlpha = .18,
  double lightAlpha = .4,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Colors.white.withValues(alpha: isDark ? darkAlpha : lightAlpha);
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          const CinematicGameBackground(),

          SafeArea(
            child: Column(
              children: [
                _TopBar(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    children: [
                      _SectionHeader(title: '🎵 الصوت والموسيقى'),
                      const SizedBox(height: 10),
                      _SettingsCard(
                        children: [
                          _SettingToggle(
                            icon: '🔊',
                            title: 'أصوات اللعبة',
                            subtitle: 'أصوات النجاح والأخطاء',
                            value: settings.soundOn,
                            onChanged: (v) => ref.read(settingsControllerProvider.notifier).toggleSound(v),
                          ),
                          _SettingDivider(),
                          _SettingToggle(
                            icon: '🎵',
                            title: 'الموسيقى',
                            subtitle: 'موسيقى الخلفية الهادئة',
                            value: settings.musicOn,
                            onChanged: (v) => ref.read(settingsControllerProvider.notifier).toggleMusic(v),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),
                      _SectionHeader(title: '🎨 المظهر'),
                      const SizedBox(height: 10),
                      _SettingsCard(
                        children: [
                          _SettingToggle(
                            icon: '🌙',
                            title: 'الوضع الليلي',
                            subtitle: 'خلفية داكنة مريحة للعيون',
                            value: settings.themeMode == ThemeMode.dark,
                            onChanged: (v) => ref.read(settingsControllerProvider.notifier).toggleDarkMode(v),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),
                      _SectionHeader(title: '🔐 حماية الوالدين'),
                      const SizedBox(height: 10),
                      _SettingsCard(
                        children: [
                          _SettingItem(
                            icon: '📊',
                            title: 'لوحة تحكم الوالدين',
                            subtitle: 'تتبع تقدم طفلك',
                            onTap: () => context.go(AppRoutes.parentDashboard),
                          ),
                          _SettingDivider(),
                          _SettingItem(
                            icon: '🔑',
                            title: 'تغيير رمز PIN',
                            subtitle: 'حماية الإعدادات',
                            onTap: () => _showPinChangeNotImplemented(context),
                          ),
                          _SettingDivider(),
                          _SettingToggle(
                            icon: '👤',
                            title: 'وضع الضيف',
                            subtitle: 'الدخول بدون حساب',
                            value: settings.guestMode,
                            onChanged: (v) => ref.read(settingsControllerProvider.notifier).setGuestMode(v),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),
                      _SectionHeader(title: 'ℹ️ عن التطبيق'),
                      const SizedBox(height: 10),
                      _SettingsCard(
                        children: [
                          _SettingItem(
                            icon: '🌍',
                            title: 'يلّا! - مغامرة الطبيعة',
                            subtitle: 'الإصدار 1.0.0',
                            onTap: () => context.go(AppRoutes.appInfo),
                          ),
                          _SettingDivider(),
                          _SettingItem(
                            icon: '🔒',
                            title: 'سياسة الخصوصية',
                            subtitle: 'تطبيق آمن للأطفال',
                            onTap: () => context.go(AppRoutes.privacyPolicy),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),
                      _LogoutButton(),
                      const SizedBox(height: 34),
                    ],
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
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'الإعدادات',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const Spacer(),
          const Text('⚙️', style: TextStyle(fontSize: 28)),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: _settingsSecondaryText(context, darkAlpha: .62, lightAlpha: .94),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _settingsSurface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _settingsBorder(context)),
      ),
      child: Column(children: children),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _SettingDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: _settingsSecondaryText(context, darkAlpha: .16, lightAlpha: .33),
      indent: 16,
      endIndent: 16,
    );
  }
}

class _SettingToggle extends StatelessWidget {
  const _SettingToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final String icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: _settingsSecondaryText(context),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF1DB954),
          ),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                    color: _settingsSecondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: _settingsSecondaryText(context, darkAlpha: .4, lightAlpha: .72),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.auth),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: .18),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.red.withValues(alpha: .35)),
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
              SizedBox(width: 10),
              Text(
                'تسجيل الخروج',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 300.ms);
  }
}

void _showPinChangeNotImplemented(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('تغيير رمز PIN'),
      content: const Text('سيتم توفير هذه الميزة قريباً.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('حسنا'),
        ),
      ],
    ),
  );
}
