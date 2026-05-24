import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_mate/features/quran/data/models/last_read_model.dart';
import 'package:muslim_mate/features/quran/data/models/surah_model.dart';
import 'package:muslim_mate/features/quran/presentation/cubit/quran_state.dart';

class QuranCubit extends Cubit<QuranState> {
  QuranCubit() : super(QuranState.initial()) {
    _init();
  }

  Future<void> _init() async {
    await Future.wait([fetchSurahs(), loadLastRead()]);
  }

  Future<void> fetchSurahs() async {
    emit(state.copyWith(loading: true, errorMessage: null));

    try {
      final uri = Uri.parse('https://equran.id/api/v2/surat');
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw Exception('Failed to load surah list.');
      }
      final data = json.decode(response.body) as Map<String, dynamic>?;
      final surahData = data?['data'] as List<dynamic>?;
      if (surahData == null) {
        throw Exception('Invalid surah response.');
      }

      final surahs = surahData
          .map((item) => Surah.fromJson(item as Map<String, dynamic>))
          .toList();
      emit(state.copyWith(surahs: surahs, loading: false));
    } catch (error) {
      emit(state.copyWith(
        loading: false,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('last_read');
    if (raw == null) {
      emit(state.copyWith(lastRead: null));
      return;
    }

    try {
      final data = json.decode(raw) as Map<String, dynamic>?;
      if (data == null) {
        emit(state.copyWith(lastRead: null));
        return;
      }
      emit(state.copyWith(lastRead: LastRead.fromJson(data)));
    } catch (_) {
      emit(state.copyWith(lastRead: null));
    }
  }

  Future<void> saveLastRead(Surah surah, {int ayat = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final lastRead = LastRead(
      surahNumber: surah.nomor,
      surahName: surah.namaLatin,
      ayat: ayat,
    );
    await prefs.setString('last_read', json.encode(lastRead.toJson()));
    emit(state.copyWith(lastRead: lastRead));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setSelectedTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }
}
