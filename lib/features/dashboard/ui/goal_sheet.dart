import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/dto/auth_dto.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/providers.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/utils/money.dart';
import 'package:ustoz_trainer/core/widgets/app_bottom_sheet.dart';
import 'package:ustoz_trainer/core/widgets/app_button.dart';
import 'package:ustoz_trainer/core/widgets/app_field.dart';
import 'package:ustoz_trainer/core/widgets/app_toast.dart';
import 'package:ustoz_trainer/features/auth/providers/session_provider.dart';

/// G4 — oylik maqsad kiritish/tahrirlash sheeti. Saqlangач `PATCH /me`
/// (`monthly_goal`) va sessiya yangilanadi.
Future<void> showGoalSheet(BuildContext context, {int? current}) =>
    showAppSheet<void>(
      context: context,
      title: context.s.setGoal,
      child: _GoalSheet(current: current),
    );

class _GoalSheet extends ConsumerStatefulWidget {
  const _GoalSheet({this.current});

  final int? current;

  @override
  ConsumerState<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends ConsumerState<_GoalSheet> {
  late final TextEditingController _c = TextEditingController(
    text: widget.current == null ? '' : Money.format(widget.current!),
  );
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  int get _value => int.tryParse(_c.text.replaceAll(RegExp(r'\D'), '')) ?? 0;

  Future<void> _save() async {
    final AppStrings s = context.s;
    if (_value <= 0) {
      setState(() => _error = s.fieldRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final Me me = await ref
          .read(meRepositoryProvider)
          .updateMe(MeUpdate(monthlyGoal: _value));
      ref.read(sessionProvider.notifier).setMe(me);
      if (mounted) {
        Navigator.of(context).pop();
        AppToast.show(context, s.done);
      }
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(s.setGoalPrompt, style: AppText.body14.copyWith(color: c.soft)),
        const SizedBox(height: AppSpacing.lg),
        AppField(
          controller: _c,
          label: s.monthlyGoalLabel,
          hintText: '10 000 000',
          autofocus: true,
          enabled: !_busy,
          errorText: _error,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            _ThousandsFormatter(),
          ],
          suffix: Text(
            Money.unit,
            style: AppText.body14.copyWith(color: c.soft),
          ),
          onSubmitted: _save,
        ),
        const SizedBox(height: AppSpacing.x4l),
        GradientButton(
          label: s.save,
          onPressed: _busy ? null : _save,
          loading: _busy,
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

/// Jonli minglik ajratish (probel) — pul maydonlari uchun.
class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final String formatted = Money.format(int.parse(digits));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
