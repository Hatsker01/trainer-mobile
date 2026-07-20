import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ustoz_trainer/core/env.dart';
import 'package:ustoz_trainer/dev/gallery.dart';
import 'package:ustoz_trainer/features/splash/ui/splash_screen.dart';

/// Ilova marshrutlari.
///
/// Auth (T3), dashboard (T4) va qolganlari o'z vazifalarida qo'shiladi.
abstract final class Routes {
  static const String splash = '/';

  /// Dev-only komponent galereyasi (T1).
  static const String gallery = '/dev/gallery';
}

/// Galereya release buildda MAVJUD EMAS — `kDebugMode` kompilyatsiya
/// vaqtida const, shuning uchun tree-shaking uni butunlay olib tashlaydi.
bool get _devToolsEnabled => kDebugMode && Env.devTools;

GoRouter createRouter() => GoRouter(
  initialLocation: Routes.splash,
  routes: <RouteBase>[
    GoRoute(
      path: Routes.splash,
      builder: (BuildContext context, GoRouterState state) =>
          const SplashScreen(),
    ),
    if (_devToolsEnabled)
      GoRoute(
        path: Routes.gallery,
        builder: (BuildContext context, GoRouterState state) =>
            const GalleryScreen(),
      ),
  ],
);
