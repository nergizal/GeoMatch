import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../settings/presentation/cubit/app_cubit.dart';
import '../../../settings/presentation/cubit/app_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        final isTr = state.languageCode == 'tr';
        final theme = Theme.of(context);
        final stats = state.stats;
        final mistakeCount = stats.mistakeCountryCodes.length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('GeoMatch'),
            actions: [
              IconButton(
                tooltip: isTr ? 'Ayarlar' : 'Settings',
                icon: const Icon(Icons.settings_outlined),
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.settings),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.explore_rounded,
                                color: theme.colorScheme.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isTr ? 'Hoş Geldin!' : 'Welcome Back!',
                                    style: theme.textTheme.titleLarge,
                                  ),
                                  Text(
                                    isTr
                                        ? 'Coğrafya bilgini test etmeye hazır mısın?'
                                        : 'Ready to test your geography skills?',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatBadge(
                              label: isTr ? 'Toplam Puan' : 'Total Score',
                              value: '${stats.totalScore}',
                              icon: Icons.stars_rounded,
                              color: AppColors.accentGold,
                            ),
                            _StatBadge(
                              label: isTr ? 'En İyi Seri' : 'Best Streak',
                              value: '${stats.highestStreak}',
                              icon: Icons.local_fire_department_rounded,
                              color: Colors.deepOrange,
                            ),
                            _StatBadge(
                              label: isTr ? 'Doğruluk' : 'Accuracy',
                              value:
                                  '%${stats.accuracyPercentage.toStringAsFixed(0)}',
                              icon: Icons.check_circle_rounded,
                              color: AppColors.successLight,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.gameSetup),
                  icon: const Icon(Icons.play_arrow_rounded, size: 26),
                  label: Text(isTr ? 'Oyuna Başla' : 'Start Quiz'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.mistakes),
                  icon: const Icon(Icons.menu_book_rounded),
                  label: Text(
                    isTr
                        ? 'Hata Defteri ($mistakeCount Ülke)'
                        : 'Mistake Notebook ($mistakeCount)',
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.progress),
                  icon: const Icon(Icons.emoji_events_outlined),
                  label: Text(
                    isTr
                        ? 'İstatistikler & Başarımlar (${stats.unlockedAchievementIds.length}/6)'
                        : 'Stats & Achievements (${stats.unlockedAchievementIds.length}/6)',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBadge({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(value, style: theme.textTheme.titleLarge),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
