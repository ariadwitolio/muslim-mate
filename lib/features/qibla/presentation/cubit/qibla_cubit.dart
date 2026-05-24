import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'qibla_state.dart';

class QiblaCubit extends Cubit<QiblaState> {
  QiblaCubit() : super(QiblaState.initial()) {
    _listenCompass();
    _loadLocationAndQibla();
  }

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
      final permissionGranted = await _requestLocationPermission();
      if (isClosed) return;

      if (!permissionGranted) {
        _safeEmit(state.copyWith(
          loading: false,
          permissionDenied: true,
          errorMessage: 'Location permission is required to use the compass.',
        ));
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (isClosed) return;

      if (!serviceEnabled) {
        _safeEmit(state.copyWith(
          loading: false,
          serviceDisabled: true,
          errorMessage: 'Please enable location services and try again.',
        ));
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (isClosed) return;

      final bearing = _calculateQiblaBearing(position.latitude, position.longitude);
      final locationText = await _reverseGeocode(position.latitude, position.longitude);
      if (isClosed) return;

      _safeEmit(state.copyWith(
        loading: false,
        qiblaBearing: bearing,
        locationLine1: locationText.line1,
        locationLine2: locationText.line2,
      ));
    } catch (error) {
      if (isClosed) return;
      _safeEmit(state.copyWith(
        loading: false,
        errorMessage: 'Unable to determine location. Please try again later.',
        locationLine1: 'Location unavailable',
        locationLine2: 'Check your settings and retry.',
      ));
    }
  }

  Future<bool> _requestLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requestedPermission = await Geolocator.requestPermission();
      return requestedPermission == LocationPermission.always || requestedPermission == LocationPermission.whileInUse;
    }
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  Future<_LocationText> _reverseGeocode(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      final place = placemarks.firstWhere(
        (placemark) => placemark.locality != null || placemark.subAdministrativeArea != null || placemark.country != null,
        orElse: () => placemarks.first,
      );

      final line1 = <String?>[place.locality, place.subAdministrativeArea, place.country]
          .where((value) => value != null && value.isNotEmpty)
          .map((value) => value!)
          .join(', ');
      final line2 = <String?>[place.administrativeArea, place.isoCountryCode]
          .where((value) => value != null && value.isNotEmpty)
          .map((value) => value!)
          .join(', ');

      return _LocationText(
        line1: line1.isNotEmpty ? line1 : 'Unknown location',
        line2: line2.isNotEmpty ? line2 : 'No address data',
      );
    } catch (_) {
      return const _LocationText(
        line1: 'Unknown location',
        line2: 'Unable to resolve address',
      );
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

class _LocationText {
  const _LocationText({required this.line1, required this.line2});

  final String line1;
  final String line2;
}
