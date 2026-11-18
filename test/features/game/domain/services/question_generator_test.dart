import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo/core/errors/exceptipns.dart';
import 'package:geo/features/game/domain/entities/country.dart';
import 'package:geo/features/game/domain/entities/game_config.dart';
import 'package:geo/features/game/domain/entities/game_enums.dart';
import 'package:geo/features/game/domain/services/question_generator.dart';

void main() {
  late QuestionGenerator generator;
  late List<Country> sampleCountries;

  setUp(() {
    // Deterministik test sonuçları için sabit seed (42) kullanıyoruz
    generator = QuestionGenerator(random: Random(42));

    sampleCountries = List.generate(15, (i) {
      return Country(
        code: 'c$i',
        nameEn: 'Country $i',
        nameTr: 'Ülke $i',
        // Son 2 ülkenin başkenti yok (BR-01 edge case testi için)
        capitalsEn: i >= 13 ? const [] : ['Capital $i'],
        capitalsTr: i >= 13 ? const [] : ['Başkent $i'],
        region: i % 2 == 0 ? 'Europe' : 'Asia',
        subregion: 'Subregion',
        difficulty: (i % 3) + 1,
        flagAsset: 'assets/flags/c$i.svg',
      );
    });
  });

  group('QuestionGenerator Tests', () {
    test('tam olarak istenen sayıda (10) tekrarsız soru üretmeli', () {
      const config = GameConfig(
        mode: GameMode.flagQuiz,
        difficulty: DifficultyLevel.expert,
        totalQuestions: 10,
      );

      final questions = generator.generateSessionQuestions(
        allCountries: sampleCountries,
        config: config,
      );

      expect(questions.length, 10);

      // Aynı oturumda aynı hedef ülkenin tekrar sorulmadığını doğrula
      final targetCodes = questions.map((q) => q.targetCountry.code).toSet();
      expect(targetCodes.length, 10);
    });

    test('her soruda 4 farklı seçenek ve 1 geçerli doğru cevap indeksi olmalı', () {
      const config = GameConfig(
        mode: GameMode.flagQuiz,
        difficulty: DifficultyLevel.medium,
        totalQuestions: 10,
      );

      final questions = generator.generateSessionQuestions(
        allCountries: sampleCountries,
        config: config,
      );

      for (final q in questions) {
        expect(q.options.length, 4);
        final uniqueOptionIds = q.options.map((o) => o.id).toSet();
        expect(uniqueOptionIds.length, 4);
        expect(q.correctOptionIndex, inInclusiveRange(0, 3));
        expect(q.options[q.correctOptionIndex].id, q.targetCountry.code);
      }
    });

    test('CapitalQuiz modunda başkenti olmayan ülkeler filtrelenmeli (BR-01)', () {
      const config = GameConfig(
        mode: GameMode.capitalQuiz,
        difficulty: DifficultyLevel.expert,
        totalQuestions: 10,
      );

      final questions = generator.generateSessionQuestions(
        allCountries: sampleCountries,
        config: config,
      );

      for (final q in questions) {
        expect(q.targetCountry.hasCapital, isTrue);
        expect(q.correctOption.text, isNotEmpty);
      }
    });

    test('4ten az geçerli ülke varsa GameEngineException fırlatmalı', () {
      const config = GameConfig(
        mode: GameMode.flagQuiz,
        difficulty: DifficultyLevel.easy,
      );

      expect(
        () => generator.generateSessionQuestions(
          allCountries: sampleCountries.take(3).toList(),
          config: config,
        ),
        throwsA(isA<GameEngineException>()),
      );
    });
  });
}