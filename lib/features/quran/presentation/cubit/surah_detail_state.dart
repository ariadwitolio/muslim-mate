import 'package:flutter/foundation.dart';
import 'package:muslim_mate/features/quran/data/models/surah_detail_model.dart';

@immutable
class SurahDetailState {
  final bool loading;
  final String? errorMessage;
  final SurahDetail? surahDetail;

  const SurahDetailState({
    required this.loading,
    this.errorMessage,
    this.surahDetail,
  });

  factory SurahDetailState.initial() {
    return const SurahDetailState(
      loading: true,
      errorMessage: null,
      surahDetail: null,
    );
  }

  SurahDetailState copyWith({
    bool? loading,
    Object? errorMessage = _undefined,
    SurahDetail? surahDetail,
  }) {
    return SurahDetailState(
      loading: loading ?? this.loading,
      errorMessage: errorMessage == _undefined ? this.errorMessage : errorMessage as String?,
      surahDetail: surahDetail ?? this.surahDetail,
    );
  }
}

const Object _undefined = Object();
