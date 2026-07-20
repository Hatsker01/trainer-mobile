import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
import 'package:ustoz_trainer/core/api/dto/payment_dto.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/providers.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/utils/money.dart';
import 'package:ustoz_trainer/core/widgets/app_bottom_sheet.dart';
import 'package:ustoz_trainer/core/widgets/app_button.dart';
import 'package:ustoz_trainer/core/widgets/app_chip.dart';
import 'package:ustoz_trainer/core/widgets/app_toast.dart';
import 'package:ustoz_trainer/core/widgets/avatar.dart';
import 'package:ustoz_trainer/core/widgets/glass_card.dart';

/// To'lov sheeti (S8). `true` qaytsa — to'lov saqlandi.
Future<bool?> showPaymentSheet(
  BuildContext context, {
  required String studentId,
  required String studentName,
  required int amount,
  TariffType tariffType = TariffType.monthly,
}) => showAppSheet<bool>(
  context: context,
  title: context.s.addPayment,
  child: PaymentSheet(
    studentId: studentId,
    studentName: studentName,
    amount: amount,
    tariffType: tariffType,
  ),
);

/// **Pul nuqtasi — maksimal ehtiyot.**
///
/// Himoyalar:
/// * tugma `busy` da bloklanadi (double-tap);
/// * `Idempotency-Key` — sheet ochilganda BIR MARTA generatsiya qilinadi,
///   qayta urinishda ham AYNAN o'sha kalit ketadi, ya'ni server takroriy
///   to'lov yaratmaydi (kontrakt: bir xil kalit → asl to'lov, 201);
/// * summa faqat raqam, jonli minglik ajratish;
/// * 422 maydon xatolari sheet ICHIDA ko'rsatiladi.
class PaymentSheet extends ConsumerStatefulWidget {
  const PaymentSheet({
    required this.studentId,
    required this.studentName,
    required this.amount,
    required this.tariffType,
    super.key,
  });

  final String studentId;
  final String studentName;
  final int amount;
  final TariffType tariffType;

  @override
  ConsumerState<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<PaymentSheet> {
  late final TextEditingController _amount = TextEditingController(
    text: Money.format(widget.amount),
  );

  /// Sheet ochilganda bir marta — qayta urinishlarda O'ZGARMAYDI.
  late final String _idempotencyKey =
      'pay-${widget.studentId}-${DateTime.now().microsecondsSinceEpoch}';

  PaymentMethod _method = PaymentMethod.cash;
  DateTime _paidAt = DateTime.now();
  bool _busy = false;
  String? _amountError;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  int get _amountValue =>
      int.tryParse(_amount.text.replaceAll(RegExp(r'\D'), '')) ?? 0;

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paidAt,
      // Kelajakdagi to'lov qayd etilmaydi.
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() => _paidAt = picked);
    }
  }

  Future<void> _save() async {
    if (_busy) {
      return;
    }
    final AppStrings s = context.s;

    if (_amountValue <= 0) {
      setState(() => _amountError = s.fieldRequired);
      return;
    }

    setState(() {
      _busy = true;
      _amountError = null;
    });

    try {
      final PaymentCreated created = await ref
          .read(paymentRepositoryProvider)
          .create(
            PaymentCreate(
              studentId: widget.studentId,
              amount: _amountValue,
              method: _method,
              paidAt: _paidAt,
            ),
            idempotencyKey: _idempotencyKey,
          );

      if (!mounted) {
        return;
      }
      final DateTime? next = created.student.nextDueDate;
      Navigator.of(context).pop(true);
      AppToast.show(
        context,
        s.paymentSaved(next == null ? null : s.fullDate(next)),
      );
    } on ValidationException catch (e) {
      setState(() {
        _busy = false;
        _amountError = e.forField('amount');
      });
      if (mounted && e.forField('amount') == null) {
        AppToast.show(context, e.message);
      }
    } on AppException catch (e) {
      setState(() => _busy = false);
      if (mounted) {
        AppToast.show(context, e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: AppSpacing.x3l),

          // Shogird konteksti.
          GlassCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            radius: AppRadius.xxl,
            child: Row(
              children: <Widget>[
                Avatar.small(widget.studentName),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        widget.studentName,
                        style: AppText.body14Bold.copyWith(color: c.ink),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${s.tariffName(widget.tariffType)} · '
                        '${Money.format(widget.amount)}',
                        style: AppText.caption12.copyWith(color: c.dim),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Summa — mono, markazda, jonli minglik ajratish.
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.x6l,
              bottom: AppSpacing.xs,
            ),
            child: TextField(
              controller: _amount,
              enabled: !_busy,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: AppText.money40.copyWith(color: c.ink),
              cursorColor: c.anor,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                const _ThousandsFormatter(),
              ],
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                suffixText: ' ${s.sum}',
                suffixStyle: AppText.body16.copyWith(color: c.soft),
                errorText: _amountError,
                errorStyle: AppText.caption12.copyWith(color: c.debt),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Sana.
          Center(
            child: GhostButton(
              label: s.fullDate(_paidAt),
              size: AppButtonSize.small,
              expand: false,
              onPressed: _busy ? null : _pickDate,
            ),
          ),

          // Usul.
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxl),
            child: Row(
              spacing: AppSpacing.sm,
              children: <Widget>[
                for (final PaymentMethod m in PaymentMethod.values)
                  AppChip(
                    label: s.methodName(m),
                    selected: _method == m,
                    expand: true,
                    onTap: _busy ? null : () => setState(() => _method = m),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.x4l),
            child: GradientButton(
              label: s.savePayment,
              loading: _busy,
              onPressed: _amountValue > 0 ? _save : null,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: Text(
              s.receiptNote,
              textAlign: TextAlign.center,
              style: AppText.caption12.copyWith(color: c.dim),
            ),
          ),
        ],
      ),
    );
  }
}

/// Yozayotganda minglik ajratish: `400000` → `400 000`.
class _ThousandsFormatter extends TextInputFormatter {
  const _ThousandsFormatter();

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
