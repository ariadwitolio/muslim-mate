import 'package:flutter/foundation.dart';

@immutable
class Ayah {
  final int nomorAyat;
  final String teksArab;
  final String teksLatin;
  final String teksEnglish;
  final int? juzNumber;

  const Ayah({
    required this.nomorAyat,
    required this.teksArab,
    required this.teksLatin,
    required this.teksEnglish,
    this.juzNumber,
  });

  Ayah copyWith({String? teksEnglish, int? juzNumber}) {
    return Ayah(
      nomorAyat: nomorAyat,
      teksArab: teksArab,
      teksLatin: teksLatin,
      teksEnglish: teksEnglish ?? this.teksEnglish,
      juzNumber: juzNumber ?? this.juzNumber,
    );
  }

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      nomorAyat: json['nomorAyat'] as int? ?? 0,
      teksArab: json['teksArab'] as String? ?? '',
      teksLatin: json['teksLatin'] as String? ?? '',
      teksEnglish: '',
      juzNumber: null,
    );
  }
}
