import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muslim_mate/core/services/injection.dart';
import 'package:muslim_mate/core/theme/app_colors.dart';
import 'package:muslim_mate/core/theme/app_text_styles.dart';
import 'package:muslim_mate/features/home/presentation/widgets/home_daily_activity_section.dart';
import 'package:go_router/go_router.dart';
import 'package:muslim_mate/app/router/app_router.dart';
import 'package:muslim_mate/features/home/presentation/widgets/home_last_read_card.dart';
import 'package:muslim_mate/features/home/presentation/widgets/home_prayer_time_chip.dart';
import 'package:muslim_mate/features/home/presentation/widgets/home_shortcut_action_card.dart';
import 'package:intl/intl.dart';
import 'package:muslim_mate/features/prayer/data/sources/location_data_source.dart';
import 'package:muslim_mate/features/prayer/domain/entities/prayer_timing.dart';
import 'package:muslim_mate/features/prayer/domain/repositories/prayer_repository.dart';
import 'package:muslim_mate/features/prayer/presentation/cubit/prayer_cubit.dart';
import 'package:muslim_mate/features/prayer/presentation/cubit/prayer_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  DateTime _currentTime = DateTime.now();
  Timer? _timer;
  late final PrayerCubit _prayerCubit;
  late final AnimationController _shimmerController;
  final ScrollController _prayerScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _prayerCubit = PrayerCubit(
      sl<PrayerRepository>(),
      sl<LocationDataSource>(),
    );
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _startTimer();
    _prayerCubit.loadPrayerTimes();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _prayerCubit.close();
    _prayerScrollController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final now = DateTime.now();
      if (!DateUtils.isSameDay(now, _prayerCubit.state.cachedDate ?? DateTime(1900))) {
        _prayerCubit.loadPrayerTimes();
      }
      final previousActiveName = _prayerCubit.currentPrayer(_currentTime)?.name;
      setState(() {
        _currentTime = now;
      });
      final currentActiveName = _prayerCubit.currentPrayer(_currentTime)?.name;
      if (previousActiveName != currentActiveName) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _scrollToActivePrayer();
        });
      }
    });
  }

  void _scrollToActivePrayer() {
    final prayerTimings = _prayerCubit.state.prayerTimings;
    if (!_prayerScrollController.hasClients || prayerTimings.isEmpty) {
      return;
    }

    final activePrayer = _prayerCubit.currentPrayer(_currentTime);
    if (activePrayer == null) {
      return;
    }

    final activeIndex = prayerTimings.indexWhere((timing) => timing.name == activePrayer.name);
    if (activeIndex < 0) {
      return;
    }

    const cardTotalWidth = 102.0 + 10.0;
    final offset = (activeIndex * cardTotalWidth) - 16.0;
    final target = offset.clamp(0.0, _prayerScrollController.position.maxScrollExtent);
    _prayerScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOut,
    );
  }

  String _countdownLabel(PrayerState state) {
    final prayerTimings = state.prayerTimings;
    PrayerTiming? nextPrayer;
    for (final timing in prayerTimings) {
      if (_currentTime.isBefore(timing.dateTime)) {
        nextPrayer = timing;
        break;
      }
    }

    if (nextPrayer == null) {
      return 'Waiting for prayer times';
    }

    final currentPrayer = _prayerCubit.currentPrayer(_currentTime);
    if (currentPrayer != null && _currentTime.isAfter(currentPrayer.dateTime)) {
      final elapsed = _currentTime.difference(currentPrayer.dateTime);
      if (elapsed <= const Duration(minutes: 1)) {
        return "It's ${currentPrayer.name} time";
      }
      if (elapsed <= const Duration(minutes: 30)) {
        final minutes = elapsed.inMinutes;
        final minuteLabel = minutes == 1 ? '1 min ago' : '$minutes mins ago';
        return '${currentPrayer.name} $minuteLabel';
      }
    }

    final remaining = nextPrayer.dateTime.difference(_currentTime);
    if (remaining.isNegative) {
      return '${nextPrayer.name} in 00:00:00';
    }

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);
    final hoursString = hours.toString().padLeft(2, '0');
    final minutesString = minutes.toString().padLeft(2, '0');
    final secondsString = seconds.toString().padLeft(2, '0');
    return '${nextPrayer.name} in $hoursString:$minutesString:$secondsString';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              Container(
                constraints: const BoxConstraints(minHeight: 380),
                width: double.infinity,
                color: HomeColors.primary,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SvgPicture.asset(
                          'assets/mosque.svg',
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                          height: 220,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 48,
                        bottom: 20,
                      ),
                      child: BlocBuilder<PrayerCubit, PrayerState>(
                        bloc: _prayerCubit,
                        builder: (context, state) {
                          final currentPrayer = _prayerCubit.currentPrayer(_currentTime);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          DateFormat('HH:mm').format(_currentTime),
                                          style: HomeTextStyles.headline40Bold.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _countdownLabel(state),
                                          style: HomeTextStyles.title14Regular.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (state.hijriDate.isNotEmpty) ...[
                                        Text(
                                          state.hijriDate,
                                          style: HomeTextStyles.body14Regular.copyWith(
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 190),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: HomeColors.overlayWhite20,
                                            borderRadius: BorderRadius.circular(1000),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Iconsax.location,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  state.locationLabel,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: HomeTextStyles.body12Regular.copyWith(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              const Icon(
                                                Iconsax.arrow_right_3,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              state.loading
                                  ? _buildPrayerTimeSkeletons()
                                  : _buildPrayerTimeCards(state.prayerTimings, currentPrayer),
                              if (state.errorMessage != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  state.errorMessage!,
                                  style: HomeTextStyles.body12Regular.copyWith(
                                    color: Colors.white.withAlpha(220),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            Transform.translate(
              offset: const Offset(0, -45),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    const HomeLastReadCard(),
                    Row(
                      children: [
                        HomeShortcutActionCard(
                          title: 'Find',
                          subtitle: 'Qibla',
                          icon: Iconsax.discover,
                          onTap: () {
                            context.go(AppRoutes.qibla);
                          },
                        ),
                        const SizedBox(width: 10),
                        const HomeShortcutActionCard(
                          title: 'Find nearest',
                          subtitle: 'Mosque',
                          icon: Iconsax.location,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const HomeDailyActivitySection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildPrayerTimeCards(List<PrayerTiming> prayerTimings, PrayerTiming? currentPrayer) {
    return SingleChildScrollView(
      controller: _prayerScrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: prayerTimings.map((timing) {
          final active = currentPrayer?.name == timing.name;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
              child: HomePrayerTimeChip(
              title: timing.name,
              time: timing.displayTime,
              icon: Icons.access_time,
              active: active,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPrayerTimeSkeletons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(6, (index) {
          return Padding(
            padding: EdgeInsets.only(right: index == 5 ? 0 : 10),
            child: _Shimmer(
              controller: _shimmerController,
              child: Container(
                width: 92,
                height: 136,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(41),
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Use `PrayerTiming` from domain entity: `features/prayer/domain/entities/prayer_timing.dart`

class _PrayerResponse {
  _PrayerResponse({
    required this.prayerTimings,
    required this.hijriDate,
  });

  final List<PrayerTiming> prayerTimings;
  final String? hijriDate;
}

class _Shimmer extends StatelessWidget {
  const _Shimmer({
    required this.child,
    required this.controller,
  });

  final Widget child;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, childWidget) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final shimmerPosition = controller.value * 2 - 1;
            return LinearGradient(
              begin: Alignment(-1 - shimmerPosition, -0.3),
              end: Alignment(1 - shimmerPosition, 0.3),
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: const [0.1, 0.3, 0.4],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: childWidget,
        );
      },
      child: child,
    );
  }
}
