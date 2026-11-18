import 'package:equatable/equatable.dart';

/// Zorluk seviyesi sabitleri.
enum DifficultyLevel {
  easy(1),
  medium(2),
  hard(3),
  expert(4);

  final int value;
  const DifficultyLevel(this.value);
}

/// Domain katmanı temel Ülke varlığı (Entity).
/// Dış veri kaynaklarından (JSON, Firebase) tamamen bağımsızdır.
class Country extends Equatable {
  final String code;
  final String nameEn;
  final String nameTr;
  final List<String> capitalsEn;
  final List<String> capitalsTr;
  final String region;
  final String subregion;
  final int difficulty; // 1: Easy, 2: Medium, 3: Hard
  final String flagAsset;

  const Country({
    required this.code,
    required this.nameEn,
    required this.nameTr,
    required this.capitalsEn,
    required this.capitalsTr,
    required this.region,
    required this.subregion,
    required this.difficulty,
    required this.flagAsset,
  });

  /// Ülkenin geçerli bir başkenti olup olmadığını kontrol eder (BR-01).
  bool get hasCapital => capitalsEn.isNotEmpty && capitalsTr.isNotEmpty;

  /// Seçili dile göre ülke adını döndürür.
  String getLocalizedName(String languageCode) {
    return languageCode == 'tr' ? nameTr : nameEn;
  }

  /// Birden fazla başkenti varsa virgülle birleştirerek döndürür (BR-02).
  String getFormattedCapital(String languageCode) {
    final list = languageCode == 'tr' ? capitalsTr : capitalsEn;
    if (list.isEmpty) return '';
    return list.join(', ');
  }

  @override
  List<Object?> get props => [
        code,
        nameEn,
        nameTr,
        capitalsEn,
        capitalsTr,
        region,
        subregion,
        difficulty,
        flagAsset,
      ];
}