import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geo/features/game/presentation/cubit/game_state.dart';

import '../../../progress/data/repositories/local_storage_repository.dart';
import '../../../progress/domain/entities/player_stats.dart';
import 'app_state.dart';

/// Uygulama genelindeki ayarları ve oyuncu ilerlemesini yöneten global Cubit.
class AppCubit extends Cubit<AppState> {
  final LocalStorageRepository _storage;

  AppCubit(this._storage)
      : super(
          AppState(
            isDarkMode: _storage.isDarkMode,
            languageCode: _storage.languageCode,
            soundEnabled: _storage.soundEnabled,
            isOnboardingCompleted: _storage.isOnboardingCompleted,
            stats: _storage.loadStats(),
          ),
        );

  Future<void> toggleDarkMode(bool isDark) async {
    await _storage.setDarkMode(isDark);
    emit(state.copyWith(isDarkMode: isDark));
  }

  Future<void> changeLanguage(String languageCode) async {
    await _storage.setLanguageCode(languageCode);
    emit(state.copyWith(languageCode: languageCode));
  }

  Future<void> toggleSound(bool enabled) async {
    await _storage.setSoundEnabled(enabled);
    emit(state.copyWith(soundEnabled: enabled));
  }

  Future<void> completeOnboarding() async {
    await _storage.setOnboardingCompleted(true);
    emit(state.copyWith(isOnboardingCompleted: true));
  }

  Future<void> onGameCompleted(GameCompleted result) async {
    final outcome = await _storage.recordCompletedGame(result);
    emit(
      state.copyWith(
        stats: outcome.updatedStats,
        lastUnlockedAchievements: outcome.newlyUnlocked,
      ),
    );
  }

  Future<void> resetProgress() async {
    await _storage.resetAllProgress();
    emit(
      state.copyWith(
        stats: const PlayerStats(),
        lastUnlockedAchievements: const [],
      ),
    );
  }
}