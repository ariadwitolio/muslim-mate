import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_mate/core/services/injection.dart';
import 'package:muslim_mate/features/dzikir/domain/entities/almatsurat_item.dart';
import 'package:muslim_mate/features/dzikir/domain/repositories/dzikir_repository.dart';
import 'package:muslim_mate/features/dzikir/presentation/cubit/dzikir_cubit.dart';
import 'package:muslim_mate/features/dzikir/presentation/cubit/dzikir_state.dart';

const Color _kBackground = Color(0xFFFFFFFF);
const Color _kSectionBackground = Color(0xFFF4F7FB);
const Color _kBorder = Color(0xFFE6EBF1);
const Color _kTextPrimary = Color(0xFF111827);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kTabSelected = Color(0xFF0F8D93);
const Color _kDivider = Color(0xFFF1F5F9);

class AlMatsuratScreen extends StatefulWidget {
  const AlMatsuratScreen({super.key});

  @override
  State<AlMatsuratScreen> createState() => _AlMatsuratScreenState();
}

class _AlMatsuratScreenState extends State<AlMatsuratScreen> {
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
          child: BlocBuilder<DzikirCubit, DzikirState>(
            builder: (context, state) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                    child: _buildTabBar(state.selectedTabIndex, context),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
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

  Widget _buildTabBar(int selectedTabIndex, BuildContext context) {
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
          Expanded(
            child: _buildTabItem('Morning', 0, selectedTabIndex == 0, context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabItem('Evening', 1, selectedTabIndex == 1, context),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(
    String label,
    int index,
    bool selected,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => context.read<DzikirCubit>().selectTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        decoration: BoxDecoration(
          color: selected ? _kTabSelected : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
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

  Widget _buildItemContent(AlMatsuratItem item) {
    // Skip rendering jeda items (empty content)
    if (item.arabic.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            item.title,
            style: _jakarta(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _kTextSecondary,
            ),
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
        // Repeat count
        Text(
          'Read ${item.repeat}x',
          textAlign: TextAlign.left,
          style: _jakarta(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _kTabSelected,
          ),
        ),
      ],
    );
  }
}
