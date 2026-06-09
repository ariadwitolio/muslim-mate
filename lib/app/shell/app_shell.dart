import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslim_mate/features/home/presentation/screens/home_screen.dart';
import 'package:muslim_mate/features/home/presentation/widgets/home_bottom_navigation.dart';
import 'package:muslim_mate/features/dzikir/presentation/pages/almatsurat_page.dart';
import 'package:muslim_mate/features/prayer/presentation/pages/prayer_page.dart';
import 'package:muslim_mate/features/profile/presentation/pages/profile_page.dart';
import 'package:muslim_mate/features/quran/presentation/pages/quran_page.dart';
import 'package:muslim_mate/core/services/injection.dart';
import 'package:muslim_mate/features/prayer/presentation/cubit/prayer_cubit.dart';
import 'package:muslim_mate/features/prayer/data/sources/location_data_source.dart';
import 'package:muslim_mate/features/prayer/domain/repositories/prayer_repository.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _selectedIndex;

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    AlMatsuratScreen(),
    QuranScreen(),
    PrayerScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          // Provide a shared PrayerCubit for Home and Prayer pages
          PrayerCubit(sl<PrayerRepository>(), sl<LocationDataSource>())..loadPrayerTimes(),
      child: Scaffold(
        body: SafeArea(
          child: _pages[_selectedIndex],
        ),
        bottomNavigationBar: HomeBottomNavigation(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
