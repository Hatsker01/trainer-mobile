import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/i18n/lang_provider.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
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

class UstozApp extends ConsumerWidget {
  const UstozApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Til o'zgarsa — `AppStringsScope` yangilanadi va BUTUN daraxt
    // qayta quriladi (T7 DoD: barcha ekran matnlari almashadi).
    final AppStrings strings = ref.watch(stringsProvider);

    return AppStringsScope(
      strings: strings,
      child: MaterialApp.router(
        title: 'USTOZ',
        debugShowCheckedModeBanner: false,
        routerConfig: ref.watch(routerProvider),
        // REDESIGN (D208): aktiv tema — light navy/emerald.
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        builder: (BuildContext context, Widget? child) {
          // textScale 1.3 gacha qo'llab-quvvatlanadi (T9 adaptivlik
          // matritsasi); undan yuqorisi qattiq balandliklarni buzadi.
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
      ),
    );
  }
}
