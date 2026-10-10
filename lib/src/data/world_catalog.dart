import 'package:flutter/material.dart';

enum GameMode {
  quizClassic,
  quizSpeed,
  quizSurvival,
  dragDropCleanup,
  flameRunner,
  oceanRescueTap,
  arrowColors,
  spotDifference,
  frameChallenge,
}

class WorldBlueprint {
  const WorldBlueprint({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradientColors,
    required this.bgEmoji,
    required this.sceneWorldId,
    required this.questionWorldId,
    required this.mode,
    required this.modeLabel,
    this.isUnlocked = true,
    this.completedLevels = 0,
    this.totalLevels = 6,
    this.timerSeconds = 20,
    this.basePoints = 10,
    this.wrongPenalty = 0,
  });

  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> gradientColors;
  final List<String> bgEmoji;
  final String sceneWorldId;
  final String questionWorldId;
  final GameMode mode;
  final String modeLabel;
  final bool isUnlocked;
  final int completedLevels;
  final int totalLevels;
  final int timerSeconds;
  final int basePoints;
  final int wrongPenalty;
}

const worldCatalog = <WorldBlueprint>[
  WorldBlueprint(
    id: 'ocean_cleanup',
    title: 'عالم تنظيف المحيط',
    subtitle: 'اجمع النفايات وأنقذ الحياة البحرية',
    emoji: '🌊',
    gradientColors: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
    bgEmoji: ['🐠', '🐢', '💧', '🐬', '🪸'],
    sceneWorldId: 'ocean',
    questionWorldId: 'ocean',
    mode: GameMode.dragDropCleanup,
    modeLabel: 'تنظيف بالسحب والإفلات',
    isUnlocked: true,
    completedLevels: 3,
    timerSeconds: 25,
  ),
  WorldBlueprint(
    id: 'forest_rescue',
    title: 'عالم الغابة',
    subtitle: 'مغامرة أصدقاء البيئة في الغابة',
    emoji: '🌳',
    gradientColors: [Color(0xFF1DB954), Color(0xFF0A7A3A)],
    bgEmoji: ['🌸', '🦋', '🍃', '🌿', '🌲'],
    sceneWorldId: 'forest',
    questionWorldId: 'forest',
    mode: GameMode.quizClassic,
    modeLabel: 'اختبار المغامرة',
    isUnlocked: true,
    completedLevels: 5,
    timerSeconds: 20,
  ),
  WorldBlueprint(
    id: 'lava_flame_escape',
    title: 'عالم اللهب',
    subtitle: 'نجاة سريعة وسط الحمم والتحديات',
    emoji: '🔥',
    gradientColors: [Color(0xFFF97316), Color(0xFFB91C1C)],
    bgEmoji: ['🌋', '🔥', '💥', '🪨', '⚠️'],
    sceneWorldId: 'animals',
    questionWorldId: 'earth',
    mode: GameMode.flameRunner,
    modeLabel: 'عدّاء اللهب',
    isUnlocked: true,
    completedLevels: 2,
    timerSeconds: 15,
    basePoints: 12,
  ),
  WorldBlueprint(
    id: 'sky_city',
    title: 'مدينة السماء',
    subtitle: 'باركور كرتوني وسرعة عالية',
    emoji: '🌤️',
    gradientColors: [Color(0xFF22D3EE), Color(0xFF2563EB)],
    bgEmoji: ['☁️', '🛹', '✨', '🏙️', '🌈'],
    sceneWorldId: 'energy',
    questionWorldId: 'energy',
    mode: GameMode.quizSpeed,
    modeLabel: 'تحدي الباركور',
    completedLevels: 0,
    timerSeconds: 16,
    basePoints: 11,
  ),
  WorldBlueprint(
    id: 'wildlife_alba',
    title: 'محمية الحيوانات',
    subtitle: 'أنقذ الحيوانات ووازن الطبيعة',
    emoji: '🦊',
    gradientColors: [Color(0xFFF97316), Color(0xFFEA580C)],
    bgEmoji: ['🦁', '🐘', '🦒', '🐼', '🦜'],
    sceneWorldId: 'animals',
    questionWorldId: 'animals',
    mode: GameMode.quizClassic,
    modeLabel: 'مهام الإنقاذ',
    completedLevels: 1,
    timerSeconds: 22,
  ),
  WorldBlueprint(
    id: 'desert_temple',
    title: 'معبد الصحراء',
    subtitle: 'ألغاز وأبواب سرية وعواصف رملية',
    emoji: '🏜️',
    gradientColors: [Color(0xFFF59E0B), Color(0xFFB45309)],
    bgEmoji: ['🦂', '🏺', '🔱', '☀️', '🪙'],
    sceneWorldId: 'energy',
    questionWorldId: 'energy',
    mode: GameMode.quizSurvival,
    modeLabel: 'ألغاز البقاء',
    completedLevels: 0,
    timerSeconds: 24,
    wrongPenalty: 4,
  ),
  WorldBlueprint(
    id: 'cyber_arena',
    title: 'ساحة السايبر',
    subtitle: 'قتال ذكي وتحديات ليزر',
    emoji: '🤖',
    gradientColors: [Color(0xFF8B5CF6), Color(0xFF4C1D95)],
    bgEmoji: ['⚡', '🤖', '🛰️', '🔮', '🧠'],
    sceneWorldId: 'recycling',
    questionWorldId: 'earth',
    mode: GameMode.quizSpeed,
    modeLabel: 'ساحة الكومبو',
    completedLevels: 0,
    timerSeconds: 14,
    basePoints: 13,
  ),
  WorldBlueprint(
    id: 'ice_mountain',
    title: 'جبل الجليد',
    subtitle: 'تحكم دقيق في البرد والرياح',
    emoji: '❄️',
    gradientColors: [Color(0xFF06B6D4), Color(0xFF0E7490)],
    bgEmoji: ['❄️', '🧊', '🏔️', '🌨️', '✨'],
    sceneWorldId: 'earth',
    questionWorldId: 'earth',
    mode: GameMode.quizSurvival,
    modeLabel: 'بقاء الجليد',
    completedLevels: 0,
    timerSeconds: 23,
    wrongPenalty: 3,
  ),
];

WorldBlueprint worldById(String id) {
  return worldCatalog.firstWhere(
    (world) => world.id == id,
    orElse: () => worldCatalog[0],
  );
}
