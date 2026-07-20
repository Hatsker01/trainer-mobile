import 'package:flutter/material.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';

/// Bo'lim sarlavhasi — dizayndagi `.sec-h`.
///
/// ```css
/// .sec-h { display:flex; align-items:baseline; margin-bottom:12px }
/// .t   { Unbounded 600 15px; letter-spacing:.2px }
/// .n   { 800 12px; color:--anor; background:rgba(255,83,64,.12);
///        border-radius:20px; padding:2px 9px; margin-left:8px }
/// .all { margin-left:auto; 600 13px; color:--dim }
/// ```
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    this.count,
    this.countTone = SectionCountTone.anor,
    this.trailing,
    this.onTrailingTap,
    super.key,
  });

  final String title;

  /// Sarlavha yonidagi hisoblagich pill.
  final int? count;
  final SectionCountTone countTone;

  /// O'ngdagi matn ("tarix", "6 oy", "+ Qo'shish").
  final String? trailing;

  /// Berilsa `trailing` anor rangda va bosiladigan bo'ladi.
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool action = onTrailingTap != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sectionHeaderGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Flexible(
            child: Text(
              title,
              style: AppText.section15.copyWith(color: c.ink),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (count != null) ...<Widget>[
            const SizedBox(width: AppSpacing.sm),
            _CountPill(count: count!, tone: countTone),
          ],
          if (trailing != null) ...<Widget>[
            const Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTrailingTap,
              child: Text(
                trailing!,
                style: AppText.body13.copyWith(color: action ? c.anor : c.dim),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Hisoblagich pill ohangi — dizaynda anor (default) va warn variantlari bor.
enum SectionCountTone { anor, warn }

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count, required this.tone});

  final int count;
  final SectionCountTone tone;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    final (Color fg, Color bg) = switch (tone) {
      SectionCountTone.anor => (
        c.anor,
        const Color.fromRGBO(255, 83, 64, 0.12),
      ),
      SectionCountTone.warn => (c.warn, c.warnSoft),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Text('$count', style: AppText.caption12Heavy.copyWith(color: fg)),
    );
  }
}

/// Bo'lim bloki — sarlavha + kontent, ustidan `margin-top: 26px`.
class AppSection extends StatelessWidget {
  const AppSection({
    required this.header,
    required this.child,
    this.first = false,
    super.key,
  });

  final SectionHeader header;
  final Widget child;

  /// Ekrandagi birinchi bo'lim tepadan qo'shimcha masofa olmaydi.
  final bool first;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: first ? 0 : AppSpacing.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[header, child],
      ),
    );
  }
}
