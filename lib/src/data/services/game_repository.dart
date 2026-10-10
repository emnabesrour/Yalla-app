import '../database/app_database.dart';
import '../models/models.dart';

class GameRepository {
  Future<ChildProfile> getProfile() async {
    final db = await AppDatabase.instance.db;
    final rows = await db.query('profile', where: 'id = ?', whereArgs: [1]);
    final row = rows.first;
    return ChildProfile(
      name: row['child_name'] as String,
      totalStars: row['total_stars'] as int,
      badges: row['badges'] as int,
    );
  }

  Future<void> updateName(String name) async {
    final db = await AppDatabase.instance.db;
    await db.update('profile', {'child_name': name}, where: 'id = 1');
  }

  Future<List<LevelModel>> getLevelsByWorld(String worldId) async {
    final db = await AppDatabase.instance.db;
    final rows = await db.query(
      'levels',
      where: 'world_id = ?',
      whereArgs: [worldId],
      orderBy: 'id ASC',
    );
    return rows
        .map(
          (row) => LevelModel(
            id: row['id'] as int,
            worldId: row['world_id'] as String,
            title: row['title'] as String,
            stars: row['stars'] as int,
            isUnlocked: (row['unlocked'] as int) == 1,
            bestScore: row['best_score'] as int,
          ),
        )
        .toList();
  }

  Future<void> saveLevelResult({
    required int levelId,
    required int score,
    required int stars,
  }) async {
    final db = await AppDatabase.instance.db;

    final levelRows = await db.query(
      'levels',
      where: 'id = ?',
      whereArgs: [levelId],
      limit: 1,
    );
    if (levelRows.isEmpty) return;

    final current = levelRows.first;
    final currentStars = current['stars'] as int;
    final currentBest = current['best_score'] as int;
    final finalStars = stars > currentStars ? stars : currentStars;
    final finalBest = score > currentBest ? score : currentBest;

    await db.update(
      'levels',
      {'stars': finalStars, 'best_score': finalBest},
      where: 'id = ?',
      whereArgs: [levelId],
    );

    await db.update(
      'levels',
      {'unlocked': 1},
      where: 'id = ?',
      whereArgs: [levelId + 1],
    );

    final profile = await getProfile();
    await db.update(
      'profile',
      {
        'total_stars': profile.totalStars + (finalStars - currentStars),
        'badges': ((profile.totalStars + (finalStars - currentStars)) / 10)
            .floor(),
      },
      where: 'id = 1',
    );
  }

  Future<List<WorldProgress>> getWorldProgress() async {
    final db = await AppDatabase.instance.db;
    final worlds = ['colors', 'animals', 'numbers', 'memory'];
    final output = <WorldProgress>[];

    for (final world in worlds) {
      final rows = await db.query(
        'levels',
        where: 'world_id = ?',
        whereArgs: [world],
      );
      final total = rows.length;
      final completed = rows.where((e) => (e['stars'] as int) > 0).length;
      final stars = rows.fold<int>(0, (sum, e) => sum + (e['stars'] as int));
      output.add(
        WorldProgress(
          worldId: world,
          completedLevels: completed,
          totalLevels: total,
          stars: stars,
        ),
      );
    }
    return output;
  }
}
