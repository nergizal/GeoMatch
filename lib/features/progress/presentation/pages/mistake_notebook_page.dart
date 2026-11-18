import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../app/di/injection.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../game/domain/entities/country.dart';
import '../../../game/domain/entities/game_config.dart';
import '../../../game/domain/repositories/country_repository.dart';
import '../../../settings/presentation/cubit/app_cubit.dart';

class MistakeNotebookPage extends StatelessWidget {
  const MistakeNotebookPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppCubit>().state;
    final lang = appState.languageCode;
    final isTr = lang == 'tr';
    final theme = Theme.of(context);
    final mistakeCodes = appState.stats.mistakeCountryCodes;

    return Scaffold(
      appBar: AppBar(
        title: Text(isTr ? 'Hata Defteri' : 'Mistake Notebook'),
      ),
      body: SafeArea(
        child: mistakeCodes.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 64,
                        color: AppColors.successLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isTr
                            ? 'Harika! Bekleyen hatan yok.'
                            : 'Awesome! No pending mistakes.',
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isTr
                            ? 'Oyunlarda yanlış bildiğin ülkeler burada toplanır ve tekrar çalışabilirsin.'
                            : 'Countries you miss during quizzes appear here so you can master them.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : FutureBuilder<List<Country>>(
                future: sl<CountryRepository>().getAllCountries(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final codeSet = mistakeCodes.toSet();
                  final mistakeCountries = snapshot.data!
                      .where((c) => codeSet.contains(c.code))
                      .toList();

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: mistakeCountries.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final country = mistakeCountries[index];
                            final capital = country.getFormattedCapital(lang);
                            return Card(
                              child: ListTile(
                                leading: Container(
                                  width: 48,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: SvgPicture.asset(
                                    country.flagAsset,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  country.getLocalizedName(lang),
                                  style: theme.textTheme.titleMedium,
                                ),
                                subtitle: Text(
                                  capital.isNotEmpty
                                      ? '${isTr ? 'Başkent' : 'Capital'}: $capital'
                                      : country.region,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final config = GameConfig.mistakePractice(
                              mistakeCodes: mistakeCodes,
                              languageCode: lang,
                            );
                            Navigator.of(context).pushReplacementNamed(
                              AppRoutes.gamePlay,
                              arguments: config,
                            );
                          },
                          icon: const Icon(Icons.school_rounded),
                          label: Text(
                            isTr
                                ? 'Hatalarımı Tekrar Çöz (${mistakeCountries.length})'
                                : 'Practice Mistakes (${mistakeCountries.length})',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
