import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../settings/presentation/cubit/app_cubit.dart';
import '../../domain/entities/achievement.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppCubit>().state;
    final stats = state.stats;
    final isTr = state.languageCode == 'tr';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isTr ? 'İstatistikler & Başarımlar' : 'Stats & Achievements'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.65,
              children: [
                _MetricCard(
                  title: isTr ? 'Toplam Puan' : 'Total Score',
                  value: '${stats.totalScore}',
                ),
                _MetricCard(
                  title: isTr ? 'En Yüksek Skor' : 'Best Session',
                  value: '${stats.bestScore}',
                ),
                _MetricCard(
                  title: isTr ? 'Oynanan Oyun' : 'Games Played',
                  value: '${stats.gamesPlayed}',
                ),
                _MetricCard(
                  title: isTr ? 'En Uzun Seri' : 'Longest Streak',
                  value: '${stats.highestStreak}',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              isTr
                  ? 'Başarımlar (${stats.unlockedAchievementIds.length}/${Achievement.catalog.length})'
                  : 'Achievements (${stats.unlockedAchievementIds.length}/${Achievement.catalog.length})',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...Achievement.catalog.map((achievement) {
              final unlocked =
                  stats.unlockedAchievementIds.contains(achievement.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: unlocked
                          ? AppColors.accentGold.withValues(alpha: 0.2)
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      child: Icon(
                        unlocked
                            ? Icons.emoji_events_rounded
                            : Icons.lock_outline_rounded,
                        color: unlocked
                            ? AppColors.accentGold
                            : theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    title: Text(
                      achievement.getTitle(state.languageCode),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: unlocked
                            ? null
                            : theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    subtitle: Text(
                      achievement.getDescription(state.languageCode),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;

  const _MetricCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(title, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
