import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ustoz_trainer/core/router/app_router.dart';
import 'package:ustoz_trainer/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait-only (MVP, brief T0). Platforma manifestlarida ham qotirilgan —
  // bu ikkinchi himoya qatlami.
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  runApp(const ProviderScope(child: UstozApp()));
}

class UstozApp extends StatefulWidget {
  const UstozApp({super.key});

  @override
  State<UstozApp> createState() => _UstozAppState();
}

class _UstozAppState extends State<UstozApp> {
  // Router bir marta quriladi — build'da qayta yaratilsa navigatsiya tarixi yo'qoladi.
  late final GoRouter _router = createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'USTOZ',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: AppTheme.dark,
      // MVP dark-only (spec §9) — tizim sozlamasi qanday bo'lsa ham.
      themeMode: ThemeMode.dark,
      builder: (BuildContext context, Widget? child) {
        // textScale 1.3 gacha qo'llab-quvvatlanadi (T9 adaptivlik matritsasi);
        // undan yuqorisi qattiq balandlikdagi elementlarni buzadi.
        final MediaQueryData mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(
              minScaleFactor: 1,
              maxScaleFactor: 1.3,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
