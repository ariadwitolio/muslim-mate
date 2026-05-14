import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  static const Color _kSurface = Color(0xFFF4F7FB);
  static const Color _kBorder = Color(0xFFE6EBF1);
  static const Color _kTextPrimary = Color(0xFF111827);
  static const Color _kTextSecondary = Color(0xFF6B7280);
  static const Color _kTeal = Color(0xFF11A4AA);
  static const Color _kBadge = Color(0xFF0F8D93);

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
    final surahNumber = prefs.getInt('last_read_surah_number');
    if (surahNumber == null) {
      setState(() {
        _lastRead = null;
      });
      return;
    }
    final surahName = prefs.getString('last_read_surah_name') ?? 'Unknown';
    final ayat = prefs.getInt('last_read_ayat') ?? 1;
    setState(() {
      _lastRead = LastRead(
        surahNumber: surahNumber,
        surahName: surahName,
        ayat: ayat,
      );
    });
  }

  Future<void> _saveLastRead(Surah surah, {int ayat = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_read_surah_number', surah.nomor);
    await prefs.setString('last_read_surah_name', surah.namaLatin);
    await prefs.setInt('last_read_ayat', ayat);
    setState(() {
      _lastRead = LastRead(
        surahNumber: surah.nomor,
        surahName: surah.namaLatin,
        ayat: ayat,
      );
    });
  }

  void _openSurahDetail(Surah surah) {
    _saveLastRead(surah);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurahDetailScreen(
          surahNumber: surah.nomor,
          surahName: surah.namaLatin,
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text('Al Quran'),
        titleTextStyle: const TextStyle(
          color: _kTextPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildSearchBar()),
                  const SizedBox(width: 12),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _kSurface,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(28),
                        child: const Icon(Icons.bookmark_border, size: 24, color: _kTextSecondary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTabBar(),
              const SizedBox(height: 16),
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
        color: _kSurface,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          color: _kTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: const InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(child: _buildTabItem('Surah', 0)),
          const SizedBox(width: 8),
          Expanded(child: _buildTabItem('Juz', 1)),
          const SizedBox(width: 8),
          Expanded(child: _buildTabItem('Last Read', 2)),
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
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: selected ? _kTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : _kTextSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 14,
          ),
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
        child: const Text(
          'Surah not found',
          style: TextStyle(
            color: _kTextSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
      itemBuilder: (context, index) {
        final surah = filtered[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openSurahDetail(surah),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
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
                          style: const TextStyle(
                            color: _kTextPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${surah.arti}  •  ${surah.jumlahAyat} Ayah',
                          style: const TextStyle(
                            color: _kTextSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF9CA3AF),
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
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: const Color(0xFFE9EDF2),
          highlightColor: const Color(0xFFF6F8FB),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
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
                        height: 16,
                        width: 140,
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
          const Text(
            'Unable to load surahs',
            style: TextStyle(
              color: _kTextPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _kTextSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchSurahs,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kTeal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Text('Retry'),
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
      separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
      itemBuilder: (context, index) {
        final item = _juzItems[index];
        return GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _kSurface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'J${item.number}',
                    style: const TextStyle(
                      color: _kTextPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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
                        style: const TextStyle(
                          color: _kTextPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.startAyat,
                        style: const TextStyle(
                          color: _kTextSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
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

  Widget _buildLastReadTab() {
    if (_lastRead == null) {
      return Center(
        child: const Text(
          'No reading history yet',
          style: TextStyle(
            color: _kTextSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last Read',
              style: TextStyle(
                color: _kTextSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${_lastRead!.surahName} • Ayat ${_lastRead!.ayat}',
              style: const TextStyle(
                color: _kTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Surah ${_lastRead!.surahNumber}',
              style: const TextStyle(
                color: _kTextSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
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

  Surah({
    required this.nomor,
    required this.namaLatin,
    required this.arti,
    required this.jumlahAyat,
  });

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
        color: color,
        alignment: Alignment.center,
        child: Text(
          number.toString(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
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
