import 'package:flutter/material.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';

/// Karta ichidagi ro'yxat qatori — dizayndagi `.lrow`.
///
/// ```css
/// display:flex; align-items:center; gap:12px; padding:14px 0;
/// border-bottom:1px solid var(--line);
/// :last-child { border-bottom: 0 }
/// ```
///
/// Oxirgi qatorning chizig'ini o'chirish uchun `ListRowGroup` ishlatiladi —
/// har bir `ListRow` ga qo'lda `last: true` berish oson unutiladi.
class ListRow extends StatelessWidget {
  const ListRow({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.last = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Guruhdagi oxirgi qator — pastki chiziq chizilmaydi.
  final bool last;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    final Widget row = Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: c.line)),
      ),
      child: Row(
        children: <Widget>[
          if (leading != null) ...<Widget>[
            leading!,
            const SizedBox(width: AppSpacing.lg),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: AppText.body14Bold.copyWith(color: c.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: AppText.caption12.copyWith(color: c.dim),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: AppSpacing.lg),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap == null) {
      return row;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: row,
    );
  }
}

/// `ListRow` guruhi — oxirgi qatorning ajratuvchi chizig'ini avtomatik oladi.
class ListRowGroup extends StatelessWidget {
  const ListRowGroup({required this.rows, super.key});

  final List<ListRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < rows.length; i++)
          ListRow(
            title: rows[i].title,
            subtitle: rows[i].subtitle,
            leading: rows[i].leading,
            trailing: rows[i].trailing,
            onTap: rows[i].onTap,
            last: i == rows.length - 1,
          ),
      ],
    );
  }
}
