import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_mate/core/services/injection.dart';
import 'package:muslim_mate/features/quran/data/models/last_read_model.dart';
import 'package:muslim_mate/features/quran/data/models/surah_detail_model.dart';
import 'package:muslim_mate/features/quran/data/models/surah_tab_model.dart';
import 'package:muslim_mate/features/quran/domain/repositories/quran_repository.dart';
import 'package:muslim_mate/features/quran/presentation/cubit/surah_detail_cubit.dart';
import 'package:muslim_mate/features/quran/presentation/cubit/surah_detail_state.dart';

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
  final GlobalKey _activeTabKey = GlobalKey();
  late final SurahDetailCubit _surahDetailCubit;

  LastRead? _lastRead;
  int _selectedAyah = 1;
  List<SurahTab> _surahTabs = [];
  bool _loadingTabs = true;

  @override
  void initState() {
    super.initState();
    _surahDetailCubit = SurahDetailCubit(sl<QuranRepository>());
    _tabScrollController.addListener(() {});
    _loadLastRead();
    _loadSurahTabs();
    _surahDetailCubit.loadSurahDetail(widget.surahNumber);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          if (!mounted) return;
          _scrollToActiveTab();
        },
      );
    });
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    _surahDetailCubit.close();
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(
            const Duration(milliseconds: 150),
            () {
              if (!mounted) return;
              _scrollToActiveTab();
            },
          );
      });
    }
  }

  Future<void> _loadSurah(int number) async {
    _surahDetailCubit.loadSurahDetail(number);
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



  void _scrollToActiveTab() {
    if (!mounted) return;
    final currentDetail = _surahDetailCubit.state.surahDetail;
    if (_surahTabs.isEmpty || currentDetail == null) {
      return;
    }

    if (!_tabScrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(
          const Duration(milliseconds: 100),
          () {
            if (!mounted) return;
            _scrollToActiveTab();
          },
        );
      });
      return;
    }

    final keyContext = _activeTabKey.currentContext;
    if (keyContext == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 100), _scrollToActiveTab);
      });
      return;
    }

    final box = keyContext.findRenderObject();
    if (box is! RenderBox) {
      return;
    }

    final tabPosition = box.localToGlobal(Offset.zero);
    final tabWidth = box.size.width;
    final screenWidth = MediaQuery.of(context).size.width;
    final currentScrollOffset = _tabScrollController.offset;
    final tabCenterOnScreen = tabPosition.dx + tabWidth / 2;
    final screenCenter = screenWidth / 2;
    final targetOffset = currentScrollOffset + tabCenterOnScreen - screenCenter;

    _tabScrollController.jumpTo(
      targetOffset.clamp(0.0, _tabScrollController.position.maxScrollExtent),
    );
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

  String _selectedLocation(SurahDetail detail) {
    final place = detail.tempatTurun.toLowerCase();
    return place.startsWith('mek') ? 'Mekkah' : 'Madinah';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SurahDetailCubit>.value(
      value: _surahDetailCubit,
      child: BlocListener<SurahDetailCubit, SurahDetailState>(
        listener: (context, state) {
          if (!mounted) return;
          final detail = state.surahDetail;
          if (detail == null) return;

          setState(() {
            _selectedAyah = detail.ayat.isNotEmpty
                ? detail.ayat.first.nomorAyat
                : 1;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(milliseconds: 150), _scrollToActiveTab);
          });
        },
        child: BlocBuilder<SurahDetailCubit, SurahDetailState>(
          builder: (context, state) {
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
                toolbarHeight: 64,
                centerTitle: false,
                leading: IconButton(
                  icon: const Icon(Iconsax.arrow_left, color: _kTextSecondary),
                  onPressed: Navigator.of(context).pop,
                ),
                titleSpacing: 0,
                title: _buildAppBarSearchField(),
                actions: [
                  _buildAppBarIcon(Iconsax.setting_4, onTap: () {}, bordered: false),
                  const SizedBox(width: 2),
                  _buildAppBarIcon(Iconsax.setting_2, onTap: () {}, bordered: false),
                  const SizedBox(width: 8),
                ],
              ),
              body: SafeArea(
                child: state.loading
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: _buildLoading(),
                      )
                    : state.errorMessage != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: _buildError(state.errorMessage),
                          )
                        : _buildContent(state.surahDetail!),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildAppBarIcon(IconData icon,
      {required VoidCallback onTap, bool bordered = true}) {
    return InkWell(
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
    );
  }

  Widget _buildAppBarSearchField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Iconsax.search_normal, color: _kTextSecondary, size: 20),
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

  Widget _buildContent(SurahDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSurahTabs(),
        _buildInfoBar(detail),
        Expanded(child: _buildAyahList(detail)),
      ],
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

    // Display tabs in reversed order (right-to-left)
    final displayTabs = _surahTabs.reversed.toList();
    return Container(
      child: SizedBox(
        height: 52,
        child: ListView.separated(
          controller: _tabScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: displayTabs.length,
          separatorBuilder: (context, _) => const SizedBox(width: 24),
          itemBuilder: (context, index) {
            final tab = displayTabs[index];
            final active = tab.nomor == _surahDetailCubit.state.surahDetail?.nomor;
            return GestureDetector(
              key: active ? _activeTabKey : null,
              onTap: () => _loadSurah(tab.nomor),
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    if (active)
                      Container(height: 2, color: _kAccent)
                    else
                      const SizedBox(height: 2),
                  ],
                ),
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
        color: Color(0xFFF4F7FB),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Center(
        child: Text(
          'Juz ${detail.juzNumber}  |  $englishTitle (${detail.jumlahAyat} Ayah)  |  ${_selectedLocation(detail)}',
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
      padding: const EdgeInsets.only(top: 0, bottom: 32),
      physics: const BouncingScrollPhysics(),
      itemCount: detail.ayat.length,
      separatorBuilder: (context, _) =>
          const Divider(color: Color(0xFFE5E7EB), height: 1),
      itemBuilder: (context, index) {
        final ayah = detail.ayat[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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

  Widget _buildError(String? errorMessage) {
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
            errorMessage ?? 'Please try again.',
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
