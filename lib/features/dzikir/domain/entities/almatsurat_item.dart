class AlMatsuratItem {
  static const String categoryMorning = 'morning';
  static const String categoryEvening = 'evening';
  static const String variantSughro = 'sughro';
  static const String variantKubro = 'kubro';

  final int id;
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final int repeat;
  final String category;
  final String variant;

  const AlMatsuratItem({
    required this.id,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.repeat,
    required this.category,
    required this.variant,
  });
}
