import 'package:flutter/material.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';

/// Badge ohanglari — dizayndagi `.badge.ok` / `.warn` / `.debt` / neytral.
enum BadgeTone { ok, warn, debt, neutral }

/// Holat yorlig'i.
///
/// ```css
/// font: 800 11px; letter-spacing: .4px;
/// border-radius: 8px; padding: 4px 8px;
/// ```
///
/// Matn dizaynda har doim BOSH HARFDA ("QARZDOR", "BUGUN", "AKTIV") —
/// lekin CSS majburlamaydi, shuning uchun bu yerda ham majburlanmaydi:
/// i18n kalitlari o'zi bosh harfda beriladi (ba'zi ruscha matnlar
/// `toUpperCase()` da noto'g'ri ko'rinadi).
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {this.tone = BadgeTone.neutral, super.key});

  final String label;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    final (Color fg, Color bg) = switch (tone) {
      BadgeTone.ok => (c.ok, c.okSoft),
      BadgeTone.warn => (c.warn, c.warnSoft),
      BadgeTone.debt => (c.debt, c.debtSoft),
      BadgeTone.neutral => (c.soft, c.glass),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Text(
        label,
        style: AppText.badge11.copyWith(color: fg),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
