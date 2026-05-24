import 'package:flutter/foundation.dart';

import 'ayah_model.dart';
import 'special_surah_navigation_model.dart';

@immutable
class SurahDetail {
  final int nomor;
  final String nama;
  final String namaLatin;
  final String arti;
  final int jumlahAyat;
  final String tempatTurun;
  final List<Ayah> ayat;
  final SpecialSurahNavigation? suratSebelumnya;
  final SpecialSurahNavigation? suratSelanjutnya;
  final int juzNumber;

  const SurahDetail({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.arti,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.ayat,
    required this.suratSebelumnya,
    required this.suratSelanjutnya,
    required this.juzNumber,
  });

  SurahDetail copyWith({List<Ayah>? ayat, int? juzNumber}) {
    return SurahDetail(
      nomor: nomor,
      nama: nama,
      namaLatin: namaLatin,
      arti: arti,
      jumlahAyat: jumlahAyat,
      tempatTurun: tempatTurun,
      ayat: ayat ?? this.ayat,
      suratSebelumnya: suratSebelumnya,
      suratSelanjutnya: suratSelanjutnya,
      juzNumber: juzNumber ?? this.juzNumber,
    );
  }

  factory SurahDetail.fromJson(Map<String, dynamic> json) {
    return SurahDetail(
      nomor: json['nomor'] as int? ?? 0,
      nama: json['nama'] as String? ?? '',
      namaLatin: json['namaLatin'] as String? ?? '',
      arti: json['arti'] as String? ?? '',
      jumlahAyat: json['jumlahAyat'] as int? ?? 0,
      tempatTurun: json['tempatTurun'] as String? ?? '',
      ayat: (json['ayat'] as List<dynamic>?)
              ?.map((item) => Ayah.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      suratSebelumnya: json['suratSebelumnya'] is Map<String, dynamic>
          ? SpecialSurahNavigation.fromJson(
              json['suratSebelumnya'] as Map<String, dynamic>,
            )
          : null,
      suratSelanjutnya: json['suratSelanjutnya'] is Map<String, dynamic>
          ? SpecialSurahNavigation.fromJson(
              json['suratSelanjutnya'] as Map<String, dynamic>,
            )
          : null,
      juzNumber: 1,
    );
  }
}
