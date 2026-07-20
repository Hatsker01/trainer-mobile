import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/widgets/press_scale.dart';

/// Shisha sirt — dizayndagi `.glass` / `.glass.card`.
///
/// ```css
/// background: rgba(255,255,255,.055);
/// border: 1px solid rgba(255,255,255,.08);
/// border-radius: 20px;
/// backdrop-filter: blur(20px);
/// ```
///
/// **`backdrop-filter` haqida (D105):** default `blur: false`. Ekran foni
/// bir tekis `#0C0D10` — kartaning ortida blur qiladigan narsa yo'q, ya'ni
/// vizual farq nolga yaqin, lekin `BackdropFilter` har kadrda alohida
/// render qatlami ochadi. Scroll ro'yxatida 10+ karta = kafolatlangan jank
/// (T9 performance byudjeti). Blur FAQAT ustida kontent suzadigan joyda
/// yoqiladi: tabbar va bottom sheet.
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.cardPad),
    this.radius = AppRadius.card,
    this.borderColor,
    this.color,
    this.blur = false,
    this.onTap,
    this.overlay,
    super.key,
  });

  /// Ichki padding'siz variant (ichida o'z padding'i bor ro'yxatlar uchun).
  const GlassCard.bare({
    required this.child,
    this.radius = AppRadius.card,
    this.borderColor,
    this.color,
    this.blur = false,
    this.onTap,
    this.overlay,
    super.key,
  }) : padding = EdgeInsets.zero;

  /// Hero karta — `padding: 22px`, odatda `overlay` radial nur bilan.
  const GlassCard.hero({
    required this.child,
    this.radius = AppRadius.card,
    this.borderColor,
    this.color,
    this.blur = false,
    this.onTap,
    this.overlay,
    super.key,
  }) : padding = const EdgeInsets.all(AppSpacing.heroPad);

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// Qarzdor kartasi chegarani `rgba(255,83,64,.25)` ga o'zgartiradi.
  final Color? borderColor;
  final Color? color;
  final bool blur;
  final VoidCallback? onTap;

  /// Karta ortidagi radial nur (hero kartalarda). `Positioned.fill` ichida
  /// chiziladi va `overflow: hidden` kabi kesiladi.
  final Gradient? overlay;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final BorderRadius br = BorderRadius.circular(radius);

    Widget content = DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? c.glass,
        borderRadius: br,
        border: Border.all(color: borderColor ?? c.line),
      ),
      child: overlay == null
          ? Padding(padding: padding, child: child)
          : Stack(
              children: <Widget>[
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(gradient: overlay),
                  ),
                ),
                Padding(padding: padding, child: child),
              ],
            ),
    );

    // Overlay yoki blur bo'lsa — burchaklarni kesish shart.
    if (overlay != null || blur) {
      content = ClipRRect(
        borderRadius: br,
        child: blur
            ? BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: content,
              )
            : content,
      );
    }

    if (onTap == null) {
      return content;
    }
    return PressScale(onTap: onTap, child: content);
  }
}
