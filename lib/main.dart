import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ustoz_trainer/core/router/app_router.dart';

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
      // To'liq dizayn tizimi (AppColors / AppText) — T1.
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0C0D10),
        fontFamily: 'Manrope',
      ),
    );
  }
}
