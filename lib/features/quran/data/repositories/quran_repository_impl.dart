import 'package:muslim_mate/features/quran/data/models/surah_detail_model.dart';
import 'package:muslim_mate/features/quran/data/sources/quran_remote_data_source.dart';
import 'package:muslim_mate/features/quran/domain/repositories/quran_repository.dart';

class QuranRepositoryImpl implements QuranRepository {
  final QuranRemoteDataSource remoteDataSource;

  QuranRepositoryImpl(this.remoteDataSource);

  @override
  Future<SurahDetail> fetchSurahDetail(int number) {
    return remoteDataSource.fetchSurahDetail(number);
  }
}
