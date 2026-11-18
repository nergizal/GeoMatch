import 'package:flutter/material.dart';
import '../../features/game/domain/entities/game_config.dart';
import '../../features/game/presentation/cubit/game_state.dart';
import '../../features/game/presentation/pages/game_play_page.dart';
import '../../features/game/presentation/pages/game_setup_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/onboarding_page.dart';
import '../../features/progress/presentation/pages/mistake_notebook_page.dart';
import '../../features/progress/presentation/pages/progress_page.dart';
import '../../features/results/presentation/pages/result_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

abstract final class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String gameSetup = '/game-setup';
  static const String gamePlay = '/game-play';
  static const String gameResult = '/game-result';
  static const String mistakes = '/mistakes';
  static const String progress = '/progress';
  static const String settings = '/settings';
}

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());

      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case AppRoutes.gameSetup:
        return MaterialPageRoute(builder: (_) => const GameSetupPage());

      case AppRoutes.gamePlay:
        final config = settings.arguments as GameConfig;
        return MaterialPageRoute(builder: (_) => GamePlayPage(config: config));

      case AppRoutes.gameResult:
        final result = settings.arguments as GameCompleted;
        return MaterialPageRoute(builder: (_) => ResultPage(result: result));

      case AppRoutes.mistakes:
        return MaterialPageRoute(builder: (_) => const MistakeNotebookPage());

      case AppRoutes.progress:
        return MaterialPageRoute(builder: (_) => const ProgressPage());

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());

      default:
        return MaterialPageRoute(builder: (_) => const HomePage());
    }
  }
}
