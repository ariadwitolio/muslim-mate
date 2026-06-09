import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslim_mate/constants/index.dart';
import 'package:muslim_mate/features/prayer/presentation/cubit/prayer_cubit.dart';
import 'package:muslim_mate/features/prayer/presentation/cubit/prayer_state.dart';
import 'package:muslim_mate/features/prayer/domain/entities/prayer_timing.dart';

class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Prayer Time', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
            Chip(
              label: Row(
                children: const [
                  Icon(Icons.location_on, size: 16, color: Color(0xFF0E8B8B)),
                  SizedBox(width: 6),
                  Text('Sumedang, West Java', style: TextStyle(color: Color(0xFF0E8B8B))),
                ],
              ),
              backgroundColor: const Color(0xFFE6F7F7),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<PrayerCubit, PrayerState>(
          builder: (context, state) {
            final timings = state.prayerTimings;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Calendar header
                Center(
                  child: Text(state.hijriDate.isNotEmpty ? state.hijriDate : 'Ramadhan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: _buildCalendarPreview(),
                ),

                const SizedBox(height: 16),

                // Prayer times header + location
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Prayer Time', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    Chip(
                      label: Text(state.locationLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF0E8B8B))),
                      backgroundColor: const Color(0xFFE6F7F7),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Get accurate prayer times based on your location', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.grey)),

                const SizedBox(height: 12),

                // Prayer times list
                Expanded(
                  child: Card(
                    elevation: 0,
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: timings.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final PrayerTiming item = timings[index];
                        final activePrayer = BlocProvider.of<PrayerCubit>(context).currentPrayer(DateTime.now());
                        final isActive = activePrayer != null && activePrayer.name == item.name;
                        // Show countdown subtitle for next prayer if applicable
                        final subtitle = (item.name.toLowerCase() == 'asr') ? Text('Ashr in 01:09:59', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primaryLight)) : null;
                        return Container(
                          color: isActive ? const Color(0xFFE6FBFA) : Colors.transparent,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Icon(
                                _iconForPrayer(item.name),
                                color: Colors.black54,
                                size: 22,
                              ),
                            ),
                            title: Text(item.name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                            subtitle: subtitle,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(item.displayTime, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(width: 12),
                                Icon(Icons.volume_up, color: const Color(0xFF0E8B8B)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarPreview() {
    // Simple calendar grid preview to approximate the Figma screenshot
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 24),
            Text('10', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const Spacer(),
            const Icon(Icons.chevron_left),
            const Icon(Icons.chevron_right),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekdays.map((d) => Text(d, style: const TextStyle(fontSize: 12, color: Colors.black54))).toList(),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4, childAspectRatio: 1.6),
            itemCount: 35,
            itemBuilder: (context, index) {
              final day = index - 3; // offset to simulate
              final isActiveDay = day == 10;
              return Center(
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: isActiveDay ? BoxDecoration(color: const Color(0xFF0EB0AD), shape: BoxShape.circle) : null,
                  child: Center(
                    child: Text(
                      day > 0 ? day.toString() : '',
                      style: TextStyle(color: isActiveDay ? Colors.white : Colors.black54),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _iconForPrayer(String label) {
    switch (label.toLowerCase()) {
      case 'imsak':
        return Icons.bedtime;
      case 'subuh':
        return Icons.wb_twilight; // approximate
      case 'fajr':
        return Icons.wb_sunny;
      case 'sunrise':
        return Icons.wb_sunny;
      case 'dhuhr':
        return Icons.wb_sunny_outlined;
      case 'asr':
        return Icons.wb_sunny_outlined;
      case 'maghrib':
        return Icons.nights_stay;
      case 'isha':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }
}
