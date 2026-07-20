import 'package:flutter/material.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/widgets/app_button.dart';

/// Bo'sh holat: emoji + matn + ixtiyoriy CTA.
///
/// **Dizaynda YO'Q** — HTML prototipda hamma ma'lumot to'la, bo'sh holat
/// umuman chizilmagan. Shuning uchun mavjud primitivlardan yig'ildi:
/// tipografiya `AppText`, ranglar `--soft`/`--dim`, CTA — `GhostButton`.
/// Yangi rang yoki o'lcham o'ylab topilmadi.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.emoji,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
    super.key,
  });

  final String emoji;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Karta ichidagi kichik bo'sh holat (butun ekran emas).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: compact ? AppSpacing.x5l : AppSpacing.x7l,
        horizontal: AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(emoji, style: TextStyle(fontSize: compact ? 30 : 40)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppText.body15Bold.copyWith(color: c.soft),
          ),
          if (message != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: AppText.caption12.copyWith(color: c.dim),
            ),
          ],
          if (actionLabel != null && onAction != null) ...<Widget>[
            const SizedBox(height: AppSpacing.x4l),
            GhostButton(
              label: actionLabel!,
              onPressed: onAction,
              size: AppButtonSize.small,
              expand: false,
            ),
          ],
        ],
      ),
    );
  }
}
