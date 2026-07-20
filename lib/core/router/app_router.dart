import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ustoz_trainer/features/splash/ui/splash_screen.dart';

/// Ilova marshrutlari.
///
/// T0 da faqat splash mavjud — auth (T3), dashboard (T4) va qolganlari
/// o'z vazifalarida qo'shiladi.
abstract final class Routes {
  static const String splash = '/';
}

GoRouter createRouter() => GoRouter(
  initialLocation: Routes.splash,
  routes: <RouteBase>[
    GoRoute(
      path: Routes.splash,
      builder: (BuildContext context, GoRouterState state) =>
          const SplashScreen(),
    ),
  ],
);
