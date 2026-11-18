import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/game_config.dart';
import '../../domain/entities/question.dart';
import '../../domain/repositories/country_repository.dart';
import '../../domain/services/question_generator.dart';
import '../../domain/services/score_calculator.dart';
import 'game_state.dart';

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
        correctCodes: const [],
        wrongCodes: const [],
      );
    } catch (e) {
      emit(GameError(e.toString()));
    }
  }

  void submitAnswer(int selectedIndex) {
    final currentState = state;
    if (currentState is! GamePlaying) return;

    _cancelTimer();

    final isCorrect =
        currentState.currentQuestion.isCorrectSelection(selectedIndex);
    final countryCode = currentState.currentQuestion.targetCountry.code;

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

    final updatedCorrectCodes = isCorrect
        ? [...currentState.correctCountryCodes, countryCode]
        : currentState.correctCountryCodes;
    final updatedWrongCodes = !isCorrect
        ? [...currentState.wrongCountryCodes, countryCode]
        : currentState.wrongCountryCodes;

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
        correctCountryCodes: updatedCorrectCodes,
        wrongCountryCodes: updatedWrongCodes,
      ),
    );
  }

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
          correctCountryCodes: currentState.correctCountryCodes,
          wrongCountryCodes: currentState.wrongCountryCodes,
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
      correctCodes: currentState.correctCountryCodes,
      wrongCodes: currentState.wrongCountryCodes,
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
    required List<String> correctCodes,
    required List<String> wrongCodes,
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
        correctCountryCodes: correctCodes,
        wrongCountryCodes: wrongCodes,
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
    final countryCode = playingState.currentQuestion.targetCountry.code;
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
        correctCountryCodes: playingState.correctCountryCodes,
        wrongCountryCodes: [...playingState.wrongCountryCodes, countryCode],
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
