import 'package:equatable/equatable.dart';
import '../../../progress/domain/entities/player_stats.dart';

/// Uygulama geneli tema, dil, ses, onboarding ve istatistik durumunu tutar.
class AppState extends Equatable {
  final bool isDarkMode;
  final String languageCode;
  final bool soundEnabled;
  final bool isOnboardingCompleted;
  final PlayerStats stats;
  final List<String> lastUnlockedAchievements;

  const AppState({
    this.isDarkMode = false,
    this.languageCode = 'tr',
    this.soundEnabled = true,
    this.isOnboardingCompleted = false,
    this.stats = const PlayerStats(),
    this.lastUnlockedAchievements = const [],
  });

  AppState copyWith({
    bool? isDarkMode,
    String? languageCode,
    bool? soundEnabled,
    bool? isOnboardingCompleted,
    PlayerStats? stats,
    List<String>? lastUnlockedAchievements,
  }) {
    return AppState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      stats: stats ?? this.stats,
      lastUnlockedAchievements:
          lastUnlockedAchievements ?? this.lastUnlockedAchievements,
    );
  }

  @override
  List<Object?> get props => [
        isDarkMode,
        languageCode,
        soundEnabled,
        isOnboardingCompleted,
        stats,
        lastUnlockedAchievements,
      ];
}