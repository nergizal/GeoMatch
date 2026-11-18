import '../entities/country.dart';

/// Ülke verilerine erişim sözleşmesi (Dependency Inversion Principle).
/// Domain katmanı verinin nereden geldiğini bilmez, sadece bu arayüzü kullanır.
abstract interface class CountryRepository {
  /// Tüm ülkeleri getirir.
  Future<List<Country>> getAllCountries();

  /// Yalnızca başkenti bulunan ülkeleri getirir (Capital & Country Quiz için).
  Future<List<Country>> getCountriesWithCapitals();

  /// Zorluk seviyesine göre filtrelenmiş ülkeleri getirir.
  Future<List<Country>> getCountriesByDifficulty(DifficultyLevel level);
}