import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:muslim_mate/core/services/injection.dart';
import 'package:muslim_mate/features/dzikir/domain/entities/almatsurat_item.dart';
import 'package:muslim_mate/features/dzikir/domain/repositories/dzikir_repository.dart';
import 'package:muslim_mate/features/dzikir/presentation/cubit/dzikir_cubit.dart';
import 'package:muslim_mate/features/dzikir/presentation/cubit/dzikir_state.dart';

const Color _kBackground = Color(0xFFF4F7FB);
const Color _kSurface = Color(0xFFFFFFFF);
const Color _kBorder = Color(0xFFE6EBF1);
const Color _kTextPrimary = Color(0xFF111827);
const Color _kTextSecondary = Color(0xFF6B7280);
const Color _kAccent = Color(0xFF0F8D93);
const Color _kSectionBackground = Color(0xFFF1F5F9);

class AlMatsuratScreen extends StatefulWidget {
  const AlMatsuratScreen({super.key});

  @override
  State<AlMatsuratScreen> createState() => _AlMatsuratScreenState();
}

class _AlMatsuratScreenState extends State<AlMatsuratScreen> {
  final Set<String> _expandedItemKeys = {};

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DzikirCubit>(
      create: (_) => DzikirCubit(sl<DzikirRepository>()),
      child: Scaffold(
        backgroundColor: _kBackground,
        appBar: AppBar(
          backgroundColor: _kSurface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: Text(
            'Al-Ma\'tsurat',
            style: _jakarta(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<DzikirCubit, DzikirState>(
            builder: (context, state) {
              return Column(
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildTabBar(state.selectedTabIndex, context),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.currentItems.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = state.currentItems[index];
                        final expanded = _expandedItemKeys.contains('${item.category}-${item.id}');
                        return _buildItemCard(item, expanded);
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
      height: 1.4,
    );
  }

  void _toggleExpanded(AlMatsuratItem item) {
    final key = '${item.category}-${item.id}';
    setState(() {
      if (_expandedItemKeys.contains(key)) {
        _expandedItemKeys.remove(key);
      } else {
        _expandedItemKeys.add(key);
      }
    });
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
          Expanded(child: _buildTabItem('Morning', 0, selectedTabIndex == 0, context)),
          const SizedBox(width: 8),
          Expanded(child: _buildTabItem('Evening', 1, selectedTabIndex == 1, context)),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index, bool selected, BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<DzikirCubit>().selectTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        decoration: BoxDecoration(
          color: selected ? _kAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _kAccent : _kBorder),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: _jakarta(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? Colors.white : _kTextSecondary,
          ),
        ),
      ),
    );
  }
  Widget _buildItemCard(AlMatsuratItem item, bool expanded) {
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _toggleExpanded(item),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  _HexagonBadge(number: item.id),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title,
                      style: _jakarta(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _kAccent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${item.repeat}x',
                      style: _jakarta(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _kAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    expanded ? Iconsax.arrow_up_1 : Iconsax.arrow_down_1,
                    color: _kAccent,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(color: _kBorder),
                  Text(
                    item.arabic,
                    textAlign: TextAlign.right,
                    style: _arabic(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.transliteration,
                    style: _jakarta(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _kTextSecondary,
                    ).copyWith(fontStyle: FontStyle.italic, height: 1.6),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.translation,
                    style: _jakarta(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _kTextPrimary,
                    ).copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Read ${item.repeat}x',
                    style: _jakarta(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _kAccent,
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _HexagonBadge extends StatelessWidget {
  const _HexagonBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HexagonClipper(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _kSurface,
          border: Border.all(color: _kAccent, width: 1.8),
        ),
        child: Center(
          child: Text(
            '$number',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _kAccent,
            ),
          ),
        ),
      ),
    );
  }
}

class _HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    return Path()
      ..moveTo(width * 0.25, 0)
      ..lineTo(width * 0.75, 0)
      ..lineTo(width, height * 0.5)
      ..lineTo(width * 0.75, height)
      ..lineTo(width * 0.25, height)
      ..lineTo(0, height * 0.5)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
