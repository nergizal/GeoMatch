import 'package:equatable/equatable.dart';
import '../../domain/entities/game_config.dart';
import '../../domain/entities/question.dart';
import '../../domain/services/score_calculator.dart';

sealed class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

final class GameInitial extends GameState {
  const GameInitial();
}

final class GameLoading extends GameState {
  const GameLoading();
}

final class GamePlaying extends GameState {
  final GameConfig config;
  final List<Question> questions;
  final int currentIndex;
  final int score;
  final int streak;
  final int highestStreak;
  final int correctCount;
  final int wrongCount;
  final List<String> correctCountryCodes;
  final List<String> wrongCountryCodes;
  final int? remainingSeconds;

  const GamePlaying({
    required this.config,
    required this.questions,
    required this.currentIndex,
    required this.score,
    required this.streak,
    required this.highestStreak,
    required this.correctCount,
    required this.wrongCount,
    this.correctCountryCodes = const [],
    this.wrongCountryCodes = const [],
    this.remainingSeconds,
  });

  Question get currentQuestion => questions[currentIndex];
  int get totalQuestions => questions.length;
  double get progress => (currentIndex + 1) / totalQuestions;

  GamePlaying copyWith({
    int? remainingSeconds,
  }) {
    return GamePlaying(
      config: config,
      questions: questions,
      currentIndex: currentIndex,
      score: score,
      streak: streak,
      highestStreak: highestStreak,
      correctCount: correctCount,
      wrongCount: wrongCount,
      correctCountryCodes: correctCountryCodes,
      wrongCountryCodes: wrongCountryCodes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }

  @override
  List<Object?> get props => [
        config,
        questions,
        currentIndex,
        score,
        streak,
        highestStreak,
        correctCount,
        wrongCount,
        correctCountryCodes,
        wrongCountryCodes,
        remainingSeconds,
      ];
}

final class GameAnswered extends GameState {
  final GameConfig config;
  final List<Question> questions;
  final int currentIndex;
  final int? selectedOptionIndex;
  final bool isCorrect;
  final bool isTimeout;
  final AnswerScoreResult scoreResult;
  final int totalScore;
  final int streak;
  final int highestStreak;
  final int correctCount;
  final int wrongCount;
  final List<String> correctCountryCodes;
  final List<String> wrongCountryCodes;

  const GameAnswered({
    required this.config,
    required this.questions,
    required this.currentIndex,
    required this.selectedOptionIndex,
    required this.isCorrect,
    required this.isTimeout,
    required this.scoreResult,
    required this.totalScore,
    required this.streak,
    required this.highestStreak,
    required this.correctCount,
    required this.wrongCount,
    this.correctCountryCodes = const [],
    this.wrongCountryCodes = const [],
  });

  Question get currentQuestion => questions[currentIndex];
  int get totalQuestions => questions.length;
  bool get isLastQuestion => currentIndex >= totalQuestions - 1;

  @override
  List<Object?> get props => [
        config,
        questions,
        currentIndex,
        selectedOptionIndex,
        isCorrect,
        isTimeout,
        scoreResult,
        totalScore,
        streak,
        highestStreak,
        correctCount,
        wrongCount,
        correctCountryCodes,
        wrongCountryCodes,
      ];
}

final class GameCompleted extends GameState {
  final GameConfig config;
  final int finalScore;
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final int highestStreak;
  final List<String> correctCountryCodes;
  final List<String> wrongCountryCodes;

  const GameCompleted({
    required this.config,
    required this.finalScore,
    required this.totalQuestions,
    required this.correctCount,
    required this.wrongCount,
    required this.highestStreak,
    this.correctCountryCodes = const [],
    this.wrongCountryCodes = const [],
  });

  double get accuracyPercentage =>
      totalQuestions == 0 ? 0 : (correctCount / totalQuestions) * 100;

  @override
  List<Object?> get props => [
        config,
        finalScore,
        totalQuestions,
        correctCount,
        wrongCount,
        highestStreak,
        correctCountryCodes,
        wrongCountryCodes,
      ];
}

final class GameError extends GameState {
  final String message;

  const GameError(this.message);

  @override
  List<Object?> get props => [message];
}
