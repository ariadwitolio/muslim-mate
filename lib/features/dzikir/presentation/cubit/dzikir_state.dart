import 'package:flutter/foundation.dart';
import 'package:muslim_mate/features/dzikir/domain/entities/almatsurat_item.dart';

@immutable
class DzikirState {
  final List<AlMatsuratItem> items;
  final int selectedTabIndex;

  const DzikirState({
    required this.items,
    required this.selectedTabIndex,
  });

  factory DzikirState.initial({required int selectedTabIndex}) {
    return DzikirState(
      items: const [],
      selectedTabIndex: selectedTabIndex,
    );
  }

  List<AlMatsuratItem> get currentItems {
    final category = selectedTabIndex == 0 ? 'morning' : 'evening';
    return items.where((item) => item.category == category).toList();
  }

  DzikirState copyWith({
    List<AlMatsuratItem>? items,
    int? selectedTabIndex,
  }) {
    return DzikirState(
      items: items ?? this.items,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }
}
