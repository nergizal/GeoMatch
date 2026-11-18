import 'dart:math';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo/features/game/domain/entities/country.dart';
import 'package:geo/features/game/domain/entities/game_config.dart';
import 'package:geo/features/game/domain/entities/game_enums.dart';
import 'package:geo/features/game/domain/repositories/country_repository.dart';
import 'package:geo/features/game/domain/services/question_generator.dart';
import 'package:geo/features/game/domain/services/score_calculator.dart';
import 'package:geo/features/game/presentation/cubit/game_cubit.dart';
import 'package:geo/features/game/presentation/cubit/game_state.dart';
import 'package:mocktail/mocktail.dart';

class MockCountryRepository extends Mock implements CountryRepository {}

void main() {
  late MockCountryRepository mockRepo;
  late QuestionGenerator generator;
  late ScoreCalculator calculator;
  late List<Country> testCountries;

  setUp(() {
    mockRepo = MockCountryRepository();
    generator = QuestionGenerator(random: Random(1));
    calculator = const ScoreCalculator();

    testCountries = List.generate(
      10,
      (i) => Country(
        code: 'c$i',
        nameEn: 'Country $i',
        nameTr: 'Ülke $i',
        capitalsEn: ['Capital $i'],
        capitalsTr: ['Başkent $i'],
        region: 'Europe',
        subregion: 'Western Europe',
        difficulty: 1,
        flagAsset: 'assets/flags/c$i.svg',
      ),
    );

    when(() => mockRepo.getAllCountries()).thenAnswer((_) async => testCountries);
  });

  group('GameCubit Tests', () {
    const config = GameConfig(
      mode: GameMode.flagQuiz,
      difficulty: DifficultyLevel.easy,
      totalQuestions: 2,
    );

    blocTest<GameCubit, GameState>(
      'startGame çağrıldığında önce GameLoading sonra GamePlaying yayınlamalı',
      build: () => GameCubit(
        countryRepository: mockRepo,
        questionGenerator: generator,
        scoreCalculator: calculator,
      ),
      act: (cubit) => cubit.startGame(config),
      expect: () => [
        isA<GameLoading>(),
        isA<GamePlaying>()
            .having((s) => s.currentIndex, 'currentIndex', 0)
            .having((s) => s.totalQuestions, 'totalQuestions', 2)
            .having((s) => s.score, 'score', 0),
      ],
    );

    blocTest<GameCubit, GameState>(
      'doğru ve yanlış cevapları takip edip GameCompleted içinde kodları döndürmeli',
      build: () => GameCubit(
        countryRepository: mockRepo,
        questionGenerator: generator,
        scoreCalculator: calculator,
      ),
      act: (cubit) async {
        await cubit.startGame(config);
        final q1 = (cubit.state as GamePlaying).currentQuestion;
        // 1. soruya DOĞRU cevap
        cubit.submitAnswer(q1.correctOptionIndex);
        cubit.nextQuestion();

        final q2 = (cubit.state as GamePlaying).currentQuestion;
        // 2. soruya YANLIŞ cevap
        cubit.submitAnswer((q2.correctOptionIndex + 1) % 4);
        cubit.nextQuestion();
      },
      expect: () => [
        isA<GameLoading>(),
        isA<GamePlaying>(),
        isA<GameAnswered>()
            .having((s) => s.isCorrect, 'isCorrect', true)
            .having((s) => s.totalScore, 'totalScore', 100),
        isA<GamePlaying>().having((s) => s.currentIndex, 'currentIndex', 1),
        isA<GameAnswered>()
            .having((s) => s.isCorrect, 'isCorrect', false)
            .having((s) => s.totalScore, 'totalScore', 100)
            .having((s) => s.streak, 'streak', 0),
        isA<GameCompleted>()
            .having((s) => s.finalScore, 'finalScore', 100)
            .having((s) => s.correctCount, 'correctCount', 1)
            .having((s) => s.wrongCount, 'wrongCount', 1)
            .having((s) => s.correctCountryCodes.length, 'correctCodes', 1)
            .having((s) => s.wrongCountryCodes.length, 'wrongCodes', 1),
      ],
    );

    blocTest<GameCubit, GameState>(
      'GamePlaying dışındaki durumlarda ikinci submitAnswer çağrısı yoksayılmalı (kilit koruması)',
      build: () => GameCubit(
        countryRepository: mockRepo,
        questionGenerator: generator,
        scoreCalculator: calculator,
      ),
      act: (cubit) async {
        await cubit.startGame(config);
        final q1 = (cubit.state as GamePlaying).currentQuestion;
        cubit.submitAnswer(q1.correctOptionIndex);
        cubit.submitAnswer((q1.correctOptionIndex + 1) % 4);
      },
      expect: () => [
        isA<GameLoading>(),
        isA<GamePlaying>(),
        isA<GameAnswered>().having((s) => s.isCorrect, 'isCorrect', true),
      ],
    );
  });
}
