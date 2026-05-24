import 'package:muslim_mate/features/prayer/data/models/prayer_timing_model.dart';
import 'package:muslim_mate/features/prayer/domain/repositories/prayer_repository.dart';

class PrayerResponseModel {
  PrayerResponseModel({
    required this.prayerTimings,
    this.hijriDate,
  });

  final List<PrayerTimingModel> prayerTimings;
  final String? hijriDate;

  factory PrayerResponseModel.fromJson(
    Map<String, dynamic> json,
    DateTime date,
  ) {
    final timings = json['timings'] as Map<String, dynamic>?;
    final hijri = json['date'] is Map<String, dynamic>
        ? json['date']['hijri'] as Map<String, dynamic>?
        : null;

    final prayerTimings = <PrayerTimingModel>[];
    if (timings != null) {
      const prayerOrder = ['Imsak', 'Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
      for (final name in prayerOrder) {
        prayerTimings.add(
          PrayerTimingModel.fromJson(name, timings[name], date),
        );
      }
    }

    return PrayerResponseModel(
      prayerTimings: prayerTimings,
      hijriDate: _parseHijriDate(hijri),
    );
  }

  PrayerResponse toEntity() {
    return PrayerResponse(
      prayerTimings: prayerTimings.map((model) => model.toEntity()).toList(),
      hijriDate: hijriDate,
    );
  }
}

String? _parseHijriDate(Map<String, dynamic>? hijri) {
  if (hijri == null) {
    return null;
  }

  final day = hijri['day']?.toString();
  final month = hijri['month'] is Map<String, dynamic>
      ? hijri['month']['en']?.toString()
      : null;
  final year = hijri['year']?.toString();

  if (day != null && month != null && year != null) {
    return '$day $month $year';
  }

  return null;
}
