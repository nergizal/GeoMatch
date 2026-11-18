import 'package:flutter_test/flutter_test.dart';
import 'package:geo/features/game/domain/entities/country.dart';
import 'package:geo/features/game/domain/entities/game_config.dart';
import 'package:geo/features/game/domain/entities/game_enums.dart';
import 'package:geo/features/game/presentation/cubit/game_state.dart';
import 'package:geo/features/progress/data/repositories/local_storage_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalStorageRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repository = LocalStorageRepository(prefs);
  });

  group('LocalStorageRepository Tests', () {
    test('tamamlanan oyun istatistikleri biriktirmeli ve ilgili rozetleri açmalı', () async {
      const completed = GameCompleted(
        config: GameConfig(
          mode: GameMode.flagQuiz,
          difficulty: DifficultyLevel.easy,
          totalQuestions: 10,
        ),
        finalScore: 1150,
        totalQuestions: 10,
        correctCount: 10,
        wrongCount: 0,
        highestStreak: 10,
      );

      final outcome = await repository.recordCompletedGame(completed);

      expect(outcome.updatedStats.totalScore, 1150);
      expect(outcome.updatedStats.gamesPlayed, 1);
      expect(outcome.updatedStats.bestScore, 1150);
      expect(outcome.newlyUnlocked, containsAll(['first_game', 'streak_5', 'perfect_10']));
    });

    test('resetAllProgress tüm skor ve başarımları sıfırlamalı', () async {
      const completed = GameCompleted(
        config: GameConfig(
          mode: GameMode.capitalQuiz,
          difficulty: DifficultyLevel.medium,
        ),
        finalScore: 500,
        totalQuestions: 10,
        correctCount: 5,
        wrongCount: 5,
        highestStreak: 3,
      );

      await repository.recordCompletedGame(completed);
      await repository.resetAllProgress();

      final stats = repository.loadStats();
      expect(stats.totalScore, 0);
      expect(stats.gamesPlayed, 0);
      expect(stats.unlockedAchievementIds, isEmpty);
    });
  });
}
