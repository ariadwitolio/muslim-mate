import 'package:muslim_mate/features/prayer/data/sources/prayer_remote_data_source.dart';
import 'package:muslim_mate/features/prayer/domain/repositories/prayer_repository.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  PrayerRepositoryImpl(this.remoteDataSource);

  final PrayerRemoteDataSource remoteDataSource;

  @override
  Future<PrayerResponse> fetchPrayerTimes(
    double latitude,
    double longitude,
    DateTime date,
  ) async {
    final responseModel = await remoteDataSource.fetchPrayerTimes(
      latitude,
      longitude,
      date,
    );
    return responseModel.toEntity();
  }
}
