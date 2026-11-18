import 'package:equatable/equatable.dart';
import 'country.dart';
import 'game_enums.dart';

/// Bir sorudaki tek bir seçeneği temsil eder.
class QuestionOption extends Equatable {
  final String id; // Ülke kodu (örn. 'tr')
  final String text; // Ekranda gösterilecek metin (Ülke adı veya Başkent adı)

  const QuestionOption({
    required this.id,
    required this.text,
  });

  @override
  List<Object?> get props => [id, text];
}

/// Tek bir yarışma sorusunu temsil eden değişmez (immutable) Domain varlığı.
class Question extends Equatable {
  final GameMode mode;
  final Country targetCountry;
  final String promptText; // CapitalQuiz: Ülke adı, CountryQuiz: Başkent adı
  final String? flagAssetPath; // Yalnızca FlagQuiz modunda dolu olur
  final List<QuestionOption> options;
  final int correctOptionIndex;

  const Question({
    required this.mode,
    required this.targetCountry,
    required this.promptText,
    this.flagAssetPath,
    required this.options,
    required this.correctOptionIndex,
  });

  QuestionOption get correctOption => options[correctOptionIndex];

  bool isCorrectSelection(int selectedIndex) {
    return selectedIndex == correctOptionIndex;
  }

  @override
  List<Object?> get props => [
        mode,
        targetCountry,
        promptText,
        flagAssetPath,
        options,
        correctOptionIndex,
      ];
}