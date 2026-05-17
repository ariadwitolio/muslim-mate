import 'package:flutter/material.dart';
import 'package:muslim_mate/app_router.dart';
import 'package:muslim_mate/constants/index.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muslim Mate',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRouter.home,
      routes: AppRouter.routes,
    );
  }
}
