import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslim_mate/core/theme/app_colors.dart';
import 'package:muslim_mate/core/theme/app_text_styles.dart';
import 'package:muslim_mate/features/qibla/presentation/cubit/qibla_cubit.dart';
import 'package:muslim_mate/features/qibla/presentation/cubit/qibla_state.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QiblaCubit>(
      create: (_) => QiblaCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Qibla Direction'),
          backgroundColor: HomeColors.primary,
          elevation: 0,
        ),
        body: BlocBuilder<QiblaCubit, QiblaState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationCard(context, state),
                  const SizedBox(height: 24),
                  _buildCompassCard(context, state),
                  const SizedBox(height: 24),
                  _buildStatusRow(state),
                  if (state.errorMessage != null || state.permissionDenied || state.serviceDisabled)
                    const SizedBox(height: 24),
                  if (state.errorMessage != null || state.permissionDenied || state.serviceDisabled)
                    _buildActionCard(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, QiblaState state) {
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
            state.locationLine1,
            style: HomeTextStyles.body14Bold.copyWith(color: HomeColors.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            state.locationLine2,
            style: HomeTextStyles.body14Regular.copyWith(color: HomeColors.onSurfaceSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBadge(label: 'Qibla', value: state.loading ? '––' : '${state.qiblaBearing.round()}°'),
              const SizedBox(width: 12),
              _buildBadge(label: 'Direction', value: state.loading ? '––' : _formatCardinal(state.qiblaBearing)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompassCard(BuildContext context, QiblaState state) {
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
                  angle: -state.deviceHeading * pi / 180,
                  child: CustomPaint(
                    size: const Size(300, 300),
                    painter: _CompassPainter(
                      qiblaBearing: state.qiblaBearing,
                    ),
                  ),
                ),
                if (state.loading)
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
                          _formatCardinal(state.qiblaBearing),
                          style: HomeTextStyles.title16Bold.copyWith(color: HomeColors.primary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${state.qiblaBearing.round()}°',
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
            state.loading ? 'Preparing compass data…' : 'Live heading: ${state.deviceHeading.toStringAsFixed(0)}°',
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

  Widget _buildStatusRow(QiblaState state) {
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
                  state.deviceHeading == 0 && !state.loading ? 'Calibrating…' : 'Ready',
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
                  state.loading ? 'Loading…' : (state.serviceDisabled ? 'GPS off' : (state.permissionDenied ? 'Denied' : 'Active')),
                  style: HomeTextStyles.title14Bold.copyWith(color: HomeColors.onSurface),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, QiblaState state) {
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
            state.permissionDenied
                ? 'Location permission needed'
                : state.serviceDisabled
                    ? 'Enable location services'
                    : 'Try again',
            style: HomeTextStyles.title16Bold.copyWith(color: HomeColors.onSurface),
          ),
          const SizedBox(height: 10),
          Text(
            state.errorMessage ?? 'Grant access or turn on GPS to continue using the Qibla compass.',
            style: HomeTextStyles.body14Regular.copyWith(color: HomeColors.onSurfaceSecondary),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () => context.read<QiblaCubit>().loadLocationAndQibla(),
            style: ElevatedButton.styleFrom(
              backgroundColor: HomeColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Retry'),
          ),
          if (state.permissionDenied) ...[
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

  String _formatCardinal(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'N'];
    final index = ((degrees + 22.5) / 45).floor() % 8;
    return directions[index];
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
