import 'package:flutter/material.dart';
import 'package:muslim_mate/features/home/presentation/screens/home_screen.dart';
import 'package:muslim_mate/features/home/presentation/widgets/home_bottom_navigation.dart';
import 'package:muslim_mate/screens/discover_screen.dart';
import 'package:muslim_mate/screens/prayer_screen.dart';
import 'package:muslim_mate/screens/profile_screen.dart';
import 'package:muslim_mate/screens/quran_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    DiscoverScreen(),
    QuranScreen(),
    PrayerScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: HomeBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
