import 'package:flutter/material.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';

/// Avatar (REDESIGN, root-1-11/17): DOIRA. Foto (`url`) yoki fallback —
/// navy-tint doira + bosh harflar (navy). `url` null bo'lsa initsiallar.
///
/// Konstruktorlar orqaga mos: `Avatar(name)` / `Avatar.small(name)`.
class Avatar extends StatelessWidget {
  const Avatar(
    this.name, {
    this.size = 44,
    this.debt = false,
    this.url,
    super.key,
  });

  /// Ro'yxat qatorlaridagi kichik variant (38×38).
  const Avatar.small(this.name, {this.debt = false, this.url, super.key})
    : size = 38;

  final String name;
  final double size;
  final bool debt;
  final String? url;

  /// Ism → initsial. "Aziz Karimov" → "AK", "Aziz" → "A".
  static String initialsOf(String name) {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    return (parts[0].characters.first + parts[1].characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    if (url != null && url!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
              _fallback(c),
        ),
      );
    }
    return _fallback(c);
  }

  Widget _fallback(AppColors c) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: c.avatarGradient,
        shape: BoxShape.circle,
        border: Border.all(
          color: debt ? c.debt.withValues(alpha: 0.35) : c.line,
        ),
      ),
      child: Text(
        initialsOf(name),
        style: (size >= 44 ? AppText.avatar14 : AppText.avatar12).copyWith(
          color: debt ? c.debt : c.anor2,
        ),
      ),
    );
  }
}
