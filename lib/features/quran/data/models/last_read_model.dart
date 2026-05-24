import 'package:flutter/foundation.dart';

@immutable
class LastRead {
  final int surahNumber;
  final String surahName;
  final int ayat;

  const LastRead({
    required this.surahNumber,
    required this.surahName,
    required this.ayat,
  });

  Map<String, dynamic> toJson() {
    return {'surahNumber': surahNumber, 'surahName': surahName, 'ayat': ayat};
  }

  factory LastRead.fromJson(Map<String, dynamic> json) {
    return LastRead(
      surahNumber: json['surahNumber'] as int? ?? 0,
      surahName: json['surahName'] as String? ?? '',
      ayat: json['ayat'] as int? ?? 1,
    );
  }
}
