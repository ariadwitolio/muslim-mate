import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:muslim_mate/core/services/injection.dart';
import 'package:muslim_mate/features/quran/data/models/surah_detail_model.dart';
import 'package:muslim_mate/features/quran/domain/repositories/quran_repository.dart';
import 'package:muslim_mate/features/quran/presentation/cubit/juz_detail_cubit.dart';
import 'package:muslim_mate/features/quran/presentation/cubit/juz_detail_state.dart';
import 'package:muslim_mate/features/quran/presentation/pages/surah_detail_page.dart';

const Color _kSurface = Color(0xFFFFFFFF);
const Color _kBorder = Color(0xFFE6EBF1);
const Color _kTextPrimary = Color(0xFF111827);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kAccent = Color(0xFF0F8D93);

class JuzDetailScreen extends StatefulWidget {
  final int juzNumber;

  const JuzDetailScreen({
    required this.juzNumber,
    super.key,
  });

  @override
  State<JuzDetailScreen> createState() => _JuzDetailScreenState();
}

class _JuzDetailScreenState extends State<JuzDetailScreen> {
  final ScrollController _tabScrollController = ScrollController();
  final GlobalKey _activeTabKey = GlobalKey();
  late final JuzDetailCubit _juzDetailCubit;
  
  late int _currentJuzNumber;

  @override
  void initState() {
    super.initState();
    _currentJuzNumber = widget.juzNumber;
    _juzDetailCubit = JuzDetailCubit(sl<QuranRepository>());
    _tabScrollController.addListener(() {});
    
    _loadJuz(_currentJuzNumber);
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    _juzDetailCubit.close();
    super.dispose();
  }

  Future<void> _loadJuz(int number) async {
    setState(() {
      _currentJuzNumber = number;
    });
    _juzDetailCubit.loadJuzDetail(number);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        _scrollToActiveTab();
      });
    });
  }

  void _scrollToActiveTab() {
    if (!mounted) return;

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

    _tabScrollController.animateTo(
      targetOffset.clamp(0.0, _tabScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
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
    return BlocProvider<JuzDetailCubit>.value(
      value: _juzDetailCubit,
      child: Scaffold(
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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: _buildJuzTabs(),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<JuzDetailCubit, JuzDetailState>(
            builder: (context, state) {
              if (state.loading) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _buildLoading(),
                );
              }
              if (state.errorMessage != null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _buildError(state.errorMessage),
                );
              }
              return _buildContent(state.surahs);
            },
          ),
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

  Widget _buildContent(List<SurahDetail> surahs) {
    if (surahs.isEmpty) return const SizedBox.shrink();
    
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        for (final surah in surahs)
          SliverMainAxisGroup(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickySurahHeaderDelegate(
                  child: _buildInfoBar(surah),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildAyahList(surah),
              ),
            ],
          ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  Widget _buildJuzTabs() {
    // Generate Juz 30 down to 1
    final displayTabs = List.generate(30, (index) => 30 - index);

    return Container(
      color: _kSurface,
      child: SizedBox(
        height: 52,
        child: SingleChildScrollView(
          controller: _tabScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(displayTabs.length, (index) {
              final juzNumber = displayTabs[index];
              final active = juzNumber == _currentJuzNumber;
              return Padding(
                padding: EdgeInsets.only(right: index == displayTabs.length - 1 ? 0 : 24),
                child: GestureDetector(
                  key: active ? _activeTabKey : null,
                  onTap: () => _loadJuz(juzNumber),
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Juz $juzNumber',
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
                ),
              );
            }),
          ),
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
          '${detail.namaLatin}  |  $englishTitle (${detail.jumlahAyat} Ayah)  |  ${_selectedLocation(detail)}',
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
      padding: EdgeInsets.zero, // Padding is handled by the parent ListView
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
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
            'Unable to load the Juz',
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
            onPressed: () => _loadJuz(_currentJuzNumber),
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

class _StickySurahHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickySurahHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 44.0;

  @override
  double get minExtent => 44.0;

  @override
  bool shouldRebuild(covariant _StickySurahHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
