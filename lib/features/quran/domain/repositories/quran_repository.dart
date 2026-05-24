import 'package:muslim_mate/features/quran/data/models/surah_detail_model.dart';

abstract class QuranRepository {
  Future<SurahDetail> fetchSurahDetail(int number);
}
