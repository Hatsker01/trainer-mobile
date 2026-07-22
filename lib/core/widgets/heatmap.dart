import 'package:flutter/material.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';

/// Davomad heatmap — dizayndagi `.heat`.
///
/// ```css
/// display:grid; grid-template-columns:repeat(14,1fr); gap:5px;
/// i { aspect-ratio:1; border-radius:4px }
/// ```
/// Dizayn izohi: "Heatmap 8 hafta x 14 (2 hafta ustun ko'rinishida 56 katak)".
///
/// Darajalar: 0 `rgba(255,255,255,.06)` · 1 `rgba(61,214,140,.25)` ·
/// 2 `rgba(61,214,140,.55)` · 3 `#3DD68C`.
class Heatmap extends StatelessWidget {
  const Heatmap({required this.levels, this.columns = 14, super.key});

  /// Har katak uchun 0..3 daraja. Dizaynda 56 ta katak (4×14).
  final List<int> levels;
  final int columns;

  /// Kunlar ro'yxatidan (`/students/{id}/attendance` → kelgan kunlar)
  /// heatmap darajalarini yasaydi.
  ///
  /// Bitta katak = bitta kun. Kelgan → 3, kelmagan → 0. Oraliq darajalar
  /// (1, 2) kunlik ma'lumotda ma'noga ega emas — backend faqat "keldi"
  /// faktini beradi, intensivlik yo'q.
  static List<int> fromDays({
    required Set<DateTime> attended,
    required DateTime end,
    int days = 56,
  }) {
    final DateTime last = DateTime(end.year, end.month, end.day);
    return List<int>.generate(days, (int i) {
      final DateTime day = last.subtract(Duration(days: days - 1 - i));
      return attended.contains(DateTime(day.year, day.month, day.day)) ? 3 : 0;
    });
  }

  static Color colorFor(int level, AppColors c) => switch (level) {
    >= 3 => c.ok,
    2 => const Color.fromRGBO(46, 204, 113, 0.55),
    1 => const Color.fromRGBO(46, 204, 113, 0.22),
    // Light rejim (H3): bo'sh katak — ochiq kulrang (oq-alpha oq fonda ko'rinmasdi).
    _ => c.glassHi,
  };

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: levels.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
          ),
          itemBuilder: (BuildContext _, int i) => DecoratedBox(
            decoration: BoxDecoration(
              color: colorFor(levels[i], c),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _Legend(colors: c),
      ],
    );
  }
}

/// "kam ▫▫▪■ ko'p" — `justify-content: flex-end`.
class _Legend extends StatelessWidget {
  const _Legend({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text('kam', style: AppText.label11.copyWith(color: colors.dim)),
        const SizedBox(width: AppSpacing.xxs),
        for (int level = 0; level <= 3; level++)
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: SizedBox(
              width: 10,
              height: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Heatmap.colorFor(level, colors),
                  borderRadius: BorderRadius.circular(AppRadius.xxs),
                ),
              ),
            ),
          ),
        const SizedBox(width: AppSpacing.xxs),
        Text("ko'p", style: AppText.label11.copyWith(color: colors.dim)),
      ],
    );
  }
}
