import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/router/app_router.dart';
import '../../../settings/presentation/cubit/app_cubit.dart';
import '../../domain/entities/country.dart';
import '../../domain/entities/game_config.dart';
import '../../domain/entities/game_enums.dart';

class GameSetupPage extends StatefulWidget {
  const GameSetupPage({super.key});

  @override
  State<GameSetupPage> createState() => _GameSetupPageState();
}

class _GameSetupPageState extends State<GameSetupPage> {
  GameMode _selectedMode = GameMode.flagQuiz;
  DifficultyLevel _selectedDifficulty = DifficultyLevel.easy;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppCubit>().state.languageCode;
    final isTr = lang == 'tr';
    final theme = Theme.of(context);

    final modes = [
      (
        mode: GameMode.flagQuiz,
        icon: Icons.flag_rounded,
        title: isTr ? 'Bayrak Bilmece' : 'Flag Quiz',
        subtitle: isTr
            ? 'Gösterilen bayrağın hangi ülkeye ait olduğunu bul'
            : 'Identify the country from its national flag',
      ),
      (
        mode: GameMode.capitalQuiz,
        icon: Icons.location_city_rounded,
        title: isTr ? 'Başkent Bulma' : 'Capital Quiz',
        subtitle: isTr
            ? 'Verilen ülkenin başkentini doğru tahmin et'
            : 'Match the given country with its capital city',
      ),
      (
        mode: GameMode.countryQuiz,
        icon: Icons.map_rounded,
        title: isTr ? 'Başkentten Ülkeye' : 'Country Quiz',
        subtitle: isTr
            ? 'Verilen başkentin hangi ülkeye ait olduğunu seç'
            : 'Find which country owns the displayed capital',
      ),
    ];

    final difficulties = [
      (
        level: DifficultyLevel.easy,
        label: isTr ? 'Kolay' : 'Easy',
        desc: isTr ? 'Popüler ülkeler • Süresiz' : 'Popular countries • Untimed',
      ),
      (
        level: DifficultyLevel.medium,
        label: isTr ? 'Orta' : 'Medium',
        desc: isTr ? 'Geniş ülke havuzu • Süresiz' : 'Broader pool • Untimed',
      ),
      (
        level: DifficultyLevel.hard,
        label: isTr ? 'Zor' : 'Hard',
        desc: isTr ? 'Tüm ülkeler • Süresiz' : 'All countries • Untimed',
      ),
      (
        level: DifficultyLevel.expert,
        label: isTr ? 'Uzman' : 'Expert',
        desc: isTr
            ? 'Tüm ülkeler • Soru başı 10 sn!'
            : 'All countries • 10s per question!',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(isTr ? 'Oyun Ayarları' : 'Game Setup'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    isTr ? '1. Oyun Modu Seç' : '1. Choose Game Mode',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...modes.map((item) {
                    final selected = _selectedMode == item.mode;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => setState(() => _selectedMode = item.mode),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: selected
                                ? theme.colorScheme.primaryContainer
                                : theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                color: theme.colorScheme.primary,
                                size: 28,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.subtitle,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              if (selected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: theme.colorScheme.primary,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Text(
                    isTr ? '2. Zorluk Seviyesi' : '2. Difficulty Level',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.55,
                    children: difficulties.map((diff) {
                      final selected = _selectedDifficulty == diff.level;
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () =>
                            setState(() => _selectedDifficulty = diff.level),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: selected
                                ? theme.colorScheme.primaryContainer
                                : theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                diff.label,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: selected
                                      ? theme.colorScheme.primary
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                diff.desc,
                                style: theme.textTheme.labelSmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  final config = GameConfig.fromSelection(
                    mode: _selectedMode,
                    difficulty: _selectedDifficulty,
                    languageCode: lang,
                  );
                  Navigator.of(context).pushNamed(
                    AppRoutes.gamePlay,
                    arguments: config,
                  );
                },
                child: Text(isTr ? 'Yarışmayı Başlat (10 Soru)' : 'Start Match (10 Questions)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
