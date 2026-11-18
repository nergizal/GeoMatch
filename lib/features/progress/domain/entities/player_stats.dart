import 'package:equatable/equatable.dart';

class PlayerStats extends Equatable {
  final int totalScore;
  final int gamesPlayed;
  final int correctAnswers;
  final int wrongAnswers;
  final int bestScore;
  final int highestStreak;
  final List<String> unlockedAchievementIds;
  final List<String> mistakeCountryCodes;

  const PlayerStats({
    this.totalScore = 0,
    this.gamesPlayed = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.bestScore = 0,
    this.highestStreak = 0,
    this.unlockedAchievementIds = const [],
    this.mistakeCountryCodes = const [],
  });

  int get totalAnswered => correctAnswers + wrongAnswers;

  double get accuracyPercentage =>
      totalAnswered == 0 ? 0 : (correctAnswers / totalAnswered) * 100;

  @override
  List<Object?> get props => [
        totalScore,
        gamesPlayed,
        correctAnswers,
        wrongAnswers,
        bestScore,
        highestStreak,
        unlockedAchievementIds,
        mistakeCountryCodes,
      ];
}
