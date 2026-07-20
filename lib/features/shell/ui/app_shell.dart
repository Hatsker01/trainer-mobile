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
import 'package:ustoz_trainer/core/widgets/press_scale.dart';
import 'package:ustoz_trainer/features/attendance/ui/attendance_sheet.dart';
import 'package:ustoz_trainer/features/shell/ui/offline_banner.dart';

/// Asosiy qobiq: kontent + suzuvchi tabbar.
///
/// Dizayn (`#tabbar`): `left:16 right:16 bottom:16; height:76;
/// background: rgba(19,21,25,.72); border-radius:28; backdrop-filter:
/// blur(28px); box-shadow: 0 20px 50px rgba(0,0,0,.5)`.
/// Tartib: Asosiy · Shogirdlar · [+] · Statistika · Profil.
class AppShell extends ConsumerWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // `extendBody` — kontent tabbar ostidan o'tadi (shisha effekti
      // ko'rinishi uchun). Ekranlar pastdan `AppSpacing.screenBottom`
      // padding oladi.
      extendBody: true,
      body: Column(
        children: <Widget>[
          const OfflineBanner(),
          Expanded(child: child),
        ],
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
            // Bu yerda blur HAQIQATAN kerak: kontent tabbar ostidan
            // suzib o'tadi (D105 dagi istisno).
            filter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              height: 76,
              decoration: BoxDecoration(
                color: c.tabBar,
                borderRadius: BorderRadius.circular(AppRadius.tabBar),
                border: Border.all(color: c.line),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.5),
                    blurRadius: 50,
                    offset: Offset(0, 20),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _Tab(
                    icon: Icons.home_outlined,
                    label: s.today,
                    active: location == Routes.dashboard,
                    onTap: () => context.go(Routes.dashboard),
                  ),
                  _Tab(
                    icon: Icons.people_outline,
                    label: s.students,
                    active: location.startsWith(Routes.students),
                    onTap: () => context.go(Routes.students),
                  ),
                  const _PlusButton(),
                  _Tab(
                    icon: Icons.bar_chart_outlined,
                    label: s.stats,
                    active: location == Routes.stats,
                    onTap: () => context.go(Routes.stats),
                  ),
                  _Tab(
                    icon: Icons.person_outline,
                    label: s.profile,
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
    final Color color = active ? c.ink : c.dim;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 62,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedContainer(
              duration: AppDuration.fast,
              curve: AppMotion.short,
              child: Icon(icon, size: 22, color: color.withValues(alpha: 0.85)),
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

/// Markazdagi `+` — dizaynda tabbar ustiga chiqadi (`margin-top: -26px`)
/// va sheet ochilganda 45° buriladi.
class _PlusButton extends ConsumerStatefulWidget {
  const _PlusButton();

  @override
  ConsumerState<_PlusButton> createState() => _PlusButtonState();
}

class _PlusButtonState extends ConsumerState<_PlusButton> {
  bool _open = false;

  Future<void> _openSheet() async {
    setState(() => _open = true);
    await showAttendanceSheet(context);
    if (mounted) {
      setState(() => _open = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Transform.translate(
      offset: const Offset(0, -26),
      child: PressScale(
        onTap: _openSheet,
        child: AnimatedRotation(
          turns: _open ? 0.125 : 0,
          duration: AppDuration.fast,
          curve: AppMotion.short,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: c.anorGradient,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: c.anorGlow,
                  blurRadius: 28,
                  spreadRadius: -6,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(Icons.add, size: 26, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
