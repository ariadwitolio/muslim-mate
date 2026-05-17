import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:muslim_mate/core/theme/app_colors.dart';
import 'package:muslim_mate/core/theme/app_text_styles.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  static const _kaabaLatitude = 21.4225;
  static const _kaabaLongitude = 39.8262;

  double _deviceHeading = 0.0;
  double _qiblaBearing = 0.0;
  bool _loading = true;
  bool _permissionDenied = false;
  bool _serviceDisabled = false;
  String _locationLine1 = 'Fetching location…';
  String _locationLine2 = '';
  String? _errorMessage;
  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _listenCompass();
    _loadLocationAndQibla();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  void _listenCompass() {
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        setState(() {
          _deviceHeading = event.heading!;
        });
      }
    }, onError: (_) {
      // Ignored: some devices may not expose a heading.
    });
  }

  Future<void> _loadLocationAndQibla() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _permissionDenied = false;
      _serviceDisabled = false;
    });

    try {
      final permissionGranted = await _requestLocationPermission();
      if (!permissionGranted) {
        setState(() {
          _loading = false;
          _permissionDenied = true;
          _locationLine1 = 'Permission required';
          _locationLine2 = 'Allow location access to find Qibla direction';
        });
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _loading = false;
          _serviceDisabled = true;
          _locationLine1 = 'Location service off';
          _locationLine2 = 'Turn on GPS to calculate Qibla';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      final bearing = _calculateQiblaBearing(position.latitude, position.longitude);
      final place = await _reverseGeocode(position.latitude, position.longitude);

      setState(() {
        _qiblaBearing = bearing;
        _loading = false;
        _locationLine1 = place.line1;
        _locationLine2 = place.line2;
      });
    } catch (error) {
      setState(() {
        _loading = false;
        _errorMessage = 'Unable to determine your location right now.';
        _locationLine1 = 'Location unavailable';
        _locationLine2 = 'Try again or check your settings.';
      });
    }
  }

  Future<bool> _requestLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      return true;
    }

    var requested = permission;
    if (requested == LocationPermission.denied) {
      requested = await Geolocator.requestPermission();
    }

    return requested == LocationPermission.always || requested == LocationPermission.whileInUse;
  }

  Future<_LocationText> _reverseGeocode(double latitude, double longitude) async {
    final placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isEmpty) {
      return const _LocationText(line1: 'Unknown location', line2: '');
    }

    final place = placemarks.first;
    final line1 = <String?>[place.locality, place.subAdministrativeArea, place.country]
        .where((value) => value != null && value.isNotEmpty)
        .cast<String>()
        .join(', ');

    final line2 = <String?>[place.administrativeArea, place.isoCountryCode]
        .where((value) => value != null && value.isNotEmpty)
        .cast<String>()
        .join(', ');

    return _LocationText(
      line1: line1.isNotEmpty ? line1 : 'Current location',
      line2: line2.isNotEmpty ? line2 : '',
    );
  }

  double _calculateQiblaBearing(double latitude, double longitude) {
    final currentLat = _degreesToRadians(latitude);
    final currentLon = _degreesToRadians(longitude);
    final kaabaLat = _degreesToRadians(_kaabaLatitude);
    final kaabaLon = _degreesToRadians(_kaabaLongitude);

    final deltaLon = kaabaLon - currentLon;
    final y = sin(deltaLon) * cos(kaabaLat);
    final x = cos(currentLat) * sin(kaabaLat) - sin(currentLat) * cos(kaabaLat) * cos(deltaLon);
    final bearing = atan2(y, x);
    return (_radiansToDegrees(bearing) + 360) % 360;
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;

  double _radiansToDegrees(double radians) => radians * 180 / pi;

  String _formatCardinal(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'N'];
    final index = ((degrees + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Direction'),
        backgroundColor: HomeColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationCard(context),
            const SizedBox(height: 24),
            _buildCompassCard(context),
            const SizedBox(height: 24),
            _buildStatusRow(),
            if (_errorMessage != null || _permissionDenied || _serviceDisabled)
              const SizedBox(height: 24),
            if (_errorMessage != null || _permissionDenied || _serviceDisabled)
              _buildActionCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HomeColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HomeColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('You are here', style: HomeTextStyles.title16Bold.copyWith(color: HomeColors.primaryDark)),
          const SizedBox(height: 8),
          Text(
            _locationLine1,
            style: HomeTextStyles.body14Bold.copyWith(color: HomeColors.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            _locationLine2,
            style: HomeTextStyles.body14Regular.copyWith(color: HomeColors.onSurfaceSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBadge(label: 'Qibla', value: _loading ? '––' : '${_qiblaBearing.round()}°'),
              const SizedBox(width: 12),
              _buildBadge(label: 'Direction', value: _loading ? '––' : _formatCardinal(_qiblaBearing)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompassCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HomeColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: HomeColors.divider),
      ),
      child: Column(
        children: [
          Text(
            'Point the arrow toward the Kaaba',
            style: HomeTextStyles.body14Bold.copyWith(color: HomeColors.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: -_deviceHeading * pi / 180,
                  child: CustomPaint(
                    size: const Size(300, 300),
                    painter: _CompassPainter(
                      qiblaBearing: _qiblaBearing,
                    ),
                  ),
                ),
                if (_loading)
                  const SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(strokeWidth: 4),
                  )
                else
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: HomeColors.primary.withAlpha(20),
                      border: Border.all(color: HomeColors.primary, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatCardinal(_qiblaBearing),
                          style: HomeTextStyles.title16Bold.copyWith(color: HomeColors.primary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_qiblaBearing.round()}°',
                          style: HomeTextStyles.title14Bold.copyWith(color: HomeColors.onSurface),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _loading ? 'Preparing compass data…' : 'Live heading: ${_deviceHeading.toStringAsFixed(0)}°',
            style: HomeTextStyles.body14Regular.copyWith(color: HomeColors.onSurfaceSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: HomeColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: HomeColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: HomeTextStyles.body12Regular.copyWith(color: HomeColors.onSurfaceSecondary)),
            const SizedBox(height: 8),
            Text(value, style: HomeTextStyles.title14Bold.copyWith(color: HomeColors.onSurface)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HomeColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: HomeColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Compass status', style: HomeTextStyles.body12Regular.copyWith(color: HomeColors.onSurfaceSecondary)),
                const SizedBox(height: 8),
                Text(
                  _deviceHeading == 0 && !_loading ? 'Calibrating…' : 'Ready',
                  style: HomeTextStyles.title14Bold.copyWith(color: HomeColors.onSurface),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HomeColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: HomeColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Location', style: HomeTextStyles.body12Regular.copyWith(color: HomeColors.onSurfaceSecondary)),
                const SizedBox(height: 8),
                Text(
                  _loading ? 'Loading…' : (_serviceDisabled ? 'GPS off' : (_permissionDenied ? 'Denied' : 'Active')),
                  style: HomeTextStyles.title14Bold.copyWith(color: HomeColors.onSurface),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HomeColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HomeColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _permissionDenied ? 'Location permission needed' : _serviceDisabled ? 'Enable location services' : 'Try again',
            style: HomeTextStyles.title16Bold.copyWith(color: HomeColors.onSurface),
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage ?? 'Grant access or turn on GPS to continue using the Qibla compass.',
            style: HomeTextStyles.body14Regular.copyWith(color: HomeColors.onSurfaceSecondary),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _loadLocationAndQibla,
            style: ElevatedButton.styleFrom(
              backgroundColor: HomeColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Retry'),
          ),
          if (_permissionDenied) ...[
            const SizedBox(height: 10),
            Text(
              'If permission is permanently denied, open your device settings and allow location access.',
              style: HomeTextStyles.body12Regular.copyWith(color: HomeColors.onSurfaceSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter({required this.qiblaBearing});

  final double qiblaBearing;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width * 0.45;

    final fillPaint = Paint()..color = HomeColors.surfaceVariant;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = HomeColors.divider
      ..strokeWidth = 2;

    canvas.drawCircle(center, outerRadius, fillPaint);
    canvas.drawCircle(center, outerRadius, borderPaint);

    final tickPaint = Paint()..color = HomeColors.onSurfaceSecondary;
    for (var index = 0; index < 60; index++) {
      final angle = 2 * pi * index / 60;
      final tickLength = index % 5 == 0 ? 14.0 : 8.0;
      final inner = center + Offset(cos(angle), sin(angle)) * (outerRadius - tickLength);
      final outer = center + Offset(cos(angle), sin(angle)) * outerRadius;
      canvas.drawLine(inner, outer, tickPaint..strokeWidth = index % 5 == 0 ? 2 : 1);
    }

    final labelStyle = TextStyle(
      color: HomeColors.onSurface,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    );

    _drawText(canvas, 'N', center + const Offset(0, -118), labelStyle);
    _drawText(canvas, 'E', center + const Offset(118, 0), labelStyle);
    _drawText(canvas, 'S', center + const Offset(0, 118), labelStyle);
    _drawText(canvas, 'W', center + const Offset(-118, 0), labelStyle);

    final arrowPaint = Paint()
      ..color = HomeColors.primary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final arrowAngle = _degreesToRadians(qiblaBearing - 90);
    final arrowLength = outerRadius * 0.65;
    final arrowEnd = center + Offset(cos(arrowAngle), sin(arrowAngle)) * arrowLength;
    canvas.drawLine(center, arrowEnd, arrowPaint);

    final headPath = Path();
    final headSize = 16.0;
    final headTip = arrowEnd + Offset(cos(arrowAngle), sin(arrowAngle)) * headSize;
    final left = arrowEnd + Offset(cos(arrowAngle + pi * 0.45), sin(arrowAngle + pi * 0.45)) * headSize;
    final right = arrowEnd + Offset(cos(arrowAngle - pi * 0.45), sin(arrowAngle - pi * 0.45)) * headSize;
    headPath.moveTo(headTip.dx, headTip.dy);
    headPath.lineTo(left.dx, left.dy);
    headPath.lineTo(right.dx, right.dy);
    headPath.close();
    canvas.drawPath(headPath, arrowPaint..style = PaintingStyle.fill);
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, position - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) {
    return oldDelegate.qiblaBearing != qiblaBearing;
  }
}

class _LocationText {
  const _LocationText({required this.line1, required this.line2});

  final String line1;
  final String line2;
}
