import 'package:muslim_mate/features/prayer/domain/entities/prayer_timing.dart';

class PrayerTimingModel {
  PrayerTimingModel({
    required this.name,
    required this.displayTime,
    required this.dateTime,
  });

  final String name;
  final String displayTime;
  final DateTime dateTime;

  factory PrayerTimingModel.fromJson(
    String name,
    dynamic rawTime,
    DateTime date,
  ) {
    final timeText = rawTime?.toString() ?? '';
    final cleaned = timeText.replaceAll(RegExp('[^0-9:]'), '');
    final parts = cleaned.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    return PrayerTimingModel(
      name: name,
      displayTime: cleaned,
      dateTime: DateTime(date.year, date.month, date.day, hour, minute),
    );
  }

  PrayerTiming toEntity() {
    return PrayerTiming(
      name: name,
      displayTime: displayTime,
      dateTime: dateTime,
    );
  }
}
