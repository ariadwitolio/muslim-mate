import 'package:flutter/foundation.dart';
import 'package:muslim_mate/features/dzikir/domain/entities/almatsurat_item.dart';

@immutable
class DzikirState {
  final List<AlMatsuratItem> items;
  final int selectedTabIndex;
  final int selectedVariantIndex;

  const DzikirState({
    required this.items,
    required this.selectedTabIndex,
    required this.selectedVariantIndex,
  });

  factory DzikirState.initial({required int selectedTabIndex}) {
    return DzikirState(
      items: const [],
      selectedTabIndex: selectedTabIndex,
      selectedVariantIndex: 0,
    );
  }

  List<AlMatsuratItem> get currentItems {
    final category = selectedTabIndex == 0
        ? AlMatsuratItem.categoryMorning
        : AlMatsuratItem.categoryEvening;
    final variant = selectedVariantIndex == 0
        ? AlMatsuratItem.variantSughro
        : AlMatsuratItem.variantKubro;
    return items
        .where((item) =>
            item.category == category && item.variant == variant)
        .toList();
  }

  DzikirState copyWith({
    List<AlMatsuratItem>? items,
    int? selectedTabIndex,
    int? selectedVariantIndex,
  }) {
    return DzikirState(
      items: items ?? this.items,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      selectedVariantIndex:
          selectedVariantIndex ?? this.selectedVariantIndex,
    );
  }
}
