import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/router/app_router.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_motion.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/features/shell/ui/offline_banner.dart';

/// Asosiy qobiq: kontent + suzuvchi tabbar (REDESIGN — 4 tab, markaziy FAB yo'q).
/// Tartib: Bosh sahifa · Shogirdlar · Kalendar · Sozlamalar (D203).
class AppShell extends ConsumerWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBody: true,
      // H1 — status bar himoyasi BUTUN qobiq kontenti uchun (dashboard,
      // shogirdlar, kalendar, statistika, sozlamalar bir joyda). Past
      // tomon `false` — tabbar o'z SafeArea'siga ega + extendBody suzadi.
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            const OfflineBanner(),
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: _TabBar(location: location),
    );
  }
}

class _TabBar extends ConsumerWidget {
  const _TabBar({required this.location});

  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          0,
          AppSpacing.xxl,
          AppSpacing.xxl,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.tabBar),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: c.tabBar,
                borderRadius: BorderRadius.circular(AppRadius.tabBar),
                border: Border.all(color: c.line),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color.fromRGBO(17, 24, 39, 0.10),
                    blurRadius: 30,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _Tab(
                    icon: Icons.home_rounded,
                    label: s.navHome,
                    active: location == Routes.dashboard,
                    onTap: () => context.go(Routes.dashboard),
                  ),
                  _Tab(
                    icon: Icons.people_alt_rounded,
                    label: s.students,
                    active: location.startsWith(Routes.students),
                    onTap: () => context.go(Routes.students),
                  ),
                  _Tab(
                    icon: Icons.calendar_today_rounded,
                    label: s.calendarTitle,
                    active: location == Routes.calendar,
                    onTap: () => context.go(Routes.calendar),
                  ),
                  _Tab(
                    icon: Icons.settings_rounded,
                    label: s.navSettings,
                    active: location == Routes.settings,
                    onTap: () => context.go(Routes.settings),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color color = active ? c.anor2 : c.dim;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedContainer(
              duration: AppDuration.fast,
              curve: AppMotion.short,
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.tab105.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
