class ChildProfile {
  const ChildProfile({
    required this.name,
    required this.totalStars,
    required this.badges,
    this.xp = 0,
    this.level = 1,
  });

  final String name;
  final int totalStars;
  final int badges;
  final int xp;
  final int level;
}

class WorldModel {
  const WorldModel({
    required this.id,
    required this.title,
    required this.emoji,
    required this.color,
    this.isUnlocked = false,
    this.completedLevels = 0,
    this.totalLevels = 6,
  });

  final String id;
  final String title;
  final String emoji;
  final int color;
  final bool isUnlocked;
  final int completedLevels;
  final int totalLevels;

  static const all = [
    WorldModel(id: 'forest', title: 'عالم الغابة', emoji: '🌳', color: 0xFF1DB954, isUnlocked: true, totalLevels: 6),
    WorldModel(id: 'ocean', title: 'عالم المحيط', emoji: '🌊', color: 0xFF0EA5E9, isUnlocked: true, totalLevels: 6),
    WorldModel(id: 'animals', title: 'عالم الحيوانات', emoji: '🐼', color: 0xFFF97316, isUnlocked: true, totalLevels: 6),
    WorldModel(id: 'recycling', title: 'مدينة الرسكلة', emoji: '♻️', color: 0xFF8B5CF6, isUnlocked: false, totalLevels: 6),
    WorldModel(id: 'energy', title: 'عالم الطاقة', emoji: '☀️', color: 0xFFFACC15, isUnlocked: false, totalLevels: 6),
    WorldModel(id: 'earth', title: 'حارس الأرض', emoji: '🌍', color: 0xFF06B6D4, isUnlocked: false, totalLevels: 6),
  ];
}

class LevelModel {
  const LevelModel({
    required this.id,
    required this.worldId,
    required this.title,
    required this.stars,
    required this.isUnlocked,
    required this.bestScore,
  });

  final int id;
  final String worldId;
  final String title;
  final int stars;
  final bool isUnlocked;
  final int bestScore;
}

class WorldProgress {
  const WorldProgress({
    required this.worldId,
    required this.completedLevels,
    required this.totalLevels,
    required this.stars,
  });

  final String worldId;
  final int completedLevels;
  final int totalLevels;
  final int stars;
}
