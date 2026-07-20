import 'package:flutter/material.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';

/// Filtr chip — dizayndagi `.chip` / `.chip.on`.
///
/// ```css
/// font: 700 13px; color: --soft;
/// background: --glass; border: 1px solid --line;
/// border-radius: 20px; padding: 8px 14px;
/// transition: .15s;
/// .chip.on { color:#fff; background: linear-gradient(135deg,#FF5340,#E2264B);
///            border-color: transparent }
/// ```
///
/// `count` berilsa yoniga hisoblagich qo'yiladi (`.chip b`:
/// `opacity:.65; font-weight:800; margin-left:4px`).
class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
    this.labelColor,
    this.expand = false,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// Filtr chiplaridagi son ("Hammasi 23").
  final int? count;

  /// Tanlanmagan holatdagi matn rangi — "Qarzdor" chipi `debt` rangida.
  final Color? labelColor;

  /// To'lov usuli chiplari `flex: 1` bilan teng kenglikda joylashadi.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color fg = selected ? Colors.white : (labelColor ?? c.soft);

    final Widget content = AnimatedContainer(
      duration: AppDuration.fast,
      curve: Curves.ease,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: selected ? null : c.glass,
        gradient: selected ? c.anorGradient : null,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: selected ? Colors.transparent : c.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            label,
            style: AppText.body13Bold.copyWith(color: fg),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (count != null) ...<Widget>[
            const SizedBox(width: AppSpacing.xxs),
            Text(
              '$count',
              style: AppText.body13Bold.copyWith(
                color: fg.withValues(alpha: 0.65),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );

    final Widget tappable = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: content,
    );

    return expand ? Expanded(child: tappable) : tappable;
  }
}

/// Chiplar qatori — gorizontal scroll, `gap: 8px`, scrollbar yashirin.
class AppChipRow extends StatelessWidget {
  const AppChipRow({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 2),
      physics: const BouncingScrollPhysics(),
      child: Row(spacing: AppSpacing.sm, children: children),
    );
  }
}
