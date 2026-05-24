class PrayerTiming {
  PrayerTiming({
    required this.name,
    required this.displayTime,
    required this.dateTime,
  });

  final String name;
  final String displayTime;
  final DateTime dateTime;

  PrayerTiming copyWith({
    String? name,
    String? displayTime,
    DateTime? dateTime,
  }) {
    return PrayerTiming(
      name: name ?? this.name,
      displayTime: displayTime ?? this.displayTime,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}
