import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslim_mate/features/dzikir/domain/repositories/dzikir_repository.dart';
import 'dzikir_state.dart';

class DzikirCubit extends Cubit<DzikirState> {
  DzikirCubit(this._repository)
      : super(DzikirState.initial(
          selectedTabIndex: DateTime.now().hour < 12 ? 0 : 1,
        )) {
    _loadAlMatsuratItems();
  }

  final DzikirRepository _repository;

  void _loadAlMatsuratItems() {
    final items = _repository.getAlMatsuratItems();
    emit(state.copyWith(items: items));
  }

  void selectTab(int index) {
    if (state.selectedTabIndex == index) return;
    // switching primary tab resets variant to Sughro (index 0)
    emit(state.copyWith(selectedTabIndex: index, selectedVariantIndex: 0));
  }

  void selectVariant(int index) {
    if (state.selectedVariantIndex == index) return;
    emit(state.copyWith(selectedVariantIndex: index));
  }
}
