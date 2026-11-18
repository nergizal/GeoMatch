/// Yerel veri okuma veya ayrıştırma (parsing) sırasında oluşan hatalar.
class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Yerel veri yüklenirken bir hata oluştu.']);

  @override
  String toString() => 'CacheException: $message';
}

/// Oyun motoru veya soru üretimi sırasında oluşan kural ihlali hataları.
class GameEngineException implements Exception {
  final String message;

  const GameEngineException([this.message = 'Oyun motoru hatası oluştu.']);

  @override
  String toString() => 'GameEngineException: $message';
}