import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ustoz_trainer/core/i18n/lang_provider.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/router/app_router.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_motion.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/widgets/app_button.dart';
import 'package:ustoz_trainer/core/widgets/plita_ring.dart';

/// Onboarding — 3 slayd, faqat BIRINCHI ochilishda.
///
/// "Ko'rildi" bayrog'i lokal saqlanadi (`LocalStore`), server bilan
/// bog'liq emas.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const String storeKey = 'onboarding';
  static const String seenField = 'seen';

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pages = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(localStoreProvider).writeJson(
      OnboardingScreen.storeKey,
      <String, dynamic>{OnboardingScreen.seenField: true},
    );
    if (mounted) {
      context.go(Routes.phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    final List<(String, String, double)> slides = <(String, String, double)>[
      (s.onb1Title, s.onb1Body, 0.35),
      (s.onb2Title, s.onb2Body, 0.68),
      (s.onb3Title, s.onb3Body, 1),
    ];

    final bool last = _index == slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _finish,
                  child: Text(
                    s.skip,
                    style: AppText.body13.copyWith(color: c.dim),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: slides.length,
                onPageChanged: (int i) => setState(() => _index = i),
                itemBuilder: (BuildContext context, int i) {
                  final (String title, String body, double progress) =
                      slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.x6l,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Dizayndagi plita-ring — brend belgisi sifatida.
                        PlitaRing(
                          value: progress,
                          size: RingSize.hero,
                          label: '${(progress * 100).round()}%',
                        ),
                        const SizedBox(height: AppSpacing.x7l),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: AppText.display24.copyWith(color: c.ink),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          body,
                          textAlign: TextAlign.center,
                          style: AppText.body14.copyWith(color: c.soft),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Nuqtalar.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (int i = 0; i < slides.length; i++)
                  AnimatedContainer(
                    duration: AppDuration.fast,
                    curve: AppMotion.short,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxs,
                    ),
                    width: i == _index ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _index ? c.anor : c.dim,
                      borderRadius: BorderRadius.circular(AppRadius.xxs),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenH),
              child: GradientButton(
                label: last ? s.onbStart : s.next,
                onPressed: () {
                  if (last) {
                    unawaited(_finish());
                  } else {
                    _pages.nextPage(
                      duration: AppDuration.screenIn,
                      curve: AppMotion.house,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
