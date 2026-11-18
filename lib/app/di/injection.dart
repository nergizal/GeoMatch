import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/game/data/datasources/country_local_datasource.dart';
import '../../features/game/data/repositories/country_repository_impl.dart';
import '../../features/game/domain/repositories/country_repository.dart';
import '../../features/game/domain/services/question_generator.dart';
import '../../features/game/domain/services/score_calculator.dart';
import '../../features/game/presentation/cubit/game_cubit.dart';
import '../../features/progress/data/repositories/local_storage_repository.dart';
import '../../features/settings/presentation/cubit/app_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  sl.registerLazySingleton<CountryLocalDataSource>(
    () => CountryLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<CountryRepository>(
    () => CountryRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<LocalStorageRepository>(
    () => LocalStorageRepository(sl()),
  );

  sl.registerLazySingleton<QuestionGenerator>(() => QuestionGenerator());
  sl.registerLazySingleton<ScoreCalculator>(() => const ScoreCalculator());

  sl.registerLazySingleton<AppCubit>(() => AppCubit(sl()));

  sl.registerFactory<GameCubit>(
    () => GameCubit(
      countryRepository: sl(),
      questionGenerator: sl(),
      scoreCalculator: sl(),
    ),
  );
}
