import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color _kBackground = Color(0xFFF4F7FB);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kBorder = Color(0xFFE6EBF1);
const Color _kTextPrimary = Color(0xFF111827);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kAccent = Color(0xFF0F8D93);
const String _kLastReadKey = 'last_read';

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahDetailScreen({
    required this.surahNumber,
    required this.surahName,
    super.key,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final ScrollController _tabScrollController = ScrollController();
  final List<GlobalKey> _tabKeys = List.generate(114, (_) => GlobalKey());

  bool _loading = true;
  String? _errorMessage;
  SurahDetail? _surahDetail;
  LastRead? _lastRead;
  int _selectedAyah = 1;
  List<SurahTab> _surahTabs = [];
  bool _loadingTabs = true;

  @override
  void initState() {
    super.initState();
    _loadLastRead();
    _loadSurahTabs();
    _loadSurah(widget.surahNumber);
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLastReadKey);
    if (raw == null) {
      return;
    }
    try {
      final jsonMap = json.decode(raw) as Map<String, dynamic>?;
      if (jsonMap != null) {
        setState(() {
          _lastRead = LastRead.fromJson(jsonMap);
        });
      }
    } catch (_) {
      // ignore malformed saved state
    }
  }

  Future<void> _loadSurahTabs() async {
    setState(() {
      _loadingTabs = true;
    });
    try {
      _surahTabs = await _fetchSurahTabs();
    } catch (_) {
      _surahTabs = [];
    } finally {
      if (mounted) {
        setState(() {
          _loadingTabs = false;
        });
      }
      _scrollToActiveTab();
    }
  }

  Future<void> _loadSurah(int number) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _surahDetail = null;
      _selectedAyah = 1;
    });

    try {
      final detail = await _fetchSurahDetail(number);
      if (!mounted) return;
      setState(() {
        _surahDetail = detail;
        _selectedAyah = detail.ayat.isNotEmpty
            ? detail.ayat.first.nomorAyat
            : 1;
      });
      _scrollToActiveTab();
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<List<SurahTab>> _fetchSurahTabs() async {
    final uri = Uri.parse('https://equran.id/api/v2/surat');
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Failed to load surah tabs.');
    }
    final data = json.decode(response.body) as Map<String, dynamic>?;
    final surahData = data?['data'] as List<dynamic>?;
    if (surahData == null) {
      throw Exception('Invalid surah list response.');
    }
    return surahData
        .map(
          (item) => SurahTab(
            nomor: item['nomor'] as int? ?? 0,
            namaLatin: item['namaLatin'] as String? ?? '',
          ),
        )
        .toList();
  }

  Future<SurahDetail> _fetchSurahDetail(int number) async {
    final detailFuture = _fetchEquranSurah(number);
    final quranComFuture = _fetchQuranComVerseData(number);
    final results = await Future.wait([detailFuture, quranComFuture]);

    final detail = results[0] as SurahDetail;
    final quranMeta = results[1] as QuranVerseData;
    final Map<int, String> translations = quranMeta.translations;
    final Map<int, int> juzNumbers = quranMeta.juzNumbers;

    if (translations.values.every((value) => value.isEmpty)) {
      final fallback = await _fetchAlQuranCloudTranslation(number);
      translations.addAll(fallback.translations);
      juzNumbers.addAll(fallback.juzNumbers);
    }

    final ayahs = detail.ayat.map((ayah) {
      final translated = translations[ayah.nomorAyat] ?? '';
      final juz = juzNumbers[ayah.nomorAyat] ?? ayah.juzNumber ?? 1;
      return ayah.copyWith(teksEnglish: translated, juzNumber: juz);
    }).toList();

    final juzNumber = ayahs.isNotEmpty
        ? ayahs.first.juzNumber
        : detail.juzNumber;
    return detail.copyWith(ayat: ayahs, juzNumber: juzNumber);
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

  Future<QuranVerseData> _fetchQuranComVerseData(int number) async {
    final uri = Uri.parse(
      'https://api.quran.com/api/v4/verses/by_chapter/$number?language=en&translations=131&per_page=300',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      return QuranVerseData(translations: {}, juzNumbers: {});
    }

    final body = json.decode(response.body) as Map<String, dynamic>?;
    final verses = body?['verses'] as List<dynamic>?;
    if (verses == null) {
      return QuranVerseData(translations: {}, juzNumbers: {});
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
        final text =
            (translationList.first as Map<String, dynamic>)['text']
                as String? ??
            '';
        translations[verseNumber] = text;
      }
    }

    return QuranVerseData(translations: translations, juzNumbers: juzNumbers);
  }

  Future<QuranVerseData> _fetchAlQuranCloudTranslation(int number) async {
    final uri = Uri.parse(
      'https://api.alquran.cloud/v1/surah/$number/en.sahih',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      return QuranVerseData(translations: {}, juzNumbers: {});
    }

    final body = json.decode(response.body) as Map<String, dynamic>?;
    final data = body?['data'] as Map<String, dynamic>?;
    final ayahs = data?['ayahs'] as List<dynamic>?;
    if (ayahs == null) {
      return QuranVerseData(translations: {}, juzNumbers: {});
    }

    final translations = <int, String>{};
    final juzNumbers = <int, int>{};
    for (final item in ayahs) {
      final ayah = item as Map<String, dynamic>;
      final verseNumber = ayah['numberInSurah'] as int? ?? 0;
      translations[verseNumber] = ayah['text'] as String? ?? '';
      juzNumbers[verseNumber] =
          ayah['juz'] as int? ?? juzNumbers[verseNumber] ?? 1;
    }
    return QuranVerseData(translations: translations, juzNumbers: juzNumbers);
  }

  Future<void> _bookmarkCurrentAyah() async {
    if (_surahDetail == null) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final bookmark = LastRead(
      surahNumber: _surahDetail!.nomor,
      surahName: _surahDetail!.namaLatin,
      ayat: _selectedAyah,
    );
    await prefs.setString(_kLastReadKey, json.encode(bookmark.toJson()));
    if (!mounted) return;
    setState(() {
      _lastRead = bookmark;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bookmark saved.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _selectAyah(int ayahNumber) {
    setState(() {
      _selectedAyah = ayahNumber;
    });
  }

  void _scrollToActiveTab() {
    if (_surahTabs.isEmpty || _surahDetail == null) {
      return;
    }
    final activeIndex = _surahTabs.indexWhere(
      (tab) => tab.nomor == _surahDetail!.nomor,
    );
    if (activeIndex < 0 || activeIndex >= _tabKeys.length) {
      return;
    }
    final context = _tabKeys[activeIndex].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 250),
        alignment: 0.5,
        curve: Curves.easeOut,
      );
    }
  }

  TextStyle _jakarta({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color color = _kTextPrimary,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  TextStyle _arabic({
    double fontSize = 28,
    FontWeight fontWeight = FontWeight.w500,
    Color color = _kTextPrimary,
  }) {
    return GoogleFonts.scheherazadeNew(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.4,
    );
  }

  String get _selectedLocation {
    final place = _surahDetail?.tempatTurun.toLowerCase() ?? '';
    return place.startsWith('mek') ? 'Mekkah' : 'Madinah';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: _kSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        toolbarOpacity: 1.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _kTextSecondary),
          onPressed: Navigator.of(context).pop,
        ),
        titleSpacing: 0,
        title: _buildAppBarSearchField(),
        actions: [
          _buildAppBarIcon(Icons.tune, onTap: () {}, bordered: false),
          _buildAppBarIcon(Icons.settings, onTap: () {}, bordered: false),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: _buildLoading(),
              )
            : _errorMessage != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: _buildError(),
                  )
                : _buildContent(),
      ),
    );
  }

  bool get _isCurrentLocationBookmarked {
    return _lastRead != null &&
        _lastRead!.surahNumber == _surahDetail?.nomor &&
        _lastRead!.ayat == _selectedAyah;
  }

  Widget _buildAppBarIcon(IconData icon,
      {required VoidCallback onTap, bool bordered = true}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(14),
            border: bordered ? Border.all(color: _kBorder) : null,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: _kTextSecondary),
        ),
      ),
    );
  }

  Widget _buildAppBarSearchField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search, color: _kTextSecondary, size: 20),
          const SizedBox(width: 10),
          Text(
            'Search',
            style: _jakarta(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _kTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final detail = _surahDetail!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSurahTabs(),
        _buildInfoBar(detail),
        Expanded(child: _buildAyahList(detail)),
      ],
    );
  }

  Widget _buildInfoChip({required String label, bool active = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: active ? const Color.fromRGBO(15, 141, 147, 0.12) : _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: active ? _kAccent : const Color(0xFFE6EBF1)),
      ),
      child: Text(
        label,
        style: _jakarta(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: active ? _kAccent : _kTextSecondary,
        ),
      ),
    );
  }

  Widget _buildSurahTabs() {
    if (_loadingTabs) {
      return SizedBox(
        height: 52,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 6,
          separatorBuilder: (context, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            return Container(
              width: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFF5F5F5),
              ),
            );
          },
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: SizedBox(
        height: 52,
        child: ListView.separated(
          controller: _tabScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _surahTabs.length,
          separatorBuilder: (context, _) => const SizedBox(width: 24),
          itemBuilder: (context, index) {
            final tab = _surahTabs[index];
            final active = tab.nomor == _surahDetail?.nomor;
            return GestureDetector(
              key: _tabKeys[index],
              onTap: () => _loadSurah(tab.nomor),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${tab.nomor}. ${tab.namaLatin}',
                    style: _jakarta(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? _kAccent : _kTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2,
                    width: active ? 36 : 0,
                    decoration: BoxDecoration(
                      color: _kAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoBar(SurahDetail detail) {
    final englishTitle = SurahEnglishNames.english[detail.nomor] ?? detail.arti;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Center(
        child: Text(
          'Juz ${detail.juzNumber}  |  $englishTitle (${detail.jumlahAyat} Ayah)  |  ${_selectedLocation}',
          textAlign: TextAlign.center,
          style: _jakarta(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: _kTextSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildAyahList(SurahDetail detail) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: detail.ayat.length,
      separatorBuilder: (context, _) =>
          const Divider(color: Color(0xFFE5E7EB), height: 1),
      itemBuilder: (context, index) {
        final ayah = detail.ayat[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AyahNumberBadge(number: ayah.nomorAyat),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ayah.teksArab,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: _arabic(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: _kTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ayah.teksLatin,
                style: _jakarta(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _kTextSecondary,
                ).copyWith(fontStyle: FontStyle.italic, height: 1.6),
              ),
              const SizedBox(height: 8),
              Text(
                ayah.teksEnglish.isNotEmpty
                    ? ayah.teksEnglish
                    : 'Translation unavailable',
                style: _jakarta(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _kTextPrimary,
                ).copyWith(height: 1.6),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmerBox(height: 22, width: 200),
        const SizedBox(height: 16),
        _buildShimmerBox(height: 52),
        const SizedBox(height: 18),
        Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: index == 4 ? 0 : 18),
                child: _buildShimmerItem(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerBox({required double height, double? width}) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFECEFF2),
      highlightColor: const Color(0xFFF8FAFC),
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFECEFF2),
      highlightColor: const Color(0xFFF8FAFC),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 26,
                  decoration: BoxDecoration(
                    color: _kSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _kSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _kSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Unable to load the surah',
            style: _jakarta(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage ?? 'Please try again.',
            textAlign: TextAlign.center,
            style: _jakarta(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _kTextSecondary,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () => _loadSurah(widget.surahNumber),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: Text(
              'Retry',
              style: _jakarta(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SurahTab {
  final int nomor;
  final String namaLatin;

  SurahTab({required this.nomor, required this.namaLatin});
}

class QuranVerseData {
  final Map<int, String> translations;
  final Map<int, int> juzNumbers;

  QuranVerseData({required this.translations, required this.juzNumbers});
}

class SurahDetail {
  final int nomor;
  final String nama;
  final String namaLatin;
  final String arti;
  final int jumlahAyat;
  final String tempatTurun;
  final List<Ayah> ayat;
  final SpecialSurahNavigation? suratSebelumnya;
  final SpecialSurahNavigation? suratSelanjutnya;
  final int juzNumber;

  SurahDetail({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.arti,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.ayat,
    required this.suratSebelumnya,
    required this.suratSelanjutnya,
    required this.juzNumber,
  });

  SurahDetail copyWith({List<Ayah>? ayat, int? juzNumber}) {
    return SurahDetail(
      nomor: nomor,
      nama: nama,
      namaLatin: namaLatin,
      arti: arti,
      jumlahAyat: jumlahAyat,
      tempatTurun: tempatTurun,
      ayat: ayat ?? this.ayat,
      suratSebelumnya: suratSebelumnya,
      suratSelanjutnya: suratSelanjutnya,
      juzNumber: juzNumber ?? this.juzNumber,
    );
  }

  factory SurahDetail.fromJson(Map<String, dynamic> json) {
    return SurahDetail(
      nomor: json['nomor'] as int? ?? 0,
      nama: json['nama'] as String? ?? '',
      namaLatin: json['namaLatin'] as String? ?? '',
      arti: json['arti'] as String? ?? '',
      jumlahAyat: json['jumlahAyat'] as int? ?? 0,
      tempatTurun: json['tempatTurun'] as String? ?? '',
      ayat:
          (json['ayat'] as List<dynamic>?)
              ?.map((item) => Ayah.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      suratSebelumnya: json['suratSebelumnya'] is Map<String, dynamic>
          ? SpecialSurahNavigation.fromJson(
              json['suratSebelumnya'] as Map<String, dynamic>,
            )
          : null,
      suratSelanjutnya: json['suratSelanjutnya'] is Map<String, dynamic>
          ? SpecialSurahNavigation.fromJson(
              json['suratSelanjutnya'] as Map<String, dynamic>,
            )
          : null,
      juzNumber: 1,
    );
  }
}

class Ayah {
  final int nomorAyat;
  final String teksArab;
  final String teksLatin;
  final String teksEnglish;
  final int? juzNumber;

  Ayah({
    required this.nomorAyat,
    required this.teksArab,
    required this.teksLatin,
    required this.teksEnglish,
    this.juzNumber,
  });

  Ayah copyWith({String? teksEnglish, int? juzNumber}) {
    return Ayah(
      nomorAyat: nomorAyat,
      teksArab: teksArab,
      teksLatin: teksLatin,
      teksEnglish: teksEnglish ?? this.teksEnglish,
      juzNumber: juzNumber ?? this.juzNumber,
    );
  }

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      nomorAyat: json['nomorAyat'] as int? ?? 0,
      teksArab: json['teksArab'] as String? ?? '',
      teksLatin: json['teksLatin'] as String? ?? '',
      teksEnglish: '',
      juzNumber: null,
    );
  }
}

class SpecialSurahNavigation {
  final int nomor;
  final String namaLatin;

  SpecialSurahNavigation({required this.nomor, required this.namaLatin});

  factory SpecialSurahNavigation.fromJson(Map<String, dynamic> json) {
    return SpecialSurahNavigation(
      nomor: json['nomor'] as int? ?? 0,
      namaLatin: json['namaLatin'] as String? ?? '',
    );
  }
}

class LastRead {
  final int surahNumber;
  final String surahName;
  final int ayat;

  LastRead({
    required this.surahNumber,
    required this.surahName,
    required this.ayat,
  });

  Map<String, dynamic> toJson() {
    return {'surahNumber': surahNumber, 'surahName': surahName, 'ayat': ayat};
  }

  factory LastRead.fromJson(Map<String, dynamic> json) {
    return LastRead(
      surahNumber: json['surahNumber'] as int? ?? 0,
      surahName: json['surahName'] as String? ?? '',
      ayat: json['ayat'] as int? ?? 1,
    );
  }
}

class SurahEnglishNames {
  static const Map<int, String> english = {
    1: 'The Opening',
    2: 'The Cow',
    3: 'Family of Imran',
    4: 'The Women',
    5: 'The Table Spread',
    6: 'The Cattle',
    7: 'The Heights',
    8: 'The Spoils of War',
    9: 'The Repentance',
    10: 'Jonah',
    11: 'Hud',
    12: 'Joseph',
    13: 'The Thunder',
    14: 'Abraham',
    15: 'The Rocky Tract',
    16: 'The Bee',
    17: 'The Night Journey',
    18: 'The Cave',
    19: 'Mary',
    20: 'Ta-Ha',
    21: 'The Prophets',
    22: 'The Pilgrimage',
    23: 'The Believers',
    24: 'The Light',
    25: 'The Criterion',
    26: 'The Poets',
    27: 'The Ant',
    28: 'The Stories',
    29: 'The Spider',
    30: 'The Romans',
    31: 'Luqman',
    32: 'The Prostration',
    33: 'The Combined Forces',
    34: 'Sheba',
    35: 'The Originator',
    36: 'Ya-Sin',
    37: 'Those Ranged in Ranks',
    38: 'Sad',
    39: 'The Groups',
    40: 'The Forgiver',
    41: 'Explained in Detail',
    42: 'The Consultation',
    43: 'The Ornaments of Gold',
    44: 'The Smoke',
    45: 'The Crouching',
    46: 'The Wind-Curved Sandhills',
    47: 'Muhammad',
    48: 'The Victory',
    49: 'The Rooms',
    50: 'Qaf',
    51: 'The Winnowing Winds',
    52: 'The Mount',
    53: 'The Star',
    54: 'The Moon',
    55: 'The Beneficent',
    56: 'The Inevitable',
    57: 'The Iron',
    58: 'The Pleading Woman',
    59: 'The Exile',
    60: 'She That is to be Examined',
    61: 'The Ranks',
    62: 'Friday',
    63: 'The Hypocrites',
    64: 'Mutual Disillusion',
    65: 'The Divorce',
    66: 'The Prohibition',
    67: 'The Sovereignty',
    68: 'The Pen',
    69: 'The Reality',
    70: 'The Ascending Stairways',
    71: 'Noah',
    72: 'The Jinn',
    73: 'The Enshrouded One',
    74: 'The Cloaked One',
    75: 'The Resurrection',
    76: 'The Man',
    77: 'The Emissaries',
    78: 'The Tidings',
    79: 'Those Who Drag Forth',
    80: 'He Frowned',
    81: 'The Overthrowing',
    82: 'The Cleaving',
    83: 'The Defrauding',
    84: 'The Splitting Open',
    85: 'The Mansions of the Stars',
    86: 'The Nightcommer',
    87: 'The Most High',
    88: 'The Overwhelming',
    89: 'The Dawn',
    90: 'The City',
    91: 'The Sun',
    92: 'The Night',
    93: 'The Morning Hours',
    94: 'The Relief',
    95: 'The Fig',
    96: 'The Clot',
    97: 'The Power',
    98: 'The Clear Proof',
    99: 'The Earthquake',
    100: 'The Courser',
    101: 'The Calamity',
    102: 'The Rivalry in World Increase',
    103: 'The Declining Day',
    104: 'The Traducer',
    105: 'The Elephant',
    106: 'Quraysh',
    107: 'The Small Kindnesses',
    108: 'The Abundance',
    109: 'The Disbelievers',
    110: 'The Divine Support',
    111: 'The Palm Fiber',
    112: 'The Sincerity',
    113: 'The Daybreak',
    114: 'Mankind',
  };
}

class _AyahNumberBadge extends StatelessWidget {
  final int number;

  const _AyahNumberBadge({required this.number, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HexagonBorderPainter(),
      child: SizedBox(
        width: 32,
        height: 32,
        child: Center(
          child: Text(
            number.toString(),
            style: GoogleFonts.plusJakartaSans(
              color: _kAccent,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _HexagonBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = _kSurface
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = _kAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w * 0.25, 0);
    path.lineTo(w * 0.75, 0);
    path.lineTo(w, h * 0.5);
    path.lineTo(w * 0.75, h);
    path.lineTo(w * 0.25, h);
    path.lineTo(0, h * 0.5);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
