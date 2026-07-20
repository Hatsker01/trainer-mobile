import 'package:flutter/material.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';

/// Initsialli avatar — dizayndagi `.avatar`.
///
/// ```css
/// 44×44; border-radius: 16px;
/// background: linear-gradient(145deg, #23262D, #17191E);
/// border: 1px solid --line; color: --soft;
/// font: Unbounded 600 14px;
/// ```
///
/// Qarzdor varianti: `color:#FF7A6B; border-color: rgba(255,83,64,.3)`.
///
/// Rasm YO'Q — MVP da shogird fotosi yuklanmaydi (spec §9), initsial yetarli.
class Avatar extends StatelessWidget {
  const Avatar(this.name, {this.size = 44, this.debt = false, super.key});

  /// Ro'yxat qatorlaridagi kichik variant (38×38, 12px shrift).
  const Avatar.small(this.name, {this.debt = false, super.key}) : size = 38;

  final String name;
  final double size;
  final bool debt;

  /// Ism → initsial. "Aziz Karimov" → "AK", "Aziz" → "A".
  ///
  /// Bo'sh/probelli ism ham xavfsiz — `?` qaytadi, hech qachon crash emas.
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

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: c.avatarGradient,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: debt ? const Color.fromRGBO(255, 83, 64, 0.3) : c.line,
        ),
      ),
      child: Text(
        initialsOf(name),
        style: (size >= 44 ? AppText.avatar14 : AppText.avatar12).copyWith(
          color: debt ? c.debt : c.soft,
        ),
      ),
    );
  }
}
