import 'package:equatable/equatable.dart';

/// Puanlama kurallarını merkezi ve kolay değiştirilebilir tutan yapı.
class ScoringRules extends Equatable {
  final int baseCorrectPoints;
  final int wrongAnswerPoints;
  final int streak3Bonus;
  final int streak5Bonus;
  final int pointsPerRemainingSecond;

  const ScoringRules({
    this.baseCorrectPoints = 100,
    this.wrongAnswerPoints = 0,
    this.streak3Bonus = 50,
    this.streak5Bonus = 100,
    this.pointsPerRemainingSecond = 5,
  });

  @override
  List<Object?> get props => [
        baseCorrectPoints,
        wrongAnswerPoints,
        streak3Bonus,
        streak5Bonus,
        pointsPerRemainingSecond,
      ];
}

/// Tek bir sorunun cevaplanması sonucunda oluşan puan dökümü.
class AnswerScoreResult extends Equatable {
  final int basePoints;
  final int streakBonus;
  final int timeBonus;
  final int newStreak;

  const AnswerScoreResult({
    required this.basePoints,
    required this.streakBonus,
    required this.timeBonus,
    required this.newStreak,
  });

  int get totalEarned => basePoints + streakBonus + timeBonus;

  @override
  List<Object?> get props => [basePoints, streakBonus, timeBonus, newStreak];
}

/// Puan, seri (streak) ve süre bonusu hesaplamalarından sorumlu Domain servisi.
class ScoreCalculator {
  final ScoringRules rules;

  const ScoreCalculator({this.rules = const ScoringRules()});

  AnswerScoreResult calculate({
    required bool isCorrect,
    required int currentStreak,
    int? remainingSeconds,
  }) {
    if (!isCorrect) {
      return AnswerScoreResult(
        basePoints: rules.wrongAnswerPoints,
        streakBonus: 0,
        timeBonus: 0,
        newStreak: 0,
      );
    }

    final updatedStreak = currentStreak + 1;

    int streakBonus = 0;
    if (updatedStreak >= 5 && updatedStreak % 5 == 0) {
      streakBonus = rules.streak5Bonus;
    } else if (updatedStreak == 3) {
      streakBonus = rules.streak3Bonus;
    }

    final int timeBonus;
    if (remainingSeconds != null && remainingSeconds > 0) {
      timeBonus = remainingSeconds * rules.pointsPerRemainingSecond;
    } else {
      timeBonus = 0;
    }

    return AnswerScoreResult(
      basePoints: rules.baseCorrectPoints,
      streakBonus: streakBonus,
      timeBonus: timeBonus,
      newStreak: updatedStreak,
    );
  }
}