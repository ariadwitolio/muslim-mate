import 'package:flutter/foundation.dart';
import 'package:muslim_mate/features/quran/data/models/surah_detail_model.dart';

@immutable
class JuzDetailState {
  final bool loading;
  final String? errorMessage;
  final List<SurahDetail> surahs;

  const JuzDetailState({
    required this.loading,
    this.errorMessage,
    required this.surahs,
  });

  factory JuzDetailState.initial() {
    return const JuzDetailState(
      loading: true,
      surahs: [],
    );
  }

  JuzDetailState copyWith({
    bool? loading,
    String? errorMessage,
    List<SurahDetail>? surahs,
  }) {
    return JuzDetailState(
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
      surahs: surahs ?? this.surahs,
    );
  }
}
