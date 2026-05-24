import 'package:flutter/foundation.dart';

const _unsetErrorMessage = Object();

@immutable
class QiblaState {
  final double deviceHeading;
  final double qiblaBearing;
  final bool loading;
  final bool permissionDenied;
  final bool serviceDisabled;
  final String locationLine1;
  final String locationLine2;
  final String? errorMessage;

  const QiblaState({
    required this.deviceHeading,
    required this.qiblaBearing,
    required this.loading,
    required this.permissionDenied,
    required this.serviceDisabled,
    required this.locationLine1,
    required this.locationLine2,
    required this.errorMessage,
  });

  factory QiblaState.initial() {
    return const QiblaState(
      deviceHeading: 0.0,
      qiblaBearing: 0.0,
      loading: true,
      permissionDenied: false,
      serviceDisabled: false,
      locationLine1: 'Fetching location…',
      locationLine2: '',
      errorMessage: null,
    );
  }

  QiblaState copyWith({
    double? deviceHeading,
    double? qiblaBearing,
    bool? loading,
    bool? permissionDenied,
    bool? serviceDisabled,
    String? locationLine1,
    String? locationLine2,
    Object? errorMessage = _unsetErrorMessage,
  }) {
    return QiblaState(
      deviceHeading: deviceHeading ?? this.deviceHeading,
      qiblaBearing: qiblaBearing ?? this.qiblaBearing,
      loading: loading ?? this.loading,
      permissionDenied: permissionDenied ?? this.permissionDenied,
      serviceDisabled: serviceDisabled ?? this.serviceDisabled,
      locationLine1: locationLine1 ?? this.locationLine1,
      locationLine2: locationLine2 ?? this.locationLine2,
      errorMessage: identical(errorMessage, _unsetErrorMessage) ? this.errorMessage : errorMessage as String?,
    );
  }
}
