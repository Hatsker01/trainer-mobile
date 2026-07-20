import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_motion.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';

/// Grafik ustuni ma'lumoti.
class BarDatum {
  const BarDatum({required this.label, required this.value, this.hot = false});

  /// Oy yorlig'i ("Iyl").
  final String label;

  /// Xom qiymat (so'm). Balandlik eng katta qiymatga nisbatan hisoblanadi.
  final int value;

  /// Joriy oy — anor gradient + glow bilan ajratiladi.
  final bool hot;
}

/// 6 oylik daromad grafigi — dizayndagi `.bars`.
///
/// ```css
/// .bars { display:flex; align-items:flex-end; gap:12px; height:140px; padding-top:8px }
/// .fill { border-radius:10px 10px 6px 6px; min-height:8px;
///         background: linear-gradient(180deg, rgba(255,255,255,.16), rgba(255,255,255,.05));
///         transition: height 1s cubic-bezier(.2,.8,.2,1) }
/// .b.hot .fill { background: linear-gradient(180deg,#FF5340,#E2264B);
///                box-shadow: 0 8px 24px -6px rgba(255,83,64,.35) }
/// ```
class MiniBarChart extends StatelessWidget {
  const MiniBarChart({
    required this.data,
    this.onTap,
    this.selectedIndex,
    this.height = 140,
    super.key,
  });

  final List<BarDatum> data;

  /// Ustunga bosilganda — oy summasi tooltip'i uchun (T7).
  final ValueChanged<int>? onTap;
  final int? selectedIndex;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(height: height);
    }

    // Nolga bo'linishdan himoya: hamma qiymat 0 bo'lsa ham ustunlar
    // `min-height: 8px` bilan ko'rinadi.
    final int max = data.map((BarDatum d) => d.value).reduce(math.max);

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: AppSpacing.lg,
          children: <Widget>[
            for (int i = 0; i < data.length; i++)
              Expanded(
                child: _Bar(
                  datum: data[i],
                  fraction: max == 0 ? 0 : data[i].value / max,
                  selected: selectedIndex == i,
                  onTap: onTap == null ? null : () => onTap!(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.datum,
    required this.fraction,
    required this.selected,
    required this.onTap,
  });

  final BarDatum datum;
  final double fraction;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool hot = datum.hot || selected;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext _, BoxConstraints box) {
                final double target = (box.maxHeight * fraction).clamp(
                  8.0,
                  box.maxHeight,
                );

                return Align(
                  alignment: Alignment.bottomCenter,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: target),
                    duration: AppDuration.chart,
                    curve: AppMotion.house,
                    builder: (BuildContext _, double h, Widget? _) => Container(
                      height: h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: hot
                            ? LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: <Color>[c.anor, c.anor2],
                              )
                            : const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: <Color>[
                                  Color.fromRGBO(255, 255, 255, 0.16),
                                  Color.fromRGBO(255, 255, 255, 0.05),
                                ],
                              ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppRadius.md),
                          bottom: Radius.circular(AppRadius.sm),
                        ),
                        boxShadow: hot
                            ? <BoxShadow>[
                                BoxShadow(
                                  color: c.anorGlow,
                                  blurRadius: 24,
                                  spreadRadius: -6,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            datum.label,
            style: AppText.label11.copyWith(color: hot ? c.ink : c.dim),
          ),
        ],
      ),
    );
  }
}
