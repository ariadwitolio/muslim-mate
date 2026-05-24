import 'package:flutter/foundation.dart';

@immutable
class SpecialSurahNavigation {
  final int nomor;
  final String namaLatin;

  const SpecialSurahNavigation({
    required this.nomor,
    required this.namaLatin,
  });

  factory SpecialSurahNavigation.fromJson(Map<String, dynamic> json) {
    return SpecialSurahNavigation(
      nomor: json['nomor'] as int? ?? 0,
      namaLatin: json['namaLatin'] as String? ?? '',
    );
  }
}
