import 'package:flutter/foundation.dart';
import 'package:muslim_mate/features/quran/data/models/last_read_model.dart';
import 'package:muslim_mate/features/quran/data/models/surah_model.dart';

@immutable
class QuranState {
  final List<Surah> surahs;
  final bool loading;
  final String? errorMessage;
  final int selectedTabIndex;
  final String searchQuery;
  final LastRead? lastRead;

  const QuranState({
    required this.surahs,
    required this.loading,
    required this.errorMessage,
    required this.selectedTabIndex,
    required this.searchQuery,
    required this.lastRead,
  });

  factory QuranState.initial() {
    return const QuranState(
      surahs: [],
      loading: true,
      errorMessage: null,
      selectedTabIndex: 0,
      searchQuery: '',
      lastRead: null,
    );
  }

  QuranState copyWith({
    List<Surah>? surahs,
    bool? loading,
    String? errorMessage,
    int? selectedTabIndex,
    String? searchQuery,
    LastRead? lastRead,
  }) {
    return QuranState(
      surahs: surahs ?? this.surahs,
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      lastRead: lastRead ?? this.lastRead,
    );
  }

  List<Surah> get filteredSurahs {
    if (searchQuery.isEmpty) {
      return surahs;
    }

    final query = searchQuery.trim().toLowerCase();
    return surahs.where((surah) {
      final matchesName = surah.namaLatin.toLowerCase().contains(query);
      final matchesNumber = surah.nomor.toString().contains(query);
      return matchesName || matchesNumber;
    }).toList();
  }
}
