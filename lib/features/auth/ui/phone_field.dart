import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';

/// `+998 90 123 45 67` niqobi.
///
/// Kontrakt: telefon `+998XXXXXXXXX` — 13 belgi, probelsiz. Foydalanuvchi
/// FAQAT 9 raqam kiritadi, `+998` o'zgarmas prefiks sifatida ko'rsatiladi.
class PhoneInputFormatter extends TextInputFormatter {
  const PhoneInputFormatter();

  /// `901234567` → `90 123 45 67` (2-3-2-2 guruhlash).
  static String format(String digits) {
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5 || i == 7) {
        out.write(' ');
      }
      out.write(digits[i]);
    }
    return out.toString();
  }

  /// Niqobdan xom raqamlarni ajratish.
  static String digitsOf(String text) => text.replaceAll(RegExp(r'\D'), '');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digits = digitsOf(newValue.text).characters.take(9).toString();
    final String formatted = format(digits);

    return TextEditingValue(
      text: formatted,
      // Kursor har doim oxirida — o'rtaga yozish niqobni buzadi.
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// `+998` prefiksli telefon maydoni.
class PhoneField extends StatelessWidget {
  const PhoneField({
    required this.controller,
    required this.onSubmitted,
    this.errorText,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onSubmitted;
  final String? errorText;
  final bool enabled;

  /// Kontrakt formatiga keltirish: `+998901234567`.
  static String toE164(String maskedText) =>
      '+998${PhoneInputFormatter.digitsOf(maskedText)}';

  static bool isComplete(String maskedText) =>
      PhoneInputFormatter.digitsOf(maskedText).length == 9;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            color: c.glass,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(color: errorText != null ? c.debt : c.line),
          ),
          child: Row(
            children: <Widget>[
              Text('+998', style: AppText.money17.copyWith(color: c.soft)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  style: AppText.money17.copyWith(color: c.ink),
                  cursorColor: c.anor,
                  inputFormatters: const <TextInputFormatter>[
                    PhoneInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: '90 123 45 67',
                    hintStyle: AppText.money17.copyWith(color: c.dim),
                  ),
                  onSubmitted: (_) => onSubmitted(),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.sm,
              left: AppSpacing.xxs,
            ),
            child: Text(
              errorText!,
              style: AppText.caption12.copyWith(color: c.debt),
            ),
          ),
      ],
    );
  }
}
