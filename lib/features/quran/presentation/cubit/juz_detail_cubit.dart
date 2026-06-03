import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslim_mate/features/quran/domain/repositories/quran_repository.dart';
import 'package:muslim_mate/features/quran/presentation/cubit/juz_detail_state.dart';

class JuzDetailCubit extends Cubit<JuzDetailState> {
  final QuranRepository repository;

  JuzDetailCubit(this.repository) : super(JuzDetailState.initial());

  Future<void> loadJuzDetail(int juzNumber) async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      final surahs = await repository.fetchJuzDetail(juzNumber);
      emit(state.copyWith(loading: false, surahs: surahs));
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }
}
