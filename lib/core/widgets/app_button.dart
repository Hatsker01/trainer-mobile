import 'package:flutter/material.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/widgets/press_scale.dart';

/// Tugma o'lchamlari — dizayndagi `.btn` va `.btn.sm`.
enum AppButtonSize {
  /// `height: 54; border-radius: 18; font: 700 15px` — asosiy CTA.
  normal(height: 54, radius: AppRadius.button, style: AppText.body15Bold),

  /// `height: 38; border-radius: 12; font: 700 13px; padding: 0 14px`.
  small(height: 38, radius: AppRadius.lg, style: AppText.body13Bold);

  const AppButtonSize({
    required this.height,
    required this.radius,
    required this.style,
  });

  final double height;
  final double radius;
  final TextStyle style;
}

/// Asosiy CTA — anor gradient + glow.
///
/// ```css
/// background: linear-gradient(135deg, #FF5340, #E2264B);
/// box-shadow: 0 12px 30px -8px rgba(255,83,64,.35),
///             inset 0 1px 0 rgba(255,255,255,.25);
/// ```
///
/// **Double-tap himoyasi (T6):** `loading: true` bo'lganda `onPressed`
/// uzib qo'yiladi — pul operatsiyalarida ikki marta yuborish mumkin emas.
class GradientButton extends StatelessWidget {
  const GradientButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.size = AppButtonSize.normal,
    this.expand = true,
    this.loading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final AppButtonSize size;

  /// `width: 100%` (asosiy) yoki kontent bo'yicha (`.btn.sm` inline).
  final bool expand;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool enabled = onPressed != null && !loading;

    return PressScale(
      onTap: enabled ? onPressed : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: Container(
          height: size.height,
          width: expand ? double.infinity : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size.radius),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: c.anorGlow,
                blurRadius: 30,
                spreadRadius: -8,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size.radius),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(gradient: c.anorGradient),
                  ),
                ),
                // `inset 0 1px 0 rgba(255,255,255,.25)` — yuqoridagi nur chizig'i.
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1,
                  child: ColoredBox(color: Color.fromRGBO(255, 255, 255, 0.25)),
                ),
                Positioned.fill(
                  child: Center(
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : _ButtonLabel(
                            label: label,
                            icon: icon,
                            size: size,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ikkilamchi tugma — `.btn.ghost`: shisha fon, chegara, soya YO'Q.
class GhostButton extends StatelessWidget {
  const GhostButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.size = AppButtonSize.normal,
    this.expand = true,
    this.color,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final AppButtonSize size;
  final bool expand;

  /// Matn rangi — default `--ink`. Xavfli amallar uchun `debt` beriladi.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool enabled = onPressed != null;

    return PressScale(
      onTap: onPressed,
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: Container(
          height: size.height,
          width: expand ? double.infinity : null,
          padding: expand
              ? null
              : const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          decoration: BoxDecoration(
            color: c.glass,
            borderRadius: BorderRadius.circular(size.radius),
            border: Border.all(color: c.line),
          ),
          child: Center(
            child: _ButtonLabel(
              label: label,
              icon: icon,
              size: size,
              color: color ?? c.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// Kvadrat ikonka tugmasi — orqaga (40×40, r14), sheet yopish (36×36, r12),
/// qo'ng'iroq (44×h, r12). Ghost uslubida.
class GhostIconButton extends StatelessWidget {
  const GhostIconButton({
    required this.child,
    required this.onPressed,
    this.size = 40,
    this.radius = AppRadius.xl,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return PressScale(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.glass,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: c.line),
        ),
        child: child,
      ),
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({
    required this.label,
    required this.icon,
    required this.size,
    required this.color,
  });

  final String label;
  final Widget? icon;
  final AppButtonSize size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final Text text = Text(
      label,
      style: size.style.copyWith(color: color),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (icon == null) {
      return text;
    }
    // `.btn { gap: 8px }`
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconTheme.merge(
          data: IconThemeData(color: color, size: 16),
          child: icon!,
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(child: text),
      ],
    );
  }
}
