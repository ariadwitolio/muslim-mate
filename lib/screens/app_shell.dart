import 'package:flutter/material.dart';
import 'package:muslim_mate/constants/index.dart';
import 'package:muslim_mate/screens/discover_screen.dart';
import 'package:muslim_mate/screens/home_screen.dart';
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

  static const List<BottomNavigationBarItem> _navigationItems = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.explore_outlined),
      activeIcon: Icon(Icons.explore),
      label: 'Discover',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.book_outlined),
      activeIcon: Icon(Icons.book),
      label: 'Quran',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.access_time_outlined),
      activeIcon: Icon(Icons.access_time),
      label: 'Prayer',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ),
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
      bottomNavigationBar: BottomNavigationBar(
        items: _navigationItems,
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.greyDark,
        backgroundColor: AppColors.surface,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
