import 'dart:math';
import 'package:geo/core/errors/exceptipns.dart';

import '../entities/country.dart';
import '../entities/game_config.dart';
import '../entities/game_enums.dart';
import '../entities/question.dart';

class QuestionGenerator {
  final Random _random;

  QuestionGenerator({Random? random}) : _random = random ?? Random();

  List<Question> generateSessionQuestions({
    required List<Country> allCountries,
    required GameConfig config,
  }) {
    final modeEligible = allCountries.where((country) {
      if (config.mode == GameMode.capitalQuiz ||
          config.mode == GameMode.countryQuiz) {
        return country.hasCapital;
      }
      return true;
    }).toList();

    if (modeEligible.length < 4) {
      throw const GameEngineException(
        'Soru üretmek için en az 4 geçerli ülke gereklidir.',
      );
    }

    List<Country> targetPool;
    if (config.isMistakePractice) {
      final codeSet = config.customCountryCodes!.toSet();
      targetPool =
          modeEligible.where((c) => codeSet.contains(c.code)).toList();
    } else if (config.difficulty == DifficultyLevel.expert) {
      targetPool = List<Country>.from(modeEligible);
    } else {
      targetPool = modeEligible
          .where((c) => c.difficulty <= config.difficulty.value)
          .toList();
    }

    if (targetPool.isEmpty) {
      targetPool = List<Country>.from(modeEligible);
    }

    final questionCount = min(config.totalQuestions, targetPool.length);

    targetPool.shuffle(_random);
    final selectedTargets = targetPool.take(questionCount).toList();

    return selectedTargets.map((target) {
      return _buildQuestion(
        target: target,
        distractorPool: modeEligible,
        config: config,
      );
    }).toList(growable: false);
  }

  Question _buildQuestion({
    required Country target,
    required List<Country> distractorPool,
    required GameConfig config,
  }) {
    final targetOption = _createOption(target, config);

    final sameRegionCandidates = distractorPool
        .where((c) => c.code != target.code && c.region == target.region)
        .toList()
      ..shuffle(_random);

    final selectedDistractors = <QuestionOption>[];
    final usedTexts = <String>{targetOption.text};

    void addCandidates(List<Country> candidates) {
      for (final candidate in candidates) {
        if (selectedDistractors.length == 3) break;
        final option = _createOption(candidate, config);
        if (option.text.isNotEmpty && !usedTexts.contains(option.text)) {
          usedTexts.add(option.text);
          selectedDistractors.add(option);
        }
      }
    }

    addCandidates(sameRegionCandidates);

    if (selectedDistractors.length < 3) {
      final otherCandidates = distractorPool
          .where((c) => c.code != target.code && c.region != target.region)
          .toList()
        ..shuffle(_random);
      addCandidates(otherCandidates);
    }

    if (selectedDistractors.length < 3) {
      throw GameEngineException(
        '${target.code} ülkesi için yeterli sayıda benzersiz çeldirici üretilemedi.',
      );
    }

    final allOptions = <QuestionOption>[targetOption, ...selectedDistractors]
      ..shuffle(_random);

    final correctIndex =
        allOptions.indexWhere((option) => option.id == targetOption.id);

    return Question(
      mode: config.mode,
      targetCountry: target,
      promptText: _buildPromptText(target, config),
      flagAssetPath:
          config.mode == GameMode.flagQuiz ? target.flagAsset : null,
      options: List<QuestionOption>.unmodifiable(allOptions),
      correctOptionIndex: correctIndex,
    );
  }

  QuestionOption _createOption(Country country, GameConfig config) {
    final text = switch (config.mode) {
      GameMode.flagQuiz => country.getLocalizedName(config.languageCode),
      GameMode.capitalQuiz => country.getFormattedCapital(config.languageCode),
      GameMode.countryQuiz => country.getLocalizedName(config.languageCode),
    };
    return QuestionOption(id: country.code, text: text);
  }

  String _buildPromptText(Country target, GameConfig config) {
    return switch (config.mode) {
      GameMode.flagQuiz => '',
      GameMode.capitalQuiz => target.getLocalizedName(config.languageCode),
      GameMode.countryQuiz => target.getFormattedCapital(config.languageCode),
    };
  }
}
