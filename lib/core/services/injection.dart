import 'package:get_it/get_it.dart';
import 'package:muslim_mate/core/network/api_service.dart';
import 'package:muslim_mate/features/dzikir/data/sources/almatsurat_local_data_source.dart';
import 'package:muslim_mate/features/dzikir/data/repositories/dzikir_repository_impl.dart';
import 'package:muslim_mate/features/dzikir/domain/repositories/dzikir_repository.dart';
import 'package:muslim_mate/features/quran/data/repositories/quran_repository_impl.dart';
import 'package:muslim_mate/features/quran/data/sources/quran_remote_data_source.dart';
import 'package:muslim_mate/features/quran/domain/repositories/quran_repository.dart';
import 'package:muslim_mate/features/prayer/data/repositories/prayer_repository_impl.dart';
import 'package:muslim_mate/features/prayer/data/sources/location_data_source.dart';
import 'package:muslim_mate/features/prayer/data/sources/prayer_remote_data_source.dart';
import 'package:muslim_mate/features/prayer/domain/repositories/prayer_repository.dart';

final GetIt sl = GetIt.instance;

void configureDependencies() {
  if (sl.isRegistered<ApiService>()) {
    return;
  }

  sl.registerLazySingleton<ApiService>(
    () => ApiService(),
  );

  // Dzikir feature registrations
  if (!sl.isRegistered<AlMatsuratLocalDataSource>()) {
    sl.registerLazySingleton<AlMatsuratLocalDataSource>(
      () => AlMatsuratLocalDataSource(),
    );
  }

  if (!sl.isRegistered<DzikirRepository>()) {
    sl.registerLazySingleton<DzikirRepository>(
      () => DzikirRepositoryImpl(sl()),
    );
  }

  // Quran feature registrations
  if (!sl.isRegistered<QuranRemoteDataSource>()) {
    sl.registerLazySingleton<QuranRemoteDataSource>(
      () => const QuranRemoteDataSource(),
    );
  }

  if (!sl.isRegistered<QuranRepository>()) {
    sl.registerLazySingleton<QuranRepository>(
      () => QuranRepositoryImpl(sl()),
    );
  }

  // Prayer feature registrations
  if (!sl.isRegistered<LocationDataSource>()) {
    sl.registerLazySingleton<LocationDataSource>(
      () => const LocationDataSource(),
    );
  }

  if (!sl.isRegistered<PrayerRemoteDataSource>()) {
    sl.registerLazySingleton<PrayerRemoteDataSource>(
      () => const PrayerRemoteDataSource(),
    );
  }

  if (!sl.isRegistered<PrayerRepository>()) {
    sl.registerLazySingleton<PrayerRepository>(
      () => PrayerRepositoryImpl(sl()),
    );
  }
}

