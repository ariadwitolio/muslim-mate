import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_mate/core/services/injection.dart';
import 'package:muslim_mate/features/dzikir/domain/entities/almatsurat_item.dart';
import 'package:muslim_mate/features/dzikir/domain/repositories/dzikir_repository.dart';
import 'package:muslim_mate/features/dzikir/presentation/cubit/dzikir_cubit.dart';
import 'package:muslim_mate/features/dzikir/presentation/cubit/dzikir_state.dart';

const Color _kBackground = Color(0xFFFFFFFF);
const Color _kTextPrimary = Color(0xFF111827);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kTabSelected = Color(0xFF0F8D93);
const Color _kDivider = Color(0xFFF1F5F9);
const List<String> _kCategoryLabels = ['Morning', 'Evening'];
const List<String> _kVariantLabels = ['Sughro', 'Kubro'];

class AlMatsuratScreen extends StatefulWidget {
  const AlMatsuratScreen({super.key});

  @override
  State<AlMatsuratScreen> createState() => _AlMatsuratScreenState();
}

class _AlMatsuratScreenState extends State<AlMatsuratScreen> {
  final ScrollController _listController = ScrollController();
  late int _prevTabIndex;
  late int _prevVariantIndex;

  @override
  void initState() {
    super.initState();
    final cubit = DzikirCubit(sl<DzikirRepository>());
    // initialize previous indices from cubit initial state
    _prevTabIndex = cubit.state.selectedTabIndex;
    _prevVariantIndex = cubit.state.selectedVariantIndex;
    cubit.close();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocProvider<DzikirCubit>(
      create: (_) => DzikirCubit(sl<DzikirRepository>()),
      child: Scaffold(
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
            'Al-Ma\'tsurat',
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
          child: BlocListener<DzikirCubit, DzikirState>(
            listener: (context, state) {
              // when primary tab or variant changes, scroll list to top
              if (state.selectedTabIndex != _prevTabIndex) {
                _listController.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                _prevTabIndex = state.selectedTabIndex;
                // variant is reset in cubit when primary tab changes; update prev
                _prevVariantIndex = state.selectedVariantIndex;
              } else if (state.selectedVariantIndex != _prevVariantIndex) {
                _listController.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                _prevVariantIndex = state.selectedVariantIndex;
              }
            },
            child: BlocBuilder<DzikirCubit, DzikirState>(
              builder: (context, state) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                      child: _buildPrimaryTabBar(state.selectedTabIndex, context),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildVariantTabBar(state.selectedVariantIndex, context),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.separated(
                        controller: _listController,
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                        itemCount: state.currentItems.length,
                        separatorBuilder: (context, index) {
                          final nextItem = state.currentItems[index + 1];
                          if (nextItem.arabic.isEmpty) {
                            return const SizedBox(height: 24);
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Divider(
                              color: _kDivider,
                              thickness: 1,
                              height: 1,
                            ),
                          );
                        },
                        itemBuilder: (context, index) {
                          final item = state.currentItems[index];
                          return _buildItemContent(item);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
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
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.w500,
    Color color = _kTextPrimary,
  }) {
    return GoogleFonts.scheherazadeNew(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.8,
    );
  }

  Widget _buildPrimaryTabBar(int selectedTabIndex, BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF4F7FB)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(_kCategoryLabels.length, (index) {
          final selected = selectedTabIndex == index;
          return Expanded(
            child: _buildPrimaryTabItem(
              label: _kCategoryLabels[index],
              selected: selected,
              onTap: () => context.read<DzikirCubit>().selectTab(index),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPrimaryTabItem({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        decoration: BoxDecoration(
          color: selected ? _kTabSelected : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          label,
          style: _jakarta(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? Colors.white : _kTextSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildVariantTabBar(int selectedVariantIndex, BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: const Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        children: List.generate(_kVariantLabels.length, (index) {
          final selected = selectedVariantIndex == index;
          return Expanded(
            child: _buildVariantTabItem(
              label: _kVariantLabels[index],
              selected: selected,
              onTap: () => context.read<DzikirCubit>().selectVariant(index),
            ),
          );
        }),
      ),
    );
  }

  

  Widget _buildVariantTabItem({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Text(
                label,
                style: _jakarta(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? _kTabSelected : _kTextSecondary,
                ),
              ),
            ),
          ),
          Container(
            height: 2,
            color: selected ? _kTabSelected : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildItemContent(AlMatsuratItem item) {
    // Skip rendering jeda items (empty content)
    if (item.arabic.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title with repeat count inline (e.g. "Ta'awudz (1x)")
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: _jakarta(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _kTextSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${item.repeat}x)',
                style: _jakarta(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _kTabSelected,
                ),
              ),
            ],
          ),
        ),
        // Arabic text - right aligned
        Text(
          item.arabic,
          textAlign: TextAlign.right,
          style: _arabic(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: _kTextPrimary,
          ),
        ),
        const SizedBox(height: 16),
        // Transliteration - left aligned
        Text(
          item.transliteration,
          textAlign: TextAlign.left,
          style: _jakarta(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _kTextSecondary,
          ).copyWith(fontStyle: FontStyle.italic, height: 1.6),
        ),
        const SizedBox(height: 16),
        // Translation - left aligned
        Text(
          item.translation,
          textAlign: TextAlign.left,
          style: _jakarta(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _kTextPrimary,
          ).copyWith(height: 1.6),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
