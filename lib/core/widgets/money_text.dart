import 'package:flutter/material.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/utils/money.dart';

/// G1 — pul KO'RSATISHNING yagona komponenti.
///
/// Qoida (brief G1): raqam asosiy o'lchamda, `so'm` suffiks ~57% o'lchamda va
/// soft rangda. Minglik ajratgich — probel (`Money` util). Vergul YO'Q.
///
/// [compact] `true` bo'lsa millionlar `mln` ga qisqaradi (KPI/hero/ro'yxat).
/// [showUnit] `false` bo'lsa suffiks chizilmaydi (masalan sof son ustunlar).
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.amount, {
    required this.style,
    this.color,
    this.compact = false,
    this.showUnit = true,
    this.unitColor,
    this.maxLines = 1,
    super.key,
  });

  final int amount;
  final TextStyle style;
  final Color? color;
  final bool compact;
  final bool showUnit;
  final Color? unitColor;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color numColor = color ?? c.ink;
    final String number = compact
        ? Money.compact(amount)
        : Money.format(amount);

    final double baseSize = style.fontSize ?? 16;
    // Suffiks — asosiy o'lchamning ~57% i, soft rang (G1 spetsifikatsiyasi).
    final TextStyle unitStyle = style.copyWith(
      fontSize: baseSize * 0.57,
      fontWeight: FontWeight.w600,
      color: unitColor ?? c.soft,
    );

    if (!showUnit) {
      return Text(
        number,
        style: style.copyWith(color: numColor),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(
            text: number,
            style: style.copyWith(color: numColor),
          ),
          // Uzilmas probel — raqam va suffiks bir qatorda qoladi.
          TextSpan(text: ' ${Money.unit}', style: unitStyle),
        ],
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
