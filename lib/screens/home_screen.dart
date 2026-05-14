import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:muslim_mate/constants/index.dart';

const Color _homeHeaderColor = AppColors.primary;
const Color _homeIconBackgroundColor = AppColors.primary;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  DateTime _currentTime = DateTime.now();
  Timer? _timer;
  bool _loading = true;
  String? _errorMessage;
  String _locationLabel = 'Fetching location…';
  String _hijriDate = '';
  List<PrayerTiming> _prayerTimings = [];
  DateTime? _cachedTimingDate;
  late final AnimationController _shimmerController;

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
    _shimmerController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (!DateUtils.isSameDay(now, _cachedTimingDate ?? DateTime(1900))) {
        _fetchPrayerTimes();
      }
      setState(() {
        _currentTime = now;
      });
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
      final response = await _loadPrayerTimes(
        position.latitude,
        position.longitude,
        _currentTime,
      );

      setState(() {
        _locationLabel = label;
        _hijriDate = response.hijriDate ?? _formatHijriFromDate(_currentTime);
        _prayerTimings = response.prayerTimings;
        _cachedTimingDate = DateTime(
          _currentTime.year,
          _currentTime.month,
          _currentTime.day,
        );
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _hijriDate = _formatHijriFromDate(_currentTime);
        if (_errorMessage!.toLowerCase().contains('denied')) {
          _locationLabel = 'Location unavailable';
        }
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

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String> _getLocationLabel(Position position) async {
    try {
      final places = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final place = places.isNotEmpty ? places.first : null;
      return place?.locality ??
          place?.administrativeArea ??
          place?.country ??
          'Unknown location';
    } catch (_) {
      return 'Unknown location';
    }
  }

  Future<_PrayerResponse> _loadPrayerTimes(
    double latitude,
    double longitude,
    DateTime date,
  ) async {
    final dateString = DateFormat('dd-MM-yyyy').format(date);
    final uri = Uri.parse(
      'https://api.aladhan.com/v1/timings/$dateString?latitude=$latitude&longitude=$longitude&method=11',
    );

    final httpResponse = await http
        .get(uri)
        .timeout(const Duration(seconds: 15));
    if (httpResponse.statusCode != 200) {
      throw Exception(
        'Prayer times fetch failed (${httpResponse.statusCode}).',
      );
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

    final hijri = data['date'] is Map<String, dynamic>
        ? data['date']['hijri'] as Map<String, dynamic>?
        : null;
    final hijriDate = _parseHijriDate(hijri);
    final prayerTimings = _parsePrayerTimings(timings, date);

    return _PrayerResponse(prayerTimings: prayerTimings, hijriDate: hijriDate);
  }

  String _parseHijriDate(Map<String, dynamic>? hijri) {
    if (hijri == null) {
      return _formatHijriFromDate(_currentTime);
    }

    final day = hijri['day']?.toString();
    final month = hijri['month'] is Map<String, dynamic>
        ? hijri['month']['en']?.toString()
        : null;
    final year = hijri['year']?.toString();
    if (day != null && month != null && year != null) {
      return '$day $month $year';
    }

    return _formatHijriFromDate(_currentTime);
  }

  List<PrayerTiming> _parsePrayerTimings(
    Map<String, dynamic> timings,
    DateTime date,
  ) {
    final prayerOrder = ['Imsak', 'Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    return prayerOrder.map((name) {
      final rawTime = timings[name]?.toString() ?? '';
      final dateTime = _buildPrayerDateTime(rawTime, date);
      return PrayerTiming(
        name: name,
        displayTime: rawTime.replaceAll(RegExp('[^0-9:]'), ''),
        dateTime: dateTime,
        iconData: _iconForPrayer(name),
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
      case 'Imsak':
        return Icons.notifications;
      case 'Fajr':
        return Icons.cloud;
      case 'Dhuhr':
        return Icons.wb_sunny;
      case 'Asr':
        return Icons.cloud_queue;
      case 'Maghrib':
        return Icons.nightlight_round;
      case 'Isha':
        return Icons.bedtime;
      default:
        return Icons.access_time;
    }
  }

  PrayerTiming? get _currentPrayer {
    for (var i = 0; i < _prayerTimings.length; i++) {
      final timing = _prayerTimings[i];
      final next = i + 1 < _prayerTimings.length ? _prayerTimings[i + 1] : null;
      if (!_currentTime.isBefore(timing.dateTime) &&
          (next == null || _currentTime.isBefore(next.dateTime))) {
        return timing;
      }
    }
    return null;
  }

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
      if (elapsed <= const Duration(minutes: 30)) {
        return '${current.name} started ${_formatDuration(elapsed)} ago';
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
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 356,
              color: _homeHeaderColor,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hijriDate.isNotEmpty
                          ? _hijriDate
                          : 'Loading Hijri date…',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(46),
                        borderRadius: BorderRadius.circular(1000),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _locationLabel,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      DateFormat('HH:mm').format(_currentTime),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _countdownLabel,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    _loading
                        ? _buildPrayerTimeSkeletons()
                        : _buildPrayerTimeCards(),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withAlpha(217),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildLastReadCard(context),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildQuickActionCard(
                          icon: Icons.explore,
                          title: 'Find',
                          subtitle: 'Qibla',
                        ),
                        const SizedBox(width: 10),
                        _buildQuickActionCard(
                          icon: Icons.location_on,
                          title: 'Find nearest',
                          subtitle: 'Mosque',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDailyActivitySection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
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
                width: 72,
                height: 92,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(41),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPrayerTimeCards() {
    final currentPrayer = _currentPrayer;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _prayerTimings.map((timing) {
          final active = currentPrayer?.name == timing.name;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _PrayerTimeCard(timing: timing, active: active),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLastReadCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha((0.06 * 255).round()),
            blurRadius: 16,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _homeIconBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.menu_book, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last Read',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.greyDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Al Baqarah : 120',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  child: Text(
                    'Juz 1',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.greyDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _homeHeaderColor,
              borderRadius: BorderRadius.circular(1000),
            ),
            alignment: Alignment.center,
            child: Text(
              'Continue',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _homeIconBackgroundColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.greyDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyActivitySection(BuildContext context) {
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
                    'Daily Activity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Complete the daily activity checklist',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.greyDark),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(1000),
              ),
              child: const Text(
                '50%',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 0.5,
                  minHeight: 6,
                  color: AppColors.primary,
                  backgroundColor: AppColors.surfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '3/6',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.greyDark),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _ActivityTile(title: 'Alms', progress: '4/10'),
        const SizedBox(height: 12),
        const _ActivityTile(title: 'Recite the Al Quran', progress: '8/10'),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(1000),
              ),
            ),
            child: const Text('Go to Checklist'),
          ),
        ),
      ],
    );
  }
}

class PrayerTiming {
  PrayerTiming({
    required this.name,
    required this.displayTime,
    required this.dateTime,
    required this.iconData,
  });

  final String name;
  final String displayTime;
  final DateTime dateTime;
  final IconData iconData;

  PrayerTiming copyWith({DateTime? dateTime}) {
    return PrayerTiming(
      name: name,
      displayTime: displayTime,
      dateTime: dateTime ?? this.dateTime,
      iconData: iconData,
    );
  }
}

class _PrayerTimeCard extends StatelessWidget {
  const _PrayerTimeCard({required this.timing, required this.active});

  final PrayerTiming timing;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white.withAlpha(31),
        borderRadius: BorderRadius.circular(18),
      ),
      child: active
          ? ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: _buildCardContent(context),
              ),
            )
          : _buildCardContent(context),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          timing.name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: active ? _homeHeaderColor : Colors.white,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active ? _homeHeaderColor : Colors.white.withAlpha(46),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(timing.iconData, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          timing.displayTime,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.title, required this.progress});

  final String title;
  final String progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.black),
            ),
          ),
          Text(
            progress,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.circle_outlined, size: 28, color: AppColors.greyDark),
        ],
      ),
    );
  }
}

class _PrayerResponse {
  _PrayerResponse({required this.prayerTimings, required this.hijriDate});

  final List<PrayerTiming> prayerTimings;
  final String? hijriDate;
}

class _Shimmer extends StatelessWidget {
  const _Shimmer({required this.child, required this.controller});

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
