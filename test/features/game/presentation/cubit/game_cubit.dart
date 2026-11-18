import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geo/features/game/domain/entities/game_config.dart';
import 'package:geo/features/game/domain/entities/question.dart';
import 'package:geo/features/game/domain/repositories/country_repository.dart';
import 'package:geo/features/game/domain/services/question_generator.dart';
import 'package:geo/features/game/domain/services/score_calculator.dart';

import 'game_state.dart';

/// Oyun oturumunun tüm mantığını ve durum geçişlerini yöneten Cubit.
class GameCubit extends Cubit<GameState> {
  final CountryRepository countryRepository;
  final QuestionGenerator questionGenerator;
  final ScoreCalculator scoreCalculator;

  Timer? _questionTimer;

  GameCubit({
    required this.countryRepository,
    required this.questionGenerator,
    required this.scoreCalculator,
  }) : super(const GameInitial());

  /// Yeni bir oyun oturumu başlatır.
  Future<void> startGame(GameConfig config) async {
    _cancelTimer();
    emit(const GameLoading());

    try {
      final allCountries = await countryRepository.getAllCountries();
      final questions = questionGenerator.generateSessionQuestions(
        allCountries: allCountries,
        config: config,
      );

      _emitQuestionState(
        config: config,
        questions: questions,
        index: 0,
        score: 0,
        streak: 0,
        highestStreak: 0,
        correctCount: 0,
        wrongCount: 0,
      );
    } catch (e) {
      emit(GameError(e.toString()));
    }
  }

  /// Oyuncu 4 seçenekten birine dokunduğunda çağrılır.
  void submitAnswer(int selectedIndex) {
    final currentState = state;
    // Yalnızca GamePlaying durumundayken cevap kabul edilir (çift tıklama koruması)
    if (currentState is! GamePlaying) return;

    _cancelTimer();

    final isCorrect =
        currentState.currentQuestion.isCorrectSelection(selectedIndex);

    final scoreResult = scoreCalculator.calculate(
      isCorrect: isCorrect,
      currentStreak: currentState.streak,
      remainingSeconds: currentState.remainingSeconds,
    );

    final updatedScore = currentState.score + scoreResult.totalEarned;
    final updatedStreak = scoreResult.newStreak;
    final updatedHighestStreak =
        max(currentState.highestStreak, updatedStreak);
    final updatedCorrect =
        currentState.correctCount + (isCorrect ? 1 : 0);
    final updatedWrong = currentState.wrongCount + (isCorrect ? 0 : 1);

    emit(
      GameAnswered(
        config: currentState.config,
        questions: currentState.questions,
        currentIndex: currentState.currentIndex,
        selectedOptionIndex: selectedIndex,
        isCorrect: isCorrect,
        isTimeout: false,
        scoreResult: scoreResult,
        totalScore: updatedScore,
        streak: updatedStreak,
        highestStreak: updatedHighestStreak,
        correctCount: updatedCorrect,
        wrongCount: updatedWrong,
      ),
    );
  }

  /// Cevap geri bildirimi sonrası sonraki soruya veya sonuç ekranına geçer.
  void nextQuestion() {
    final currentState = state;
    if (currentState is! GameAnswered) return;

    if (currentState.isLastQuestion) {
      emit(
        GameCompleted(
          config: currentState.config,
          finalScore: currentState.totalScore,
          totalQuestions: currentState.totalQuestions,
          correctCount: currentState.correctCount,
          wrongCount: currentState.wrongCount,
          highestStreak: currentState.highestStreak,
        ),
      );
      return;
    }

    _emitQuestionState(
      config: currentState.config,
      questions: currentState.questions,
      index: currentState.currentIndex + 1,
      score: currentState.totalScore,
      streak: currentState.streak,
      highestStreak: currentState.highestStreak,
      correctCount: currentState.correctCount,
      wrongCount: currentState.wrongCount,
    );
  }

  void _emitQuestionState({
    required GameConfig config,
    required List<Question> questions,
    required int index,
    required int score,
    required int streak,
    required int highestStreak,
    required int correctCount,
    required int wrongCount,
  }) {
    final initialSeconds = config.questionTimeLimitSeconds;

    emit(
      GamePlaying(
        config: config,
        questions: questions,
        currentIndex: index,
        score: score,
        streak: streak,
        highestStreak: highestStreak,
        correctCount: correctCount,
        wrongCount: wrongCount,
        remainingSeconds: initialSeconds,
      ),
    );

    if (initialSeconds != null) {
      _startTimer(initialSeconds);
    }
  }

  void _startTimer(int seconds) {
    _cancelTimer();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentState = state;
      if (currentState is! GamePlaying) {
        timer.cancel();
        return;
      }

      final currentRemaining = currentState.remainingSeconds ?? 0;
      if (currentRemaining <= 1) {
        timer.cancel();
        _handleTimeout(currentState);
      } else {
        emit(currentState.copyWith(remainingSeconds: currentRemaining - 1));
      }
    });
  }

  void _handleTimeout(GamePlaying playingState) {
    final scoreResult = scoreCalculator.calculate(
      isCorrect: false,
      currentStreak: playingState.streak,
      remainingSeconds: 0,
    );

    emit(
      GameAnswered(
        config: playingState.config,
        questions: playingState.questions,
        currentIndex: playingState.currentIndex,
        selectedOptionIndex: null,
        isCorrect: false,
        isTimeout: true,
        scoreResult: scoreResult,
        totalScore: playingState.score,
        streak: 0,
        highestStreak: playingState.highestStreak,
        correctCount: playingState.correctCount,
        wrongCount: playingState.wrongCount + 1,
      ),
    );
  }

  void _cancelTimer() {
    _questionTimer?.cancel();
    _questionTimer = null;
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}