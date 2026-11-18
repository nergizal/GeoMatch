import '../../domain/entities/country.dart';

/// JSON veri yapısını Domain Entity'ye dönüştüren Data katmanı modeli.
class CountryModel extends Country {
  const CountryModel({
    required super.code,
    required super.nameEn,
    required super.nameTr,
    required super.capitalsEn,
    required super.capitalsTr,
    required super.region,
    required super.subregion,
    required super.difficulty,
    required super.flagAsset,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      code: (json['code'] as String).toLowerCase().trim(),
      nameEn: (json['name_en'] as String).trim(),
      nameTr: (json['name_tr'] as String).trim(),
      capitalsEn: List<String>.from(json['capitals_en'] as List? ?? const []),
      capitalsTr: List<String>.from(json['capitals_tr'] as List? ?? const []),
      region: (json['region'] as String? ?? 'Unknown').trim(),
      subregion: (json['subregion'] as String? ?? 'Unknown').trim(),
      difficulty: json['difficulty'] as int? ?? 2,
      flagAsset: (json['flag_asset'] as String).trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name_en': nameEn,
      'name_tr': nameTr,
      'capitals_en': capitalsEn,
      'capitals_tr': capitalsTr,
      'region': region,
      'subregion': subregion,
      'difficulty': difficulty,
      'flag_asset': flagAsset,
    };
  }
}