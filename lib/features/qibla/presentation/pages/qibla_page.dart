import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:muslim_mate/app/router/app_router.dart';
import 'package:muslim_mate/core/services/injection.dart';
import 'package:muslim_mate/features/prayer/data/sources/location_data_source.dart';
import 'package:muslim_mate/core/theme/app_colors.dart';
import 'package:muslim_mate/core/theme/app_text_styles.dart';
import 'package:muslim_mate/features/qibla/presentation/cubit/qibla_cubit.dart';
import 'package:muslim_mate/features/qibla/presentation/cubit/qibla_state.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QiblaCubit>(
      create: (_) => QiblaCubit(sl<LocationDataSource>()),
      child: Scaffold(
        backgroundColor: HomeColors.background,
        appBar: AppBar(
          backgroundColor: HomeColors.background,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          scrolledUnderElevation: 0,
          toolbarOpacity: 1.0,
          toolbarHeight: 64,
          centerTitle: false,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left, color: HomeColors.onSurface),
            onPressed: () => context.go(AppRoutes.home),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<QiblaCubit, QiblaState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    _buildCompassSection(state),
                    const SizedBox(height: 24),
                    _buildDirectionSection(state),
                    const SizedBox(height: 24),
                    _buildLocationSection(state),
                    const SizedBox(height: 24),
                    _buildRefreshAction(context, state),
                    if (state.errorMessage != null || state.permissionDenied || state.serviceDisabled) ...[
                      const SizedBox(height: 18),
                      _buildErrorMessage(state),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCompassSection(QiblaState state) {
    final relativeDegrees = (state.qiblaBearing - state.deviceHeading + 360) % 360;
    return Column(
      children: [
        Text(
          'Point the compass to the Kaaba',
          style: HomeTextStyles.title16Bold.copyWith(color: HomeColors.onSurface),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Rotate your device until the arrow points to the Kaaba marker.',
          style: HomeTextStyles.body14Regular.copyWith(color: HomeColors.onSurfaceSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 320,
          height: 320,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildCompassDial(),
              AnimatedRotation(
                turns: relativeDegrees / 360,
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOut,
                child: const _CompassArrow(),
              ),
              Positioned(
                top: 28,
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: HomeColors.primary.withAlpha(24),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Iconsax.location, size: 20, color: HomeColors.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kaaba',
                      style: HomeTextStyles.body12Regular.copyWith(color: HomeColors.onSurfaceSecondary),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCompassDirection('N'),
                    const SizedBox(width: 14),
                    _buildCompassDirection('E'),
                    const SizedBox(width: 14),
                    _buildCompassDirection('S'),
                    const SizedBox(width: 14),
                    _buildCompassDirection('W'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompassDial() {
    return CustomPaint(
      size: const Size(320, 320),
      painter: _CompassDialPainter(),
    );
  }

  Widget _buildCompassDirection(String label) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: HomeColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(label, style: HomeTextStyles.title14Bold.copyWith(color: HomeColors.onSurface)),
    );
  }

  Widget _buildDirectionSection(QiblaState state) {
    final cardinal = _formatCardinal(state.qiblaBearing);
    final degrees = state.qiblaBearing.round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Qibla direction',
          style: HomeTextStyles.body12Regular.copyWith(color: HomeColors.onSurfaceSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          state.loading ? 'Calculating…' : '$degrees° $cardinal',
          style: HomeTextStyles.headline40Bold.copyWith(fontSize: 32, color: HomeColors.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Use the arrow and marker to align your phone with the Qibla.',
          style: HomeTextStyles.body14Regular.copyWith(color: HomeColors.onSurfaceSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLocationSection(QiblaState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Your location',
          style: HomeTextStyles.title16Bold.copyWith(color: HomeColors.onSurface),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          state.locationLine1,
          style: HomeTextStyles.body14Bold.copyWith(color: HomeColors.onSurface),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          state.locationLine2,
          style: HomeTextStyles.body14Regular.copyWith(color: HomeColors.onSurfaceSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.map_1, size: 20, color: HomeColors.primary),
            const SizedBox(width: 8),
            Text(
              state.loading ? 'Fetching GPS location…' : 'Using current device position',
              style: HomeTextStyles.body12Regular.copyWith(color: HomeColors.onSurfaceSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRefreshAction(BuildContext context, QiblaState state) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: state.loading ? null : () => context.read<QiblaCubit>().loadLocationAndQibla(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.refresh_circle,
              size: 20,
              color: state.loading ? HomeColors.onSurfaceSecondary : HomeColors.primary,
            ),
            const SizedBox(width: 10),
            Text(
              state.loading ? 'Recalibrating…' : 'Refresh',
              style: HomeTextStyles.title14Bold.copyWith(
                color: state.loading ? HomeColors.onSurfaceSecondary : HomeColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(QiblaState state) {
    final message = state.permissionDenied
        ? 'Location permission denied'
        : state.serviceDisabled
            ? 'GPS services unavailable'
            : 'Unable to update compass';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          message,
          style: HomeTextStyles.title16Bold.copyWith(color: HomeColors.onSurface),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          state.errorMessage ?? 'Make sure location and motion permissions are enabled.',
          style: HomeTextStyles.body14Regular.copyWith(color: HomeColors.onSurfaceSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatCardinal(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'N'];
    final index = ((degrees + 22.5) / 45).floor() % 8;
    return directions[index];
  }
}

class _CompassDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width * 0.44;
    final ringPaint = Paint()..color = HomeColors.surface;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = HomeColors.divider
      ..strokeWidth = 2;

    canvas.drawCircle(center, outerRadius, ringPaint);
    canvas.drawCircle(center, outerRadius, borderPaint);

    final tickPaint = Paint()..color = HomeColors.onSurfaceSecondary;
    for (var i = 0; i < 60; i++) {
      final angle = 2 * pi * i / 60;
      final isMajor = i % 5 == 0;
      final length = isMajor ? 18.0 : 10.0;
      final start = center + Offset(cos(angle), sin(angle)) * (outerRadius - length - 6);
      final end = center + Offset(cos(angle), sin(angle)) * outerRadius;
      tickPaint.strokeWidth = isMajor ? 2 : 1;
      canvas.drawLine(start, end, tickPaint);
    }

    final labelStyle = TextStyle(
      color: HomeColors.onSurface,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    );

    _drawText(canvas, 'N', center + Offset(0, -outerRadius + 22), labelStyle);
    _drawText(canvas, 'E', center + Offset(outerRadius - 20, 0), labelStyle);
    _drawText(canvas, 'S', center + Offset(0, outerRadius - 22), labelStyle);
    _drawText(canvas, 'W', center + Offset(-outerRadius + 20, 0), labelStyle);

    final innerPaint = Paint()..color = HomeColors.surfaceVariant;
    canvas.drawCircle(center, outerRadius * 0.64, innerPaint);
    canvas.drawCircle(center, outerRadius * 0.64, borderPaint);
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final offset = position - Offset(textPainter.width / 2, textPainter.height / 2);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompassArrow extends StatelessWidget {
  const _CompassArrow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 320,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 140,
              decoration: BoxDecoration(
                color: HomeColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 0),
            CustomPaint(
              size: const Size(40, 40),
              painter: _ArrowHeadPainter(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrowHeadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = HomeColors.primary;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
