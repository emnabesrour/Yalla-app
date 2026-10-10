import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/sounds/sound_service.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/settings_controller.dart';
import 'router/app_router.dart';

class KidsEcoApp extends ConsumerWidget {
  const KidsEcoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final router = ref.watch(appRouterProvider);
    ref.listen<SettingsState>(settingsControllerProvider, (previous, next) {
      SoundService.instance.setSoundEnabled(next.soundOn);
      SoundService.instance.setMusicEnabled(next.musicOn);
    });
    SoundService.instance.setSoundEnabled(settings.soundOn);
    SoundService.instance.setMusicEnabled(settings.musicOn);

    return MaterialApp.router(
      title: 'أصدقاء البيئة',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('fr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      themeMode: settings.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      builder: (context, child) {
        return Listener(
          onPointerDown: (_) {
            unawaited(SoundService.instance.registerUserInteraction());
          },
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
