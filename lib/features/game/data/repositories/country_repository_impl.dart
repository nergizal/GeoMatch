import '../../domain/entities/country.dart';
import '../../domain/repositories/country_repository.dart';
import '../datasources/country_local_datasource.dart';

/// CountryRepository arayüzünün somut uygulaması.
/// Performans için veriyi ilk okumada bellekte (RAM) önbellekler.
class CountryRepositoryImpl implements CountryRepository {
  final CountryLocalDataSource localDataSource;
  List<Country>? _cachedCountries;

  CountryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Country>> getAllCountries() async {
    if (_cachedCountries != null) {
      return _cachedCountries!;
    }
    final models = await localDataSource.loadCountriesFromAsset();
    _cachedCountries = List<Country>.unmodifiable(models);
    return _cachedCountries!;
  }

  @override
  Future<List<Country>> getCountriesWithCapitals() async {
    final all = await getAllCountries();
    return all.where((country) => country.hasCapital).toList(growable: false);
  }

  @override
  Future<List<Country>> getCountriesByDifficulty(DifficultyLevel level) async {
    final all = await getAllCountries();
    if (level == DifficultyLevel.expert) {
      return all; // Expert modu tüm 195 ülkeyi kapsar.
    }
    return all
        .where((country) => country.difficulty <= level.value)
        .toList(growable: false);
  }
}