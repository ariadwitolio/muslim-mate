import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_mate/constants/index.dart';
import 'package:muslim_mate/screens/surah_detail_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  static const Color _kBackground = Color(0xFFFFFFFF);
  static const Color _kSectionBackground = Color(0xFFF4F7FB);
  static const Color _kSurface = Color(0xFFFFFFFF);
  static const Color _kBorder = Color(0xFFE6EBF1);
  static const Color _kTextPrimary = Color(0xFF111827);
  static const Color _kTextSecondary = Color(0xFF6B7280);
  static const Color _kTabSelected = Color(0xFF0F8D93);
  static const Color _kBadge = Color(0xFF0F8D93);
  static const String _kLastReadKey = 'last_read';

  final TextEditingController _searchController = TextEditingController();
  final List<JuzItem> _juzItems = List.generate(
    30,
    (index) => JuzItem(
      number: index + 1,
      startSurah: 'Al-Fatihah',
      startAyat: 'Ayat 1',
    ),
  );

  List<Surah> _surahs = [];
  bool _loading = true;
  String? _errorMessage;
  int _selectedTabIndex = 0;
  String _searchQuery = '';
  LastRead? _lastRead;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchSurahs();
    _loadLastRead();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  Future<void> _fetchSurahs() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse('https://equran.id/api/v2/surat');
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw Exception('Failed to load surah list.');
      }
      final data = json.decode(response.body) as Map<String, dynamic>?;
      final surahData = data?['data'] as List<dynamic>?;
      if (surahData == null) {
        throw Exception('Invalid surah response.');
      }
      setState(() {
        _surahs = surahData
            .map((item) => Surah.fromJson(item as Map<String, dynamic>))
            .toList();
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

  Future<void> _loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLastReadKey);
    if (raw == null) {
      setState(() {
        _lastRead = null;
      });
      return;
    }

    try {
      final data = json.decode(raw) as Map<String, dynamic>?;
      if (data == null) {
        setState(() {
          _lastRead = null;
        });
        return;
      }
      setState(() {
        _lastRead = LastRead.fromJson(data);
      });
    } catch (_) {
      setState(() {
        _lastRead = null;
      });
    }
  }

  Future<void> _saveLastRead(Surah surah, {int ayat = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final lastRead = LastRead(
      surahNumber: surah.nomor,
      surahName: surah.namaLatin,
      ayat: ayat,
    );
    await prefs.setString(_kLastReadKey, json.encode(lastRead.toJson()));
    setState(() {
      _lastRead = lastRead;
    });
  }

  Future<void> _openSurahDetail(Surah surah) async {
    final navigator = Navigator.of(context);
    await _saveLastRead(surah);
    await navigator.push(
      MaterialPageRoute(
        builder: (_) => SurahDetailScreen(
          surahNumber: surah.nomor,
          surahName: surah.namaLatin,
        ),
      ),
    );
    if (!mounted) return;
    await _loadLastRead();
  }

  List<Surah> get _filteredSurahs {
    if (_searchQuery.isEmpty) {
      return _surahs;
    }
    final query = _searchQuery.trim().toLowerCase();
    return _surahs.where((surah) {
      final matchesName = surah.namaLatin.toLowerCase().contains(query);
      final matchesNumber = surah.nomor.toString().contains(query);
      return matchesName || matchesNumber;
    }).toList();
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

  Widget _buildSearchRow() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _kSectionBackground,
            borderRadius: BorderRadius.circular(18),
          ),
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.bookmark_border, color: _kTabSelected, size: 24),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _buildSearchBar()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _kBackground,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        toolbarHeight: 72,
        title: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Al Quran',
            style: _jakarta(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
        ),
        titleTextStyle: _jakarta(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: _kTextPrimary,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            children: [
              _buildSearchRow(),
              const SizedBox(height: 16),
              _buildTabBar(),
              const SizedBox(height: 18),
              Expanded(child: _buildTabContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: _kSectionBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _kSectionBackground),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: _kTextSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: _jakarta(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: _kTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: _jakarta(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _kTextSecondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: _kSectionBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _kSectionBackground),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(child: _buildTabItem('Surah', 0)),
          const SizedBox(width: 8),
          Expanded(child: _buildTabItem('Juz', 1)),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabItem('Last Read', 2, icon: Icons.access_time),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index, {IconData? icon}) {
    final selected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedTabIndex = index;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        decoration: BoxDecoration(
          color: selected ? _kTabSelected : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : _kTextSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: _jakarta(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? Colors.white : _kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 1:
        return _buildJuzList();
      case 2:
        return _buildLastReadTab();
      default:
        return _buildSurahTab();
    }
  }

  Widget _buildSurahTab() {
    if (_loading) {
      return _buildSurahListLoading();
    }

    if (_errorMessage != null) {
      return _buildSurahListError();
    }

    final filtered = _filteredSurahs;
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'Surah not found',
          style: _jakarta(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _kTextSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (context, _) =>
          const Divider(height: 1, thickness: 1, color: Color(0xFFE6EBF1)),
      itemBuilder: (context, index) {
        final surah = filtered[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openSurahDetail(surah),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  HexagonBadge(number: surah.nomor, color: _kBadge),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surah.namaLatin,
                          style: _jakarta(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _kTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${surah.englishTranslation} • ${surah.jumlahAyat} Ayah',
                          style: _jakarta(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _kTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSurahListLoading() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (context, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: const Color(0xFFE9EDF2),
          highlightColor: const Color(0xFFF6F8FB),
          child: Container(
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _kBorder),
            ),
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEE5EC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 18,
                        width: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEE5EC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 14,
                        width: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEE5EC),
                          borderRadius: BorderRadius.circular(8),
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

  Widget _buildSurahListError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Unable to load surahs',
            style: _jakarta(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: _jakarta(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: _kTextSecondary,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _fetchSurahs,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kTabSelected,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                'Retry',
                style: _jakarta(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJuzList() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: _juzItems.length,
      separatorBuilder: (context, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _juzItems[index];
        return Container(
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _kBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _kBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _kBorder),
                ),
                alignment: Alignment.center,
                child: Text(
                  'J${item.number}',
                  style: _jakarta(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.startSurah,
                      style: _jakarta(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.startAyat,
                      style: _jakarta(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _kTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: _kTextSecondary,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLastReadTab() {
    if (_lastRead == null) {
      return Center(
        child: Text(
          'No reading history yet',
          style: _jakarta(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _kTextSecondary,
          ),
        ),
      );
    }

    return Center(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _kBorder),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Last Read',
              style: _jakarta(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _kTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${_lastRead!.surahName} • Ayat ${_lastRead!.ayat}',
              style: _jakarta(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Surah ${_lastRead!.surahNumber}',
              style: _jakarta(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Surah {
  final int nomor;
  final String namaLatin;
  final String arti;
  final int jumlahAyat;

  static const Map<int, String> _englishNames = {
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

  Surah({
    required this.nomor,
    required this.namaLatin,
    required this.arti,
    required this.jumlahAyat,
  });

  String get englishTranslation => _englishNames[nomor] ?? arti;

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      nomor: json['nomor'] as int,
      namaLatin: json['namaLatin'] as String? ?? '',
      arti: json['arti'] as String? ?? '',
      jumlahAyat: json['jumlahAyat'] as int? ?? 0,
    );
  }
}

class JuzItem {
  final int number;
  final String startSurah;
  final String startAyat;

  JuzItem({
    required this.number,
    required this.startSurah,
    required this.startAyat,
  });
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

class HexagonBadge extends StatelessWidget {
  final int number;
  final Color color;

  const HexagonBadge({required this.number, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HexagonClipper(),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: const Color.fromRGBO(255, 255, 255, 0.18),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          number.toString(),
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
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
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
