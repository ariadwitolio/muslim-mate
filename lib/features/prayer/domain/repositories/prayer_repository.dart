import 'package:muslim_mate/features/prayer/domain/entities/prayer_timing.dart';

class PrayerResponse {
  PrayerResponse({
    required this.prayerTimings,
    this.hijriDate,
  });

  final List<PrayerTiming> prayerTimings;
  final String? hijriDate;
}

abstract class PrayerRepository {
  Future<PrayerResponse> fetchPrayerTimes(
    double latitude,
    double longitude,
    DateTime date,
  );
}
