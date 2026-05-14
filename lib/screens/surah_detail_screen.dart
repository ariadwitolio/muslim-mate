import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_mate/constants/index.dart';

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
  bool _loading = true;
  String? _errorMessage;
  SurahDetail? _surahDetail;
  int _selectedAyah = 1;

  @override
  void initState() {
    super.initState();
    _loadSurah(widget.surahNumber);
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
      setState(() {
        _surahDetail = detail;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<SurahDetail> _fetchSurahDetail(int number) async {
    final uri = Uri.parse('https://equran.id/api/v2/surat/$number');
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Failed to load surah detail (${response.statusCode}).');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>?;
    final data = body?['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Invalid surah detail response.');
    }

    return SurahDetail.fromJson(data);
  }

  Future<void> _bookmarkCurrentAyah() async {
    final detail = _surahDetail;
    if (detail == null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_read_surah_number', detail.nomor);
    await prefs.setString('last_read_surah_name', detail.namaLatin);
    await prefs.setInt('last_read_ayat', _selectedAyah);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved last read location.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _selectAyah(int number) {
    setState(() {
      _selectedAyah = number;
    });
  }

  SpecialSurahNavigation? get _previousSurah => _surahDetail?.suratSebelumnya;
  SpecialSurahNavigation? get _nextSurah => _surahDetail?.suratSelanjutnya;

  String get _surahEnglishMeaning {
    return SurahEnglishNames.english[_surahDetail?.nomor ?? widget.surahNumber] ?? _surahDetail?.arti ?? 'Surah';
  }

  String get _surahPlace {
    final place = _surahDetail?.tempatTurun.toLowerCase() ?? '';
    return place.startsWith('mek') ? 'Makkah' : 'Madinah';
  }

  String get _juzLabel {
    return 'Juz 1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: Navigator.of(context).pop,
        ),
        titleSpacing: 0,
        title: _buildSearchField(),
        actions: [
          _buildAppBarIcon(Icons.filter_list_outlined, onTap: () {}),
          _buildAppBarIcon(Icons.settings_outlined, onTap: () {}),
          _buildAppBarIcon(
            _surahDetail != null ? Icons.bookmark : Icons.bookmark_border,
            onTap: _bookmarkCurrentAyah,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: _loading
              ? _buildLoading()
              : _errorMessage != null
                  ? _buildError()
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey.shade500, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Search',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarIcon(IconData icon, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final detail = _surahDetail!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSurahTabs(detail),
        const SizedBox(height: 16),
        _buildInfoBar(detail),
        const SizedBox(height: 16),
        Expanded(child: _buildAyahList(detail)),
      ],
    );
  }

  Widget _buildSurahTabs(SurahDetail detail) {
    final currentLabel = '${detail.nomor}. ${detail.namaLatin}';
    final previousLabel = _previousSurah != null ? '${_previousSurah!.nomor}. ${_previousSurah!.namaLatin}' : null;
    final nextLabel = _nextSurah != null ? '${_nextSurah!.nomor}. ${_nextSurah!.namaLatin}' : null;

    return Row(
      children: [
        if (_previousSurah != null)
          Expanded(
            child: GestureDetector(
              onTap: () => _loadSurah(_previousSurah!.nomor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    previousLabel!,
                    style: TextStyle(
                      color: const Color(0xFF475569),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(height: 3, width: 72, decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(4))),
                ],
              ),
            ),
          ),
        if (_previousSurah != null) const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentLabel,
                  style: const TextStyle(
                    color: Color(0xFF0B525B),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF11A4AA),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_nextSurah != null) const SizedBox(width: 12),
        if (_nextSurah != null)
          Expanded(
            child: GestureDetector(
              onTap: () => _loadSurah(_nextSurah!.nomor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    nextLabel!,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: const Color(0xFF475569),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(height: 3, width: 72, decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(4))),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoBar(SurahDetail detail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Text(
        '$_juzLabel  |  $_surahEnglishMeaning (${detail.jumlahAyat} Ayah)  |  $_surahPlace',
        style: TextStyle(
          color: const Color(0xFF667085),
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildAyahList(SurahDetail detail) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: detail.ayat.length,
      separatorBuilder: (context, index) => const Divider(color: Color(0xFFE2E8F0), height: 1),
      itemBuilder: (context, index) {
        final ayah = detail.ayat[index];
        final selected = _selectedAyah == ayah.nomorAyat;
        return InkWell(
          onTap: () => _selectAyah(ayah.nomorAyat),
          child: Container(
            color: selected ? const Color(0xFFE6FFFE) : Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AyahNumberBadge(number: ayah.nomorAyat),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        ayah.teksArab,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.scheherazadeNew(
                          fontSize: 26,
                          height: 1.4,
                          color: AppColors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        ayah.teksLatin,
                        style: TextStyle(
                          color: const Color(0xFF667085),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ayah.teksIndonesia,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _buildShimmerBox(height: 20, width: 180),
        const SizedBox(height: 16),
        _buildShimmerBox(height: 60),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: index == 5 ? 0 : 16),
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
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
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
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
          const Text(
            'Unable to load Surah',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage ?? 'Please try again.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () => _loadSurah(widget.surahNumber),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF11A4AA),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
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
  });

  factory SurahDetail.fromJson(Map<String, dynamic> json) {
    return SurahDetail(
      nomor: json['nomor'] as int,
      nama: json['nama'] as String? ?? '',
      namaLatin: json['namaLatin'] as String? ?? '',
      arti: json['arti'] as String? ?? '',
      jumlahAyat: json['jumlahAyat'] as int? ?? 0,
      tempatTurun: json['tempatTurun'] as String? ?? '',
      ayat: (json['ayat'] as List<dynamic>?)
              ?.map((item) => Ayah.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      suratSebelumnya: json['suratSebelumnya'] is Map<String, dynamic>
          ? SpecialSurahNavigation.fromJson(json['suratSebelumnya'] as Map<String, dynamic>)
          : null,
      suratSelanjutnya: json['suratSelanjutnya'] is Map<String, dynamic>
          ? SpecialSurahNavigation.fromJson(json['suratSelanjutnya'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Ayah {
  final int nomorAyat;
  final String teksArab;
  final String teksLatin;
  final String teksIndonesia;

  Ayah({
    required this.nomorAyat,
    required this.teksArab,
    required this.teksLatin,
    required this.teksIndonesia,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      nomorAyat: json['nomorAyat'] as int? ?? 0,
      teksArab: json['teksArab'] as String? ?? '',
      teksLatin: json['teksLatin'] as String? ?? '',
      teksIndonesia: json['teksIndonesia'] as String? ?? '',
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

class _AyahNumberBadge extends StatelessWidget {
  final int number;

  const _AyahNumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HexagonBorderPainter(),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Text(
            number.toString(),
            style: const TextStyle(
              color: Color(0xFF0B525B),
              fontWeight: FontWeight.w700,
              fontSize: 13,
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
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = const Color(0xFF11A4AA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

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

    canvas.drawPath(path, paint);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    35: 'Originator',
    36: 'The Bee',
    37: 'Those Who Set The Ranks',
    38: 'Sad',
    39: 'The Groups',
    40: 'The Forgiver',
    41: 'Explained In Detail',
    42: 'The Consultation',
    43: 'The Gold Adornments',
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
    55: 'The Most Merciful',
    56: 'The Inevitable',
    57: 'The Iron',
    58: 'The Woman Who Disputes',
    59: 'The Exile',
    60: 'She that is to be examined',
    61: 'The Ranks',
    62: 'The Congregation',
    63: 'The Hypocrites',
    64: 'The Mutual Disillusion',
    65: 'The Divorce',
    66: 'The Prohibition',
    67: 'The Sovereignty',
    68: 'The Pen',
    69: 'The Reality',
    70: 'The Ascending Stairways',
    71: 'Noah',
    72: 'The Jinn',
    73: 'The Enshrouded One',
    74: 'The One Wrapped Up',
    75: 'The Resurrection',
    76: 'The Man',
    77: 'The Emissaries',
    78: 'The Tidings',
    79: 'Those who drag forth',
    80: 'He frowned',
    81: 'The Overthrowing',
    82: 'The Cleaving',
    83: 'Defrauding',
    84: 'The Splitting Open',
    85: 'The Mansions of the Stars',
    86: 'The Nightcomer',
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
    101: 'The Striking Hour',
    102: 'The Rivalry in world increase',
    103: 'The Declining Day',
    104: 'The Traducer',
    105: 'The Elephant',
    106: 'Quraysh',
    107: 'Small Kindnesses',
    108: 'Abundance',
    109: 'The Disbelievers',
    110: 'The Divine Support',
    111: 'The Palm Fibre',
    112: 'The Sincerity',
    113: 'The Daybreak',
    114: 'The Mankind',
  };
}
