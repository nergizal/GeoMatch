import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../game/domain/entities/country.dart';
import '../../../game/presentation/cubit/game_state.dart';
import '../../domain/entities/player_stats.dart';

class LocalStorageRepository {
  final SharedPreferences _prefs;

  LocalStorageRepository(this._prefs);

  static const _kTotalScore = 'stats_total_score';
  static const _kGamesPlayed = 'stats_games_played';
  static const _kCorrectAnswers = 'stats_correct_answers';
  static const _kWrongAnswers = 'stats_wrong_answers';
  static const _kBestScore = 'stats_best_score';
  static const _kHighestStreak = 'stats_highest_streak';
  static const _kAchievements = 'unlocked_achievements';
  static const _kMistakes = 'mistake_country_codes';

  static const _kIsDarkMode = 'settings_is_dark_mode';
  static const _kLanguageCode = 'settings_language_code';
  static const _kSoundEnabled = 'settings_sound_enabled';
  static const _kOnboardingDone = 'onboarding_completed';

  PlayerStats loadStats() {
    return PlayerStats(
      totalScore: _prefs.getInt(_kTotalScore) ?? 0,
      gamesPlayed: _prefs.getInt(_kGamesPlayed) ?? 0,
      correctAnswers: _prefs.getInt(_kCorrectAnswers) ?? 0,
      wrongAnswers: _prefs.getInt(_kWrongAnswers) ?? 0,
      bestScore: _prefs.getInt(_kBestScore) ?? 0,
      highestStreak: _prefs.getInt(_kHighestStreak) ?? 0,
      unlockedAchievementIds: _prefs.getStringList(_kAchievements) ?? const [],
      mistakeCountryCodes: _prefs.getStringList(_kMistakes) ?? const [],
    );
  }

  Future<({PlayerStats updatedStats, List<String> newlyUnlocked})>
      recordCompletedGame(GameCompleted result) async {
    final current = loadStats();

    final newTotalScore = current.totalScore + result.finalScore;
    final newGamesPlayed = current.gamesPlayed + 1;
    final newCorrect = current.correctAnswers + result.correctCount;
    final newWrong = current.wrongAnswers + result.wrongCount;
    final newBestScore = max(current.bestScore, result.finalScore);
    final newHighestStreak = max(current.highestStreak, result.highestStreak);

    // Hata Defteri güncellemesi:
    // Yanlış yapılanları ekle; eğer tekrar modundaysak doğru bilinenleri çıkar!
    final mistakeSet = Set<String>.from(current.mistakeCountryCodes);
    mistakeSet.addAll(result.wrongCountryCodes);
    if (result.config.isMistakePractice) {
      mistakeSet.removeAll(result.correctCountryCodes);
    }

    final unlockedSet = Set<String>.from(current.unlockedAchievementIds);
    final newlyUnlocked = <String>[];

    void unlockIf(String id, bool condition) {
      if (condition && !unlockedSet.contains(id)) {
        unlockedSet.add(id);
        newlyUnlocked.add(id);
      }
    }

    unlockIf('first_game', newGamesPlayed >= 1);
    unlockIf('streak_5', result.highestStreak >= 5);
    unlockIf(
      'perfect_10',
      result.totalQuestions >= 10 &&
          result.correctCount == result.totalQuestions,
    );
    unlockIf('scholar_50', newCorrect >= 50);
    unlockIf('master_2500', newTotalScore >= 2500);
    unlockIf(
      'expert_survivor',
      result.config.difficulty == DifficultyLevel.expert &&
          result.correctCount >= 7,
    );

    final updatedAchievements = unlockedSet.toList(growable: false);
    final updatedMistakes = mistakeSet.toList(growable: false);

    await Future.wait([
      _prefs.setInt(_kTotalScore, newTotalScore),
      _prefs.setInt(_kGamesPlayed, newGamesPlayed),
      _prefs.setInt(_kCorrectAnswers, newCorrect),
      _prefs.setInt(_kWrongAnswers, newWrong),
      _prefs.setInt(_kBestScore, newBestScore),
      _prefs.setInt(_kHighestStreak, newHighestStreak),
      _prefs.setStringList(_kAchievements, updatedAchievements),
      _prefs.setStringList(_kMistakes, updatedMistakes),
    ]);

    final updatedStats = PlayerStats(
      totalScore: newTotalScore,
      gamesPlayed: newGamesPlayed,
      correctAnswers: newCorrect,
      wrongAnswers: newWrong,
      bestScore: newBestScore,
      highestStreak: newHighestStreak,
      unlockedAchievementIds: updatedAchievements,
      mistakeCountryCodes: updatedMistakes,
    );

    return (updatedStats: updatedStats, newlyUnlocked: newlyUnlocked);
  }

  Future<void> resetAllProgress() async {
    await Future.wait([
      _prefs.remove(_kTotalScore),
      _prefs.remove(_kGamesPlayed),
      _prefs.remove(_kCorrectAnswers),
      _prefs.remove(_kWrongAnswers),
      _prefs.remove(_kBestScore),
      _prefs.remove(_kHighestStreak),
      _prefs.remove(_kAchievements),
      _prefs.remove(_kMistakes),
    ]);
  }

  bool get isDarkMode => _prefs.getBool(_kIsDarkMode) ?? false;
  Future<void> setDarkMode(bool value) => _prefs.setBool(_kIsDarkMode, value);

  String get languageCode => _prefs.getString(_kLanguageCode) ?? 'tr';
  Future<void> setLanguageCode(String code) =>
      _prefs.setString(_kLanguageCode, code);

  bool get soundEnabled => _prefs.getBool(_kSoundEnabled) ?? true;
  Future<void> setSoundEnabled(bool value) =>
      _prefs.setBool(_kSoundEnabled, value);

  bool get isOnboardingCompleted => _prefs.getBool(_kOnboardingDone) ?? false;
  Future<void> setOnboardingCompleted(bool value) =>
      _prefs.setBool(_kOnboardingDone, value);
}
