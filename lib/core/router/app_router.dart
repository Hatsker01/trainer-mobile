import 'package:flutter/foundation.dart' show ChangeNotifier, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ustoz_trainer/core/env.dart';
import 'package:ustoz_trainer/dev/gallery.dart';
import 'package:ustoz_trainer/features/auth/providers/session_provider.dart';
import 'package:ustoz_trainer/features/auth/ui/onboarding_screen.dart';
import 'package:ustoz_trainer/features/auth/ui/otp_screen.dart';
import 'package:ustoz_trainer/features/auth/ui/phone_screen.dart';
import 'package:ustoz_trainer/features/auth/ui/profile_setup_screen.dart';
import 'package:ustoz_trainer/features/dashboard/ui/dashboard_screen.dart';
import 'package:ustoz_trainer/features/settings/ui/settings_screen.dart';
import 'package:ustoz_trainer/features/shell/ui/app_shell.dart';
import 'package:ustoz_trainer/features/splash/ui/splash_screen.dart';
import 'package:ustoz_trainer/features/stats/ui/stats_screen.dart';
import 'package:ustoz_trainer/features/students/ui/student_form_screen.dart';
import 'package:ustoz_trainer/features/students/ui/student_profile_screen.dart';
import 'package:ustoz_trainer/features/students/ui/students_screen.dart';

abstract final class Routes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String phone = '/phone';
  static const String otp = '/otp';
  static const String profileSetup = '/profile-setup';

  static const String dashboard = '/dashboard';
  static const String students = '/students';
  static const String studentNew = '/students/new';
  static const String stats = '/stats';
  static const String settings = '/settings';

  /// `/students/:id`.
  static String student(String id) => '/students/$id';

  /// Dev-only komponent galereyasi (T1).
  static const String gallery = '/dev/gallery';
}

/// Galereya release buildda MAVJUD EMAS — `kDebugMode` kompilyatsiya
/// vaqtida const, shuning uchun tree-shaking uni butunlay olib tashlaydi.
bool get _devToolsEnabled => kDebugMode && Env.devTools;

/// Riverpod holatini `GoRouter` ga ulash.
///
/// `refreshListenable` `Listenable` kutadi, Riverpod esa provider beradi —
/// shu ko'prik ularni bog'laydi.
class _SessionListenable extends ChangeNotifier {
  _SessionListenable(this._ref) {
    _ref.listen<SessionState>(
      sessionProvider,
      (SessionState? _, SessionState _) => notifyListeners(),
    );
  }

  final Ref _ref;
}

final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final _SessionListenable listenable = _SessionListenable(ref);
  ref.onDispose(listenable.dispose);

  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: listenable,
    redirect: (BuildContext context, GoRouterState state) {
      final SessionState session = ref.read(sessionProvider);
      final String location = state.matchedLocation;

      // Dev galereyasi hech qanday redirect'ga bo'ysunmaydi.
      if (location == Routes.gallery) {
        return null;
      }

      final bool inAuthFlow =
          location == Routes.onboarding ||
          location == Routes.phone ||
          location == Routes.otp;

      return switch (session) {
        // Splash tokenlarni tekshirmoqda — hech qayerga tegmaymiz.
        SessionUnknown() => location == Routes.splash ? null : Routes.splash,

        // Kirilmagan: auth oqimidan tashqarida bo'lsa — telefonga.
        SessionSignedOut() => inAuthFlow ? null : Routes.phone,

        // Kirilgan, lekin profil to'ldirilmagan (`is_new_user`).
        SessionActive(needsProfile: true) =>
          location == Routes.profileSetup ? null : Routes.profileSetup,

        // To'liq kirilgan: auth/splash sahifalarida qolmasin.
        SessionActive() =>
          inAuthFlow ||
                  location == Routes.splash ||
                  location == Routes.profileSetup
              ? Routes.dashboard
              : null,
      };
    },
    routes: <RouteBase>[
      GoRoute(
        path: Routes.splash,
        builder: (BuildContext _, GoRouterState _) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (BuildContext _, GoRouterState _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.phone,
        builder: (BuildContext _, GoRouterState _) => const PhoneScreen(),
      ),
      GoRoute(
        path: Routes.otp,
        builder: (BuildContext _, GoRouterState _) => const OtpScreen(),
      ),
      GoRoute(
        path: Routes.profileSetup,
        builder: (BuildContext _, GoRouterState _) =>
            const ProfileSetupScreen(),
      ),

      // Asosiy qism — pastki navigatsiya bilan umumiy qobiq.
      ShellRoute(
        builder: (BuildContext _, GoRouterState state, Widget child) =>
            AppShell(location: state.matchedLocation, child: child),
        routes: <RouteBase>[
          GoRoute(
            path: Routes.dashboard,
            builder: (BuildContext _, GoRouterState _) =>
                const DashboardScreen(),
          ),
          GoRoute(
            path: Routes.students,
            builder: (BuildContext _, GoRouterState _) =>
                const StudentsScreen(),
          ),
          GoRoute(
            path: Routes.stats,
            builder: (BuildContext _, GoRouterState _) => const StatsScreen(),
          ),
          GoRoute(
            path: Routes.settings,
            builder: (BuildContext _, GoRouterState _) =>
                const SettingsScreen(),
          ),
        ],
      ),

      // Qobiqdan tashqari (to'liq ekran) sahifalar.
      GoRoute(
        path: Routes.studentNew,
        builder: (BuildContext _, GoRouterState _) => const StudentFormScreen(),
      ),
      GoRoute(
        path: '/students/:id',
        builder: (BuildContext _, GoRouterState state) =>
            StudentProfileScreen(id: state.pathParameters['id']!),
      ),

      if (_devToolsEnabled)
        GoRoute(
          path: Routes.gallery,
          builder: (BuildContext _, GoRouterState _) => const GalleryScreen(),
        ),
    ],
  );
});
