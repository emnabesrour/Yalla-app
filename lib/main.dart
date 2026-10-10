import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/core/sounds/sound_service.dart';
import 'src/data/database/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.initialize();
  try {
    await SoundService.instance.onAppLaunch();
  } catch (_) {
    // Audio is optional; never block app startup.
  }
  runApp(const ProviderScope(child: KidsEcoApp()));
}
