import 'package:flutter_test/flutter_test.dart';
import 'package:geo/features/game/domain/services/score_calculator.dart';

void main() {
  late ScoreCalculator calculator;

  setUp(() {
    calculator = const ScoreCalculator();
  });

  group('ScoreCalculator Tests', () {
    test('yanlış cevapta 0 puan vermeli ve seriyi sıfırlamalı', () {
      final result = calculator.calculate(
        isCorrect: false,
        currentStreak: 4,
        remainingSeconds: 8,
      );

      expect(result.basePoints, 0);
      expect(result.streakBonus, 0);
      expect(result.timeBonus, 0);
      expect(result.totalEarned, 0);
      expect(result.newStreak, 0);
    });

    test('ilk doğru cevapta 100 temel puan vermeli ve seriyi 1 yapmalı', () {
      final result = calculator.calculate(
        isCorrect: true,
        currentStreak: 0,
      );

      expect(result.basePoints, 100);
      expect(result.streakBonus, 0);
      expect(result.totalEarned, 100);
      expect(result.newStreak, 1);
    });

    test('3. üst üste doğru cevapta +50 seri bonusu eklemeli', () {
      final result = calculator.calculate(
        isCorrect: true,
        currentStreak: 2,
      );

      expect(result.basePoints, 100);
      expect(result.streakBonus, 50);
      expect(result.totalEarned, 150);
      expect(result.newStreak, 3);
    });

    test('5. üst üste doğru cevapta +100 seri bonusu eklemeli', () {
      final result = calculator.calculate(
        isCorrect: true,
        currentStreak: 4,
      );

      expect(result.basePoints, 100);
      expect(result.streakBonus, 100);
      expect(result.totalEarned, 200);
      expect(result.newStreak, 5);
    });

    test('süreli modda kalan saniye başına +5 süre bonusu eklemeli', () {
      final result = calculator.calculate(
        isCorrect: true,
        currentStreak: 0,
        remainingSeconds: 6,
      );

      expect(result.basePoints, 100);
      expect(result.timeBonus, 30);
      expect(result.totalEarned, 130);
    });
  });
}