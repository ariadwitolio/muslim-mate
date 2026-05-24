import 'package:go_router/go_router.dart';
import 'package:muslim_mate/app/shell/app_shell.dart';
import 'package:muslim_mate/features/qibla/presentation/pages/qibla_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String almatsurat = '/almatsurat';
  static const String qibla = '/qibla';
}

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: <GoRoute>[
      GoRoute(
        name: AppRoutes.home,
        path: AppRoutes.home,
        builder: (context, state) => const AppShell(),
      ),
      GoRoute(
        name: AppRoutes.almatsurat,
        path: AppRoutes.almatsurat,
        builder: (context, state) => const AppShell(initialIndex: 1),
      ),
      GoRoute(
        name: AppRoutes.qibla,
        path: AppRoutes.qibla,
        builder: (context, state) => const QiblaScreen(),
      ),
    ],
  );
}
