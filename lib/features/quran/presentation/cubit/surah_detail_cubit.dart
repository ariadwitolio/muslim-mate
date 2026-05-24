import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslim_mate/features/quran/domain/repositories/quran_repository.dart';
import 'package:muslim_mate/features/quran/presentation/cubit/surah_detail_state.dart';

class SurahDetailCubit extends Cubit<SurahDetailState> {
  final QuranRepository repository;

  SurahDetailCubit(this.repository) : super(SurahDetailState.initial());

  Future<void> loadSurahDetail(int number) async {
    emit(state.copyWith(
      loading: true,
      errorMessage: null,
      surahDetail: null,
    ));

    try {
      final surahDetail = await repository.fetchSurahDetail(number);
      if (isClosed) return;
      emit(state.copyWith(
        loading: false,
        surahDetail: surahDetail,
      ));
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(
        loading: false,
        errorMessage: error.toString(),
      ));
    }
  }
}
