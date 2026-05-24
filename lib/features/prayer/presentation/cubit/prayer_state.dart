import 'package:muslim_mate/features/prayer/domain/entities/prayer_timing.dart';

class PrayerState {
  PrayerState({
    required this.loading,
    required this.errorMessage,
    required this.locationLabel,
    required this.hijriDate,
    required this.prayerTimings,
    required this.cachedDate,
  });

  final bool loading;
  final String? errorMessage;
  final String locationLabel;
  final String hijriDate;
  final List<PrayerTiming> prayerTimings;
  final DateTime? cachedDate;

  bool get hasData => prayerTimings.isNotEmpty;

  PrayerState copyWith({
    bool? loading,
    String? errorMessage,
    String? locationLabel,
    String? hijriDate,
    List<PrayerTiming>? prayerTimings,
    DateTime? cachedDate,
  }) {
    return PrayerState(
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
      locationLabel: locationLabel ?? this.locationLabel,
      hijriDate: hijriDate ?? this.hijriDate,
      prayerTimings: prayerTimings ?? this.prayerTimings,
      cachedDate: cachedDate ?? this.cachedDate,
    );
  }

  factory PrayerState.initial() {
    return PrayerState(
      loading: false,
      errorMessage: null,
      locationLabel: 'Fetching location…',
      hijriDate: '',
      prayerTimings: const [],
      cachedDate: null,
    );
  }
}
