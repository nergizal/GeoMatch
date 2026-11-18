import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../game/presentation/cubit/game_state.dart';
import '../../../progress/domain/entities/achievement.dart';
import '../../../settings/presentation/cubit/app_cubit.dart';

class ResultPage extends StatelessWidget {
  final GameCompleted result;

  const ResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppCubit>().state;
    final isTr = appState.languageCode == 'tr';
    final theme = Theme.of(context);

    final newBadges = Achievement.catalog
        .where((a) => appState.lastUnlockedAchievements.contains(a.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(isTr ? 'Oyun Özeti' : 'Match Summary'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      size: 64,
                      color: AppColors.accentGold,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${result.finalScore}',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      isTr ? 'TOPLAM PUAN' : 'TOTAL SCORE',
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ResultStat(
                          label: isTr ? 'Doğru' : 'Correct',
                          value: '${result.correctCount}',
                          color: AppColors.successLight,
                        ),
                        _ResultStat(
                          label: isTr ? 'Yanlış' : 'Wrong',
                          value: '${result.wrongCount}',
                          color: AppColors.errorLight,
                        ),
                        _ResultStat(
                          label: isTr ? 'En İyi Seri' : 'Best Streak',
                          value: '${result.highestStreak}',
                          color: Colors.deepOrange,
                        ),
                        _ResultStat(
                          label: isTr ? 'Başarı' : 'Accuracy',
                          value:
                              '%${result.accuracyPercentage.toStringAsFixed(0)}',
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (newBadges.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                isTr ? 'Yeni Kazanılan Başarımlar!' : 'New Achievements Unlocked!',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              ...newBadges.map(
                (badge) => Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.accentGold,
                      size: 32,
                    ),
                    title: Text(badge.getTitle(appState.languageCode)),
                    subtitle: Text(badge.getDescription(appState.languageCode)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(
                  AppRoutes.gamePlay,
                  arguments: result.config,
                );
              },
              icon: const Icon(Icons.replay_rounded),
              label: Text(isTr ? 'Tekrar Oyna' : 'Play Again'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.home,
                  (route) => false,
                );
              },
              child: Text(isTr ? 'Ana Menüye Dön' : 'Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(color: color),
        ),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
