import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:muslim_mate/features/prayer/data/sources/location_data_source.dart';
import 'package:muslim_mate/features/prayer/domain/entities/prayer_timing.dart';
import 'package:muslim_mate/features/prayer/domain/repositories/prayer_repository.dart';
import 'package:muslim_mate/features/prayer/presentation/cubit/prayer_state.dart';

class PrayerCubit extends Cubit<PrayerState> {
  PrayerCubit(
    this._repository,
    this._locationDataSource,
  ) : super(PrayerState.initial());

  final PrayerRepository _repository;
  final LocationDataSource _locationDataSource;

  Future<void> loadPrayerTimes({DateTime? date}) async {
    final now = date ?? DateTime.now();
    if (_isSameDay(now, state.cachedDate) && state.hasData) {
      return;
    }

    emit(state.copyWith(
      loading: true,
      errorMessage: null,
    ));

    try {
      final position = await _locationDataSource.determinePosition();
      final label = await _locationDataSource.getLocationLabel(position);
      final response = await _repository.fetchPrayerTimes(
        position.latitude,
        position.longitude,
        now,
      );

      if (isClosed) return;

      emit(state.copyWith(
        loading: false,
        errorMessage: null,
        locationLabel: label,
        hijriDate: response.hijriDate ?? _formatHijriFromDate(now),
        prayerTimings: response.prayerTimings,
        cachedDate: DateTime(now.year, now.month, now.day),
      ));
    } catch (error) {
      if (isClosed) return;

      final errMsg = error.toString();
      emit(state.copyWith(
        loading: false,
        errorMessage: errMsg,
        hijriDate: _formatHijriFromDate(now),
        prayerTimings: const [],
        locationLabel: errMsg.toLowerCase().contains('denied')
            ? 'Location unavailable'
            : 'Unknown location',
      ));
    }
  }

  PrayerTiming? currentPrayer(DateTime time) {
    return _activePrayerForTime(time, state.prayerTimings);
  }

  PrayerTiming? nextPrayer(DateTime time) {
    for (final timing in state.prayerTimings) {
      if (time.isBefore(timing.dateTime)) {
        return timing;
      }
    }

    if (state.prayerTimings.isNotEmpty) {
      return state.prayerTimings.first.copyWith(
        dateTime: state.prayerTimings.first.dateTime.add(const Duration(days: 1)),
      );
    }

    return null;
  }

  String countdownLabel(DateTime time) {
    final next = nextPrayer(time);
    final current = currentPrayer(time);
    if (next == null) {
      return 'Waiting for prayer times';
    }

    if (current != null && time.isAfter(current.dateTime)) {
      final elapsed = time.difference(current.dateTime);
      if (elapsed <= const Duration(minutes: 1)) {
        return "It's ${current.name} time";
      }
      if (elapsed <= const Duration(minutes: 30)) {
        final minutes = elapsed.inMinutes;
        final minuteLabel = minutes == 1 ? '1 min ago' : '$minutes mins ago';
        return '${current.name} $minuteLabel';
      }
    }

    final remaining = next.dateTime.difference(time);
    if (remaining.isNegative) {
      return '${next.name} in 00:00:00';
    }
    return '${next.name} in ${_formatDuration(remaining)}';
  }

  bool _isSameDay(DateTime current, DateTime? cached) {
    return cached != null && current.year == cached.year && current.month == cached.month && current.day == cached.day;
  }

  PrayerTiming? _activePrayerForTime(DateTime time, List<PrayerTiming> timings) {
    for (var i = 0; i < timings.length; i++) {
      final timing = timings[i];
      final next = i + 1 < timings.length ? timings[i + 1] : null;
      if (!time.isBefore(timing.dateTime) && (next == null || time.isBefore(next.dateTime))) {
        return timing;
      }
    }
    return null;
  }

  String _formatHijriFromDate(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    final monthName = hijri.longMonthName;
    return '${hijri.hDay} $monthName ${hijri.hYear}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final hoursString = hours.toString().padLeft(2, '0');
    final minutesString = minutes.toString().padLeft(2, '0');
    final secondsString = seconds.toString().padLeft(2, '0');
    return '$hoursString:$minutesString:$secondsString';
  }
}
