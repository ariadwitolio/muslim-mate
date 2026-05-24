import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:muslim_mate/constants/index.dart';
import 'package:muslim_mate/features/quran/data/models/surah_model.dart';
import 'package:muslim_mate/features/quran/presentation/cubit/quran_cubit.dart';
import 'package:muslim_mate/features/quran/presentation/cubit/quran_state.dart';
import 'package:muslim_mate/features/quran/presentation/pages/surah_detail_page.dart';

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

  final TextEditingController _searchController = TextEditingController();
  final List<JuzItem> _juzItems = List.generate(
    30,
    (index) => JuzItem(
      number: index + 1,
      startSurah: 'Al-Fatihah',
      startAyat: 'Ayat 1',
    ),
  );

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<QuranCubit>().setSearchQuery(_searchController.text);
  }


  Future<void> _openSurahDetail(BuildContext callerContext, QuranCubit cubit, Surah surah) async {
    // Save last-read before navigation using the captured cubit
    try {
      await cubit.saveLastRead(surah);
    } catch (_) {
      // ignore save errors
    }

    // Ensure widget tree still mounted before navigating
    if (!callerContext.mounted) return;

    await Navigator.of(callerContext).push(
      MaterialPageRoute(
        builder: (_) => SurahDetailScreen(
          surahNumber: surah.nomor,
          surahName: surah.namaLatin,
        ),
      ),
    );

    if (!callerContext.mounted) return;
    await cubit.loadLastRead();
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
        Expanded(child: _buildSearchBar()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuranCubit>(
      create: (_) => QuranCubit(),
      child: BlocBuilder<QuranCubit, QuranState>(
        builder: (context, state) {
          final QuranCubit cubit = context.read<QuranCubit>();
          return Scaffold(
            extendBodyBehindAppBar: false,
            backgroundColor: _kBackground,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: _kBackground,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              scrolledUnderElevation: 0,
              toolbarOpacity: 1.0,
              centerTitle: false,
              titleSpacing: 20,
              toolbarHeight: 60,
              title: Text(
                'Al Quran',
                style: _jakarta(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary,
                ),
              ),
              titleTextStyle: _jakarta(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary,
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: Column(
                  children: [
                    _buildSearchRow(),
                    const SizedBox(height: 8),
                    _buildTabBar(state),
                    const SizedBox(height: 10),
                    Expanded(child: _buildTabContent(state, cubit)),
                  ],
                ),
              ),
            ),
          );
        },
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
          const Icon(Iconsax.search_normal, size: 20, color: _kTextSecondary),
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

  Widget _buildTabBar(QuranState state) {
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
          Expanded(child: _buildTabItem('Surah', 0, state: state)),
          const SizedBox(width: 8),
          Expanded(child: _buildTabItem('Juz', 1, state: state)),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabItem('Last Read', 2, icon: Iconsax.clock, state: state),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index, {IconData? icon, required QuranState state}) {
    final selected = state.selectedTabIndex == index;
    return GestureDetector(
      onTap: () => context.read<QuranCubit>().setSelectedTab(index),
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

  Widget _buildTabContent(QuranState state, QuranCubit cubit) {
    switch (state.selectedTabIndex) {
      case 1:
        return _buildJuzList();
      case 2:
        return _buildLastReadTab(state);
      default:
        return _buildSurahTab(state, cubit);
    }
  }

  Widget _buildSurahTab(QuranState state, QuranCubit cubit) {
    if (state.loading) {
      return _buildSurahListLoading();
    }

    if (state.errorMessage != null) {
      return _buildSurahListError(state);
    }

    final filtered = state.filteredSurahs;
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
            onTap: () => _openSurahDetail(context, cubit, surah),
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

  Widget _buildSurahListError(QuranState state) {
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
            state.errorMessage ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: _jakarta(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: _kTextSecondary,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () => context.read<QuranCubit>().fetchSurahs(),
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
                Iconsax.arrow_right_3,
                size: 16,
                color: _kTextSecondary,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLastReadTab(QuranState state) {
    if (state.lastRead == null) {
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
              '${state.lastRead!.surahName} • Ayat ${state.lastRead!.ayat}',
              style: _jakarta(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Surah ${state.lastRead!.surahNumber}',
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
