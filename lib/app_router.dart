import 'package:flutter/widgets.dart';
import 'package:muslim_mate/screens/app_shell.dart';
import 'package:muslim_mate/screens/qibla_screen.dart';

class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String almatsurat = '/almatsurat';
  static const String qibla = '/qibla';

  static Map<String, WidgetBuilder> get routes => {
        home: (context) => const AppShell(),
        almatsurat: (context) => const AppShell(initialIndex: 1),
        qibla: (context) => const QiblaScreen(),
      };
}
