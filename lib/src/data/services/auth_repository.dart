import '../database/app_database.dart';
import 'game_repository.dart';

class AuthRepository {
  AuthRepository({GameRepository? gameRepository})
    : _gameRepository = gameRepository ?? GameRepository();

  final GameRepository _gameRepository;

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await AppDatabase.instance.db;
    final normalizedEmail = email.trim().toLowerCase();

    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return false;
    }

    await db.insert('users', {
      'name': name.trim(),
      'email': normalizedEmail,
      'password': password,
      'created_at': DateTime.now().toIso8601String(),
    });

    await _gameRepository.updateName(name.trim());
    return true;
  }

  Future<bool> login({required String email, required String password}) async {
    final db = await AppDatabase.instance.db;
    final normalizedEmail = email.trim().toLowerCase();

    final rows = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [normalizedEmail, password],
      limit: 1,
    );
    if (rows.isEmpty) {
      return false;
    }

    final name = rows.first['name'] as String;
    await _gameRepository.updateName(name);
    return true;
  }
}
