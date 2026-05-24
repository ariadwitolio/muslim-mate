import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:muslim_mate/features/prayer/data/sources/location_data_source.dart';

import 'qibla_state.dart';

class QiblaCubit extends Cubit<QiblaState> {
  QiblaCubit(this._locationDataSource) : super(QiblaState.initial()) {
    _listenCompass();
    _loadLocationAndQibla();
  }

  final LocationDataSource _locationDataSource;
  StreamSubscription<CompassEvent>? _compassSubscription;

  void _safeEmit(QiblaState nextState) {
    if (!isClosed) {
      emit(nextState);
    }
  }

  void _listenCompass() {
    _compassSubscription = FlutterCompass.events?.listen(
      (event) {
        final heading = event.heading;
        if (heading != null) {
          _safeEmit(state.copyWith(deviceHeading: heading));
        }
      },
      onError: (_) {},
    );
  }

  Future<void> loadLocationAndQibla() async {
    await _loadLocationAndQibla();
  }

  Future<void> _loadLocationAndQibla() async {
    if (isClosed) return;

    _safeEmit(state.copyWith(
      loading: true,
      permissionDenied: false,
      serviceDisabled: false,
      errorMessage: null,
      locationLine1: 'Fetching location…',
      locationLine2: '',
    ));

    try {
      final position = await _locationDataSource.determinePosition();
      if (isClosed) return;

      final bearing = _calculateQiblaBearing(position.latitude, position.longitude);
      final locationLabel = await _locationDataSource.getLocationLabel(position);
      if (isClosed) return;

      _safeEmit(state.copyWith(
        loading: false,
        qiblaBearing: bearing,
        locationLine1: locationLabel,
        locationLine2: 'Using current device position',
      ));
    } catch (error) {
      if (isClosed) return;

      final errMsg = error.toString();
      _safeEmit(state.copyWith(
        loading: false,
        permissionDenied: errMsg.toLowerCase().contains('denied'),
        serviceDisabled: errMsg.toLowerCase().contains('disabled'),
        errorMessage: errMsg,
        locationLine1: 'Location unavailable',
        locationLine2: 'Check your settings and retry.',
      ));
    }
  }

  double _calculateQiblaBearing(double latitude, double longitude) {
    const kaabaLatitude = 21.422487;
    const kaabaLongitude = 39.826206;
    final latRadians = _degreesToRadians(latitude);
    final lonRadians = _degreesToRadians(longitude);
    final kaabaLatRadians = _degreesToRadians(kaabaLatitude);
    final kaabaLonRadians = _degreesToRadians(kaabaLongitude);

    final y = sin(kaabaLonRadians - lonRadians) * cos(kaabaLatRadians);
    final x = cos(latRadians) * sin(kaabaLatRadians) -
        sin(latRadians) * cos(kaabaLatRadians) * cos(kaabaLonRadians - lonRadians);

    final bearing = atan2(y, x);
    return (_radiansToDegrees(bearing) + 360) % 360;
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;

  double _radiansToDegrees(double radians) => radians * 180 / pi;

  @override
  Future<void> close() {
    _compassSubscription?.cancel();
    return super.close();
  }
}
