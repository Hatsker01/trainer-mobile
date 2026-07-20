import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';

/// Matn maydoni — dizayndagi `.ta` (textarea) uslubida.
///
/// ```css
/// background: --glass; border: 1px solid --line; border-radius: 16px;
/// padding: 14px; font: 14.5px; transition: border-color .15s;
/// :focus { border-color: rgba(255,83,64,.5) }
/// ```
class AppField extends StatefulWidget {
  const AppField({
    required this.controller,
    required this.label,
    this.errorText,
    this.hintText,
    this.enabled = true,
    this.autofocus = false,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.prefix,
    this.suffix,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? errorText;
  final String? hintText;
  final bool enabled;
  final bool autofocus;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final Widget? prefix;
  final Widget? suffix;
  final VoidCallback? onSubmitted;

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool hasError = widget.errorText != null;

    final Color border = hasError
        ? c.debt
        : _focus.hasFocus
        ? const Color.fromRGBO(255, 83, 64, 0.5)
        : c.line;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            bottom: AppSpacing.sm,
            left: AppSpacing.xxs,
          ),
          child: Text(
            widget.label,
            style: AppText.caption125.copyWith(color: c.soft),
          ),
        ),
        AnimatedContainer(
          duration: AppDuration.fast,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: c.glass,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(color: border),
          ),
          child: Row(
            children: <Widget>[
              if (widget.prefix != null) ...<Widget>[
                widget.prefix!,
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  enabled: widget.enabled,
                  autofocus: widget.autofocus,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  textCapitalization: widget.textCapitalization,
                  maxLines: widget.maxLines,
                  style: AppText.body145.copyWith(color: c.ink),
                  cursorColor: c.anor,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    hintStyle: AppText.body145.copyWith(color: c.dim),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (_) => widget.onSubmitted?.call(),
                ),
              ),
              if (widget.suffix != null) ...<Widget>[
                const SizedBox(width: AppSpacing.md),
                widget.suffix!,
              ],
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xs,
              left: AppSpacing.xxs,
            ),
            child: Text(
              widget.errorText!,
              style: AppText.caption12.copyWith(color: c.debt),
            ),
          ),
      ],
    );
  }
}
