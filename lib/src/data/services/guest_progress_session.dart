import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game_repository.dart';

class GuestLevelResult {
  const GuestLevelResult({
    required this.levelId,
    required this.score,
    required this.stars,
  });

  final int levelId;
  final int score;
  final int stars;

  GuestLevelResult copyWith({
    int? levelId,
    int? score,
    int? stars,
  }) {
    return GuestLevelResult(
      levelId: levelId ?? this.levelId,
      score: score ?? this.score,
      stars: stars ?? this.stars,
    );
  }
}

class GuestProgressSessionController extends StateNotifier<List<GuestLevelResult>> {
  GuestProgressSessionController() : super(const []);

  void recordResult({
    required int levelId,
    required int score,
    required int stars,
  }) {
    final existingIndex = state.indexWhere((item) => item.levelId == levelId);
    if (existingIndex == -1) {
      state = [...state, GuestLevelResult(levelId: levelId, score: score, stars: stars)];
      return;
    }

    final current = state[existingIndex];
    final updated = current.copyWith(
      score: score > current.score ? score : current.score,
      stars: stars > current.stars ? stars : current.stars,
    );
    final next = [...state];
    next[existingIndex] = updated;
    state = next;
  }

  Future<void> flushToRepository(GameRepository repository) async {
    final pending = [...state];
    if (pending.isEmpty) return;
    for (final result in pending) {
      await repository.saveLevelResult(
        levelId: result.levelId,
        score: result.score,
        stars: result.stars,
      );
    }
    state = const [];
  }

  void clear() {
    state = const [];
  }
}

final guestProgressSessionProvider = StateNotifierProvider<
  GuestProgressSessionController,
  List<GuestLevelResult>
>((ref) {
  return GuestProgressSessionController();
});
