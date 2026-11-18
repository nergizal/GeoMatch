import 'package:equatable/equatable.dart';
import 'country.dart';
import 'game_enums.dart';

class GameConfig extends Equatable {
  final GameMode mode;
  final DifficultyLevel difficulty;
  final String languageCode;
  final int totalQuestions;
  final int? questionTimeLimitSeconds;
  final List<String>? customCountryCodes;

  const GameConfig({
    required this.mode,
    required this.difficulty,
    this.languageCode = 'tr',
    this.totalQuestions = 10,
    this.questionTimeLimitSeconds,
    this.customCountryCodes,
  });

  factory GameConfig.fromSelection({
    required GameMode mode,
    required DifficultyLevel difficulty,
    String languageCode = 'tr',
  }) {
    return GameConfig(
      mode: mode,
      difficulty: difficulty,
      languageCode: languageCode,
      totalQuestions: 10,
      questionTimeLimitSeconds:
          difficulty == DifficultyLevel.expert ? 10 : null,
    );
  }

  factory GameConfig.mistakePractice({
    required List<String> mistakeCodes,
    String languageCode = 'tr',
  }) {
    return GameConfig(
      mode: GameMode.flagQuiz,
      difficulty: DifficultyLevel.expert,
      languageCode: languageCode,
      totalQuestions: mistakeCodes.length.clamp(1, 10),
      questionTimeLimitSeconds: null,
      customCountryCodes: mistakeCodes,
    );
  }

  bool get isTimed => questionTimeLimitSeconds != null;
  bool get isMistakePractice =>
      customCountryCodes != null && customCountryCodes!.isNotEmpty;

  @override
  List<Object?> get props => [
        mode,
        difficulty,
        languageCode,
        totalQuestions,
        questionTimeLimitSeconds,
        customCountryCodes,
      ];
}
