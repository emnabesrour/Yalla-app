import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_repository.dart';
import 'game_repository.dart';

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepository();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(gameRepository: ref.watch(gameRepositoryProvider));
});
