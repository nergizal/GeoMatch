import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../app/di/injection.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../settings/presentation/cubit/app_cubit.dart';
import '../../domain/entities/game_config.dart';
import '../../domain/entities/game_enums.dart';
import '../../domain/entities/question.dart';
import '../cubit/game_cubit.dart';
import '../cubit/game_state.dart';
import '../widgets/option_button.dart';

class GamePlayPage extends StatelessWidget {
  final GameConfig config;

  const GamePlayPage({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GameCubit>()..startGame(config),
      child: const _GamePlayView(),
    );
  }
}

class _GamePlayView extends StatelessWidget {
  const _GamePlayView();

  @override
  Widget build(BuildContext context) {
    final appCubit = context.watch<AppCubit>();
    final isTr = appCubit.state.languageCode == 'tr';

    return BlocConsumer<GameCubit, GameState>(
      listener: (context, state) async {
        if (state is GameAnswered) {
          if (state.isCorrect) {
            HapticFeedback.lightImpact();
          } else {
            HapticFeedback.heavyImpact();
          }
        } else if (state is GameCompleted) {
          await context.read<AppCubit>().onGameCompleted(state);
          if (!context.mounted) return;
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.gameResult,
            arguments: state,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state is GamePlaying
                  ? '${state.currentIndex + 1} / ${state.totalQuestions}'
                  : state is GameAnswered
                      ? '${state.currentIndex + 1} / ${state.totalQuestions}'
                      : 'GeoMatch',
            ),
            actions: [
              if (state is GamePlaying || state is GameAnswered)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            size: 18,
                            color: AppColors.accentGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${state is GamePlaying ? state.score : (state as GameAnswered).totalScore}',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: switch (state) {
              GameInitial() || GameLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
              GameError(:final message) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(message, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(isTr ? 'Geri Dön' : 'Go Back'),
                        ),
                      ],
                    ),
                  ),
                ),
              GamePlaying() => _buildActiveContent(
                  context: context,
                  question: state.currentQuestion,
                  progress: (state.currentIndex + 1) / state.totalQuestions,
                  streak: state.streak,
                  remainingSeconds: state.remainingSeconds,
                  timeLimit: state.config.questionTimeLimitSeconds,
                  isAnswered: false,
                  selectedOptionIndex: null,
                  isTr: isTr,
                ),
              GameAnswered() => _buildActiveContent(
                  context: context,
                  question: state.currentQuestion,
                  progress: (state.currentIndex + 1) / state.totalQuestions,
                  streak: state.streak,
                  remainingSeconds: 0,
                  timeLimit: state.config.questionTimeLimitSeconds,
                  isAnswered: true,
                  selectedOptionIndex: state.selectedOptionIndex,
                  scoreEarned: state.scoreResult.totalEarned,
                  isTimeout: state.isTimeout,
                  isLastQuestion: state.isLastQuestion,
                  isTr: isTr,
                ),
              GameCompleted() => const Center(
                  child: CircularProgressIndicator(),
                ),
            },
          ),
        );
      },
    );
  }

  Widget _buildActiveContent({
    required BuildContext context,
    required Question question,
    required double progress,
    required int streak,
    required int? remainingSeconds,
    required int? timeLimit,
    required bool isAnswered,
    required int? selectedOptionIndex,
    required bool isTr,
    int scoreEarned = 0,
    bool isTimeout = false,
    bool isLastQuestion = false,
  }) {
    final theme = Theme.of(context);
    const prefixes = ['A', 'B', 'C', 'D'];

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          minHeight: 5,
          backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Üst Bilgi Satırı: Seri (Streak) & Expert Süre Sayacı
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (streak > 0)
                    Chip(
                      avatar: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.deepOrange,
                        size: 18,
                      ),
                      label: Text(
                        isTr ? '$streak Seri!' : '$streak Streak!',
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  if (timeLimit != null && remainingSeconds != null && !isAnswered)
                    Chip(
                      avatar: Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: remainingSeconds <= 3
                            ? AppColors.errorLight
                            : theme.colorScheme.primary,
                      ),
                      label: Text(
                        '${remainingSeconds}s',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: remainingSeconds <= 3
                              ? AppColors.errorLight
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Soru Kartı (Bayrak veya Metin)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      Text(
                        _getQuestionInstruction(question.mode, isTr),
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      if (question.mode == GameMode.flagQuiz &&
                          question.flagAssetPath != null)
                        Container(
                          height: 155,
                          width: 240,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outline,
                              width: 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: SvgPicture.asset(
                            question.flagAssetPath!,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            question.promptText,
                            style: theme.textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 4 Seçenek Butonu
              ...List.generate(question.options.length, (index) {
                final option = question.options[index];
                OptionVisualState visualState = OptionVisualState.neutral;

                if (isAnswered) {
                  if (index == question.correctOptionIndex) {
                    visualState = OptionVisualState.correct;
                  } else if (index == selectedOptionIndex) {
                    visualState = OptionVisualState.wrong;
                  } else {
                    visualState = OptionVisualState.disabled;
                  }
                }

                return OptionButton(
                  labelPrefix: prefixes[index],
                  text: option.text,
                  visualState: visualState,
                  onTap: isAnswered
                      ? null
                      : () => context.read<GameCubit>().submitAnswer(index),
                );
              }),
            ],
          ),
        ),

        // Cevap Sonrası Alt Bilgilendirme & Devam Butonu
        if (isAnswered)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outline),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isTimeout)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      isTr ? 'Süre doldu!' : 'Time is up!',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.errorLight,
                      ),
                    ),
                  )
                else if (scoreEarned > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '+$scoreEarned ${isTr ? 'Puan!' : 'Points!'}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.successLight,
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: () => context.read<GameCubit>().nextQuestion(),
                  child: Text(
                    isLastQuestion
                        ? (isTr ? 'Sonuçları Gör' : 'See Results')
                        : (isTr ? 'Sonraki Soru' : 'Next Question'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _getQuestionInstruction(GameMode mode, bool isTr) {
    return switch (mode) {
      GameMode.flagQuiz =>
        isTr ? 'Bu bayrak hangi ülkeye aittir?' : 'Which country does this flag belong to?',
      GameMode.capitalQuiz =>
        isTr ? 'Bu ülkenin başkenti neresidir?' : 'What is the capital city of this country?',
      GameMode.countryQuiz =>
        isTr ? 'Bu şehir hangi ülkenin başkentidir?' : 'Which country has this capital city?',
    };
  }
}
