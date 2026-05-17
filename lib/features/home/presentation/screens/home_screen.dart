import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:muslim_mate/core/theme/app_colors.dart';
import 'package:muslim_mate/core/theme/app_text_styles.dart';
import 'package:muslim_mate/features/home/presentation/widgets/home_daily_activity_section.dart';
import 'package:muslim_mate/app_router.dart';
import 'package:muslim_mate/features/home/presentation/widgets/home_last_read_card.dart';
import 'package:muslim_mate/features/home/presentation/widgets/home_prayer_time_chip.dart';
import 'package:muslim_mate/features/home/presentation/widgets/home_shortcut_action_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  DateTime _currentTime = DateTime.now();
  Timer? _timer;
  bool _loading = true;
  String? _errorMessage;
  String _locationLabel = 'Fetching location…';
  String _hijriDate = '';
  List<PrayerTiming> _prayerTimings = [];
  DateTime? _cachedDate;
  late final AnimationController _shimmerController;
  final ScrollController _prayerScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _startTimer();
    _fetchPrayerTimes();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _prayerScrollController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (!DateUtils.isSameDay(now, _cachedDate ?? DateTime(1900))) {
        _fetchPrayerTimes();
      }
      final previousActiveName = _currentPrayer?.name;
      setState(() {
        _currentTime = now;
      });
      final currentActiveName = _currentPrayer?.name;
      if (previousActiveName != currentActiveName) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActivePrayer());
      }
    });
  }

  Future<void> _fetchPrayerTimes() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final position = await _determinePosition();
      final label = await _getLocationLabel(position);
      final response = await _loadPrayerTimes(position.latitude, position.longitude, _currentTime);

      setState(() {
        _locationLabel = label;
        _hijriDate = response.hijriDate ?? _formatHijriFromDate(_currentTime);
        _prayerTimings = response.prayerTimings;
        _cachedDate = DateTime(_currentTime.year, _currentTime.month, _currentTime.day);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActivePrayer());
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _hijriDate = _formatHijriFromDate(_currentTime);
        _prayerTimings = [];
        _locationLabel = error.toString().toLowerCase().contains('denied') ? 'Location unavailable' : 'Unknown location';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<Position> _determinePosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions denied.');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<String> _getLocationLabel(Position position) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json',
      );

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'MuslimApp/1.0'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return 'Location unavailable';
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>?;
      if (body == null) {
        return 'Location unavailable';
      }

      final address = body['address'] as Map<String, dynamic>?;
      if (address == null) {
        return 'Location unavailable';
      }

      final kecamatan = _trimmed(address['city_district']) ?? _trimmed(address['suburb']);
      final kota = _trimmed(address['city']) ?? _trimmed(address['county']);
      final state = _trimmed(address['state']);

      if (kecamatan != null && kota != null) {
        return '$kecamatan, $kota';
      }

      if (kecamatan != null) {
        return kecamatan;
      }

      if (kota != null) {
        return kota;
      }

      if (state != null) {
        return state;
      }

      return 'Location unavailable';
    } catch (e) {
      print('Location error: $e');
      return 'Location unavailable';
    }
  }

  String? _trimmed(Object? value) {
    final text = value?.toString().trim();
    return text?.isNotEmpty == true ? text : null;
  }

  Future<_PrayerResponse> _loadPrayerTimes(double latitude, double longitude, DateTime date) async {
    final dateString = DateFormat('dd-MM-yyyy').format(date);
    final uri = Uri.parse(
      'https://api.aladhan.com/v1/timings/$dateString?latitude=$latitude&longitude=$longitude&method=11',
    );

    final httpResponse = await http.get(uri).timeout(const Duration(seconds: 15));
    if (httpResponse.statusCode != 200) {
      throw Exception('Prayer times fetch failed (${httpResponse.statusCode}).');
    }

    final body = jsonDecode(httpResponse.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Invalid prayer times response.');
    }

    final timings = data['timings'] as Map<String, dynamic>?;
    if (timings == null) {
      throw Exception('Prayer timings missing from response.');
    }

    final hijri = data['date'] is Map<String, dynamic> ? data['date']['hijri'] as Map<String, dynamic>? : null;
    final hijriDate = _parseHijriDate(hijri);
    final prayerTimings = _parsePrayerTimings(timings, date);

    return _PrayerResponse(prayerTimings: prayerTimings, hijriDate: hijriDate);
  }

  String _parseHijriDate(Map<String, dynamic>? hijri) {
    if (hijri == null) {
      return _formatHijriFromDate(_currentTime);
    }

    final day = hijri['day']?.toString();
    final month = hijri['month'] is Map<String, dynamic> ? hijri['month']['en']?.toString() : null;
    final year = hijri['year']?.toString();
    if (day != null && month != null && year != null) {
      return '$day $month $year';
    }

    return _formatHijriFromDate(_currentTime);
  }

  List<PrayerTiming> _parsePrayerTimings(Map<String, dynamic> timings, DateTime date) {
    final prayerOrder = ['Imsak', 'Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    return prayerOrder.map((name) {
      final rawTime = timings[name]?.toString() ?? '';
      final dateTime = _buildPrayerDateTime(rawTime, date);
      final displayName = name == 'Imsak' ? 'Subuh' : name;
      return PrayerTiming(
        name: displayName,
        displayTime: rawTime.replaceAll(RegExp('[^0-9:]'), ''),
        dateTime: dateTime,
        icon: _iconForPrayer(displayName),
      );
    }).toList();
  }

  DateTime _buildPrayerDateTime(String rawTime, DateTime date) {
    final cleaned = rawTime.replaceAll(RegExp('[^0-9:]'), '');
    final parts = cleaned.split(':');
    if (parts.length < 2) {
      return DateTime(date.year, date.month, date.day, 0, 0);
    }
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  String _formatHijriFromDate(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    final monthName = hijri.longMonthName;
    return '${hijri.hDay} $monthName ${hijri.hYear}';
  }

  IconData _iconForPrayer(String name) {
    switch (name) {
      case 'Subuh':
        return Iconsax.moon;
      case 'Fajr':
        return Iconsax.cloud;
      case 'Dhuhr':
        return Iconsax.sun;
      case 'Asr':
        return Iconsax.cloud_sunny;
      case 'Maghrib':
        return Iconsax.moon;
      case 'Isha':
        return Iconsax.moon;
      default:
        return Iconsax.clock;
    }
  }

  PrayerTiming? _activePrayerForTime(DateTime time) {
    for (var i = 0; i < _prayerTimings.length; i++) {
      final timing = _prayerTimings[i];
      final next = i + 1 < _prayerTimings.length ? _prayerTimings[i + 1] : null;
      if (!time.isBefore(timing.dateTime) && (next == null || time.isBefore(next.dateTime))) {
        return timing;
      }
    }
    return null;
  }

  void _scrollToActivePrayer() {
    if (!_prayerScrollController.hasClients || _prayerTimings.isEmpty) {
      return;
    }

    final activeIndex = _prayerTimings.indexWhere((timing) => timing.name == _currentPrayer?.name);
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

  PrayerTiming? get _currentPrayer => _activePrayerForTime(_currentTime);

  PrayerTiming? get _nextPrayer {
    for (final timing in _prayerTimings) {
      if (_currentTime.isBefore(timing.dateTime)) {
        return timing;
      }
    }

    if (_prayerTimings.isNotEmpty) {
      return _prayerTimings.first.copyWith(
        dateTime: _prayerTimings.first.dateTime.add(const Duration(days: 1)),
      );
    }

    return null;
  }

  String get _countdownLabel {
    final next = _nextPrayer;
    final current = _currentPrayer;
    if (next == null) {
      return 'Waiting for prayer times';
    }

    if (current != null && _currentTime.isAfter(current.dateTime)) {
      final elapsed = _currentTime.difference(current.dateTime);
      if (elapsed <= const Duration(minutes: 1)) {
        return "It's ${current.name} time";
      }
      if (elapsed <= const Duration(minutes: 30)) {
        final minutes = elapsed.inMinutes;
        final minuteLabel = minutes == 1 ? '1 min ago' : '$minutes mins ago';
        return '${current.name} $minuteLabel';
      }
    }

    final remaining = next.dateTime.difference(_currentTime);
    if (remaining.isNegative) {
      return '${next.name} in 00:00:00';
    }
    return '${next.name} in ${_formatDuration(remaining)}';
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
                      child: Column(
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
                                      _countdownLabel,
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
                                  if (_hijriDate.isNotEmpty) ...[
                                    Text(
                                      _hijriDate,
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
                                              _locationLabel,
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
                          _loading ? _buildPrayerTimeSkeletons() : _buildPrayerTimeCards(),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              style: HomeTextStyles.body12Regular.copyWith(
                                color: Colors.white.withAlpha(220),
                              ),
                            ),
                          ],
                        ],
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
                            Navigator.pushNamed(context, AppRouter.qibla);
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

  Widget _buildPrayerTimeCards() {
    final currentPrayer = _currentPrayer;
    return SingleChildScrollView(
      controller: _prayerScrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: _prayerTimings.map((timing) {
          final active = currentPrayer?.name == timing.name;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: HomePrayerTimeChip(
              title: timing.name,
              time: timing.displayTime,
              icon: timing.icon,
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

class PrayerTiming {
  PrayerTiming({
    required this.name,
    required this.displayTime,
    required this.dateTime,
    required this.icon,
  });

  final String name;
  final String displayTime;
  final DateTime dateTime;
  final IconData icon;

  PrayerTiming copyWith({DateTime? dateTime}) {
    return PrayerTiming(
      name: name,
      displayTime: displayTime,
      dateTime: dateTime ?? this.dateTime,
      icon: icon,
    );
  }
}

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
