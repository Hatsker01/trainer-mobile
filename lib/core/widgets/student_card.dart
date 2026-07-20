import 'package:flutter/material.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/widgets/glass_card.dart';
import 'package:ustoz_trainer/core/widgets/plita_ring.dart';

/// Shogird kartasi (S5 ro'yxati) — ring + ism + tarif + badge.
///
/// Dizayn: `.glass.card` (r20, p16), `row gap:12`, 50px ring, o'ngda badge
/// va ixtiyoriy summa. Qarzdor kartasi chegarasi
/// `rgba(255,83,64,.25)` ga o'zgaradi va ro'yxatda doim tepada turadi
/// (tartibni SERVER beradi — client qayta saralamaydi).
class StudentCard extends StatelessWidget {
  const StudentCard({
    required this.name,
    required this.subtitle,
    required this.ringValue,
    required this.ringTone,
    this.badge,
    this.trailingText,
    this.ringLabel,
    this.debt = false,
    this.onTap,
    this.actions,
    super.key,
  });

  final String name;

  /// "Oylik · 400 000" yoki "Paket 12 · 9 qoldi".
  final Widget subtitle;

  final double ringValue;
  final RingTone ringTone;

  /// Ring markazidagi belgi — qarzdorlarda "!".
  final String? ringLabel;

  /// O'ngdagi holat yorlig'i.
  final Widget? badge;

  /// Badge ostidagi summa (mono, dim).
  final String? trailingText;

  final bool debt;
  final VoidCallback? onTap;

  /// Karta ostidagi amal tugmalari (dashboard "✓ To'landi" / "Eslatish").
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return GlassCard(
      onTap: onTap,
      borderColor: debt ? const Color.fromRGBO(255, 83, 64, 0.25) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Badge ustuni flex EMAS — ya'ni tabiiy kengligini oladi va
          // uzun matnda (masalan "3 KUN KECHIKDI" @ textScale 1.3) qatorni
          // yorib chiqadi. Shuning uchun kengligi qator kengligining 45%
          // bilan cheklanadi; ortig'i `StatusBadge` ichida ellipsis bo'ladi.
          LayoutBuilder(
            builder: (BuildContext _, BoxConstraints box) => Row(
              children: <Widget>[
                PlitaRing(value: ringValue, tone: ringTone, label: ringLabel),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        name,
                        style: AppText.body15Bold.copyWith(color: c.ink),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      DefaultTextStyle(
                        style: AppText.caption125.copyWith(color: c.dim),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        child: subtitle,
                      ),
                    ],
                  ),
                ),
                if (badge != null || trailingText != null) ...<Widget>[
                  const SizedBox(width: AppSpacing.sm),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: box.maxWidth * 0.45),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ?badge,
                        if (trailingText != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              trailingText!,
                              style: AppText.money12.copyWith(color: c.dim),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actions != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xl),
            actions!,
          ],
        ],
      ),
    );
  }
}
