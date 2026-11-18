import 'package:equatable/equatable.dart';
import 'package:geo/features/game/domain/entities/game_config.dart';
import 'package:geo/features/game/domain/entities/question.dart';
import 'package:geo/features/game/domain/services/score_calculator.dart';


/// Oyun akışının tüm olası durumlarını temsil eden mühürlü (sealed) sınıf hiyerarşisi.
sealed class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

/// 1. Başlangıç durumu (Henüz oyun başlatılmadı).
final class GameInitial extends GameState {
  const GameInitial();
}

/// 2. Ülke verileri okunuyor ve sorular üretiliyor.
final class GameLoading extends GameState {
  const GameLoading();
}

/// 3. Aktif soru ekranda, oyuncunun cevabı bekleniyor.
final class GamePlaying extends GameState {
  final GameConfig config;
  final List<Question> questions;
  final int currentIndex;
  final int score;
  final int streak;
  final int highestStreak;
  final int correctCount;
  final int wrongCount;
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
        remainingSeconds,
      ];
}

/// 4. Oyuncu cevabı seçti (veya süre doldu); şıklar kilitli ve geri bildirim gösteriliyor.
final class GameAnswered extends GameState {
  final GameConfig config;
  final List<Question> questions;
  final int currentIndex;
  final int? selectedOptionIndex; // Süre dolduysa null olur
  final bool isCorrect;
  final bool isTimeout;
  final AnswerScoreResult scoreResult;
  final int totalScore;
  final int streak;
  final int highestStreak;
  final int correctCount;
  final int wrongCount;

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
      ];
}

/// 5. Oturumdaki 10 soru tamamlandı; sonuç özeti hazır.
final class GameCompleted extends GameState {
  final GameConfig config;
  final int finalScore;
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final int highestStreak;

  const GameCompleted({
    required this.config,
    required this.finalScore,
    required this.totalQuestions,
    required this.correctCount,
    required this.wrongCount,
    required this.highestStreak,
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
      ];
}

/// 6. Veri yükleme veya oyun motoru hatası.
final class GameError extends GameState {
  final String message;

  const GameError(this.message);

  @override
  List<Object?> get props => [message];
}