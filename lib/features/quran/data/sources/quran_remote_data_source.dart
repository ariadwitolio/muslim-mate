import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:muslim_mate/features/quran/data/models/quran_verse_data_model.dart';
import 'package:muslim_mate/features/quran/data/models/surah_detail_model.dart';

class QuranRemoteDataSource {
  const QuranRemoteDataSource();

  static const Map<int, List<int>> _juzSurahMap = {
    1: [1, 2],
    2: [2],
    3: [2, 3],
    4: [3, 4],
    5: [4],
    6: [4, 5],
    7: [5, 6],
    8: [6, 7],
    9: [7, 8],
    10: [8, 9],
    11: [9, 10, 11],
    12: [11, 12],
    13: [12, 13, 14],
    14: [15, 16],
    15: [17, 18],
    16: [18, 19, 20],
    17: [21, 22],
    18: [23, 24, 25],
    19: [25, 26, 27],
    20: [27, 28, 29],
    21: [29, 30, 31, 32, 33],
    22: [33, 34, 35, 36],
    23: [36, 37, 38, 39],
    24: [39, 40, 41],
    25: [41, 42, 43, 44, 45],
    26: [46, 47, 48, 49, 50, 51],
    27: [51, 52, 53, 54, 55, 56, 57],
    28: [58, 59, 60, 61, 62, 63, 64, 65, 66],
    29: [67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77],
    30: [78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114],
  };

  Future<SurahDetail> fetchSurahDetail(int number) async {
    final detailFuture = _fetchEquranSurah(number);
    final quranComFuture = fetchQuranComVerseData(number);
    final results = await Future.wait([detailFuture, quranComFuture]);

    final detail = results[0] as SurahDetail;
    final quranMeta = results[1] as QuranVerseData;
    final Map<int, String> translations = quranMeta.translations;
    final Map<int, int> juzNumbers = quranMeta.juzNumbers;

    if (translations.values.every((value) => value.isEmpty)) {
      final fallback = await fetchAlQuranCloudTranslation(number);
      translations.addAll(fallback.translations);
      juzNumbers.addAll(fallback.juzNumbers);
    }

    final ayahs = detail.ayat.map((ayah) {
      final translated = translations[ayah.nomorAyat] ?? '';
      final juz = juzNumbers[ayah.nomorAyat] ?? ayah.juzNumber ?? 1;
      return ayah.copyWith(teksEnglish: translated, juzNumber: juz);
    }).toList();

    final juzNumber = ayahs.isNotEmpty ? ayahs.first.juzNumber : detail.juzNumber;
    return detail.copyWith(ayat: ayahs, juzNumber: juzNumber);
  }

  Future<List<SurahDetail>> fetchJuzDetail(int juzNumber) async {
    final surahNumbers = _juzSurahMap[juzNumber] ?? [];
    if (surahNumbers.isEmpty) {
      throw Exception('Invalid Juz number');
    }

    final futures = surahNumbers.map((number) => fetchSurahDetail(number)).toList();
    final surahs = await Future.wait(futures);

    final List<SurahDetail> filteredSurahs = [];
    for (final surah in surahs) {
      final filteredAyat = surah.ayat.where((ayah) => ayah.juzNumber == juzNumber).toList();
      if (filteredAyat.isNotEmpty) {
        filteredSurahs.add(surah.copyWith(ayat: filteredAyat, juzNumber: juzNumber));
      }
    }
    
    return filteredSurahs;
  }

  Future<SurahDetail> _fetchEquranSurah(int number) async {
    final uri = Uri.parse('https://equran.id/api/v2/surat/$number');
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Failed to load surah detail.');
    }
    final body = json.decode(response.body) as Map<String, dynamic>?;
    final data = body?['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Invalid surah detail response.');
    }
    return SurahDetail.fromJson(data);
  }

  Future<QuranVerseData> fetchQuranComVerseData(int number) async {
    final uri = Uri.parse(
      'https://api.quran.com/api/v4/verses/by_chapter/$number?language=en&translations=131&per_page=300',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      return const QuranVerseData(translations: {}, juzNumbers: {});
    }

    final body = json.decode(response.body) as Map<String, dynamic>?;
    final verses = body?['verses'] as List<dynamic>?;
    if (verses == null) {
      return const QuranVerseData(translations: {}, juzNumbers: {});
    }

    final translations = <int, String>{};
    final juzNumbers = <int, int>{};
    for (final item in verses) {
      final verse = item as Map<String, dynamic>;
      final verseNumber = verse['verse_number'] as int? ?? 0;
      juzNumbers[verseNumber] =
          verse['juz_number'] as int? ?? juzNumbers[verseNumber] ?? 1;
      final translationList = verse['translations'] as List<dynamic>?;
      if (translationList != null && translationList.isNotEmpty) {
        final text = (translationList.first as Map<String, dynamic>)['text'] as String? ?? '';
        translations[verseNumber] = text;
      }
    }

    return QuranVerseData(translations: translations, juzNumbers: juzNumbers);
  }

  Future<QuranVerseData> fetchAlQuranCloudTranslation(int number) async {
    final uri = Uri.parse('https://api.alquran.cloud/v1/surah/$number/en.sahih');
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      return const QuranVerseData(translations: {}, juzNumbers: {});
    }

    final body = json.decode(response.body) as Map<String, dynamic>?;
    final data = body?['data'] as Map<String, dynamic>?;
    final ayahs = data?['ayahs'] as List<dynamic>?;
    if (ayahs == null) {
      return const QuranVerseData(translations: {}, juzNumbers: {});
    }

    final translations = <int, String>{};
    final juzNumbers = <int, int>{};
    for (final item in ayahs) {
      final ayah = item as Map<String, dynamic>;
      final verseNumber = ayah['numberInSurah'] as int? ?? 0;
      translations[verseNumber] = ayah['text'] as String? ?? '';
      juzNumbers[verseNumber] = ayah['juz'] as int? ?? juzNumbers[verseNumber] ?? 1;
    }
    return QuranVerseData(translations: translations, juzNumbers: juzNumbers);
  }
}
