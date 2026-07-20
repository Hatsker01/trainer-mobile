import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_motion.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';

/// 6 katakli OTP maydoni.
///
/// Talablar (T3): avtofokus ko'chish, **paste qo'llab-quvvatlash**,
/// noto'g'ri kodda silkinish animatsiyasi.
///
/// **Amalga oshirish.** Ko'rinib turgan 6 ta katak — shunchaki chizma.
/// Ostida BITTA ko'rinmas `TextField` turadi. Sabab: 6 ta alohida
/// `TextField` da backspace, paste va klaviatura avtotoʻldirishi
/// (SMS autofill) juda mo'rt ishlaydi; bitta maydon bularning
/// hammasini tekin beradi.
class OtpField extends StatefulWidget {
  const OtpField({
    required this.controller,
    required this.onCompleted,
    this.length = 6,
    this.hasError = false,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;

  /// Oxirgi raqam kiritilganda — avtomatik yuborish.
  final ValueChanged<String> onCompleted;

  final int length;
  final bool hasError;
  final bool enabled;

  @override
  State<OtpField> createState() => OtpFieldState();
}

class OtpFieldState extends State<OtpField>
    with SingleTickerProviderStateMixin {
  final FocusNode _focus = FocusNode();
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _focus.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
    if (widget.controller.text.length == widget.length) {
      widget.onCompleted(widget.controller.text);
    }
  }

  /// Noto'g'ri kod — silkinish + katak tozalash.
  void shake() {
    _shake.forward(from: 0);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final String value = widget.controller.text;

    return AnimatedBuilder(
      animation: _shake,
      builder: (BuildContext context, Widget? child) {
        // Sinusoidal so'nuvchi silkinish: 3 marta u yoq-bu yoq.
        final double t = _shake.value;
        final double dx = t == 0
            ? 0
            : (1 - t) * 10 * math.sin(t * 3 * 2 * math.pi);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Stack(
        children: <Widget>[
          // Ko'rinmas haqiqiy maydon — paste/autofill/backspace shu yerda.
          SizedBox(
            height: 60,
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              enabled: widget.enabled,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: widget.length,
              // SMS/Telegram avtotoʻldirishi uchun.
              autofillHints: const <String>[AutofillHints.oneTimeCode],
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.length),
              ],
              // Ko'rinmas, lekin fokuslanadigan.
              style: const TextStyle(color: Colors.transparent, height: 0.01),
              cursorColor: Colors.transparent,
              cursorWidth: 0,
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          // Chizma kataklar.
          Positioned.fill(
            child: GestureDetector(
              onTap: _focus.requestFocus,
              child: Row(
                spacing: AppSpacing.sm,
                children: <Widget>[
                  for (int i = 0; i < widget.length; i++)
                    Expanded(
                      child: _Box(
                        char: i < value.length ? value[i] : '',
                        active: i == value.length && _focus.hasFocus,
                        hasError: widget.hasError,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bitta katak.
class _Box extends StatelessWidget {
  const _Box({
    required this.char,
    required this.active,
    required this.hasError,
  });

  final String char;
  final bool active;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    final Color border = hasError
        ? c.debt
        : active
        ? c.anor
        : c.line;

    return AnimatedContainer(
      duration: AppDuration.fast,
      curve: AppMotion.short,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.glass,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: border, width: active ? 1.5 : 1),
      ),
      child: Text(
        char,
        style: AppText.money24.copyWith(color: hasError ? c.debt : c.ink),
      ),
    );
  }
}
