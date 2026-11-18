import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/settings/presentation/cubit/app_cubit.dart';
import '../features/settings/presentation/cubit/app_state.dart';
import 'di/injection.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class GeoMatchApp extends StatelessWidget {
  const GeoMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AppCubit>(),
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, appState) {
          return MaterialApp(
            title: 'GeoMatch',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: appState.isOnboardingCompleted
                ? AppRoutes.home
                : AppRoutes.onboarding,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
