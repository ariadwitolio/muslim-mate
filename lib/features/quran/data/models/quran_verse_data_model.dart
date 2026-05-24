import 'package:flutter/foundation.dart';

@immutable
class QuranVerseData {
  final Map<int, String> translations;
  final Map<int, int> juzNumbers;

  const QuranVerseData({
    required this.translations,
    required this.juzNumbers,
  });
}
