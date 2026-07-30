import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/i18n/lang_provider.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/router/app_router.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/widgets/app_button.dart';
import 'package:ustoz_trainer/core/widgets/plita_ring.dart';
import 'package:ustoz_trainer/features/auth/providers/session_provider.dart';
import 'package:ustoz_trainer/features/auth/ui/onboarding_screen.dart';

/// Splash — sessiyani tiklaydi, keyin router o'zi yo'naltiradi.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    setState(() => _error = null);

    try {
      // Onboarding hali ko'rilmagan bo'lsa — avval u.
      final Map<String, dynamic>? onboarding = await ref
          .read(localStoreProvider)
          .readJson(OnboardingScreen.storeKey);

      final bool seen = onboarding?[OnboardingScreen.seenField] == true;

      await ref.read(sessionProvider.notifier).restore();

      if (!mounted) {
        return;
      }
      // Kirilmagan va onboarding ko'rilmagan → onboarding.
      if (!seen && ref.read(sessionProvider) is SessionSignedOut) {
        context.go(Routes.onboarding);
      }
      // Qolgan hollarda router `redirect` o'z ishini qiladi.
    } on AppException catch (e) {
      // Tarmoq/server xatosi — sessiya `unknown` qoladi, qayta urinish tugmasi.
      if (mounted) {
        setState(() => _error = e.message);
      }
    } catch (_) {
      // Kutilmagan xato (JSON parse, secure-storage, platform xatosi va h.k.).
      // MUHIM: splashda JIMGINA qotib qolmasin — aks holda foydalanuvchi
      // abadiy loading ko'radi. Xato + qayta urinish ko'rsatamiz.
      if (mounted) {
        setState(() => _error = context.s.errGeneric);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x7l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const PlitaRing(value: 1, size: RingSize.profile),
              const SizedBox(height: AppSpacing.x6l),
              Text(
                s.appName,
                style: AppText.h20.copyWith(color: c.ink, letterSpacing: 2),
              ),
              if (_error != null) ...<Widget>[
                const SizedBox(height: AppSpacing.x7l),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: AppText.body14.copyWith(color: c.soft),
                ),
                const SizedBox(height: AppSpacing.xxl),
                GhostButton(
                  label: s.retry,
                  expand: false,
                  size: AppButtonSize.small,
                  onPressed: _boot,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
