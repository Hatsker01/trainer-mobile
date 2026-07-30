import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/dto/auth_dto.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
import 'package:ustoz_trainer/core/api/dto/payment_dto.dart';
import 'package:ustoz_trainer/core/api/dto/student_dto.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/providers.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/utils/money.dart';
import 'package:ustoz_trainer/core/widgets/app_button.dart';
import 'package:ustoz_trainer/core/widgets/app_chip.dart';
import 'package:ustoz_trainer/core/widgets/app_field.dart';
import 'package:ustoz_trainer/core/widgets/app_toast.dart';
import 'package:ustoz_trainer/features/auth/ui/phone_field.dart';
import 'package:ustoz_trainer/features/students/providers/students_provider.dart';

/// S7 — shogird qo'shish / tahrirlash (prototip v3).
///
/// Kompozitsiya prototipdan (proto §"Shogird qo'shish"): ekran ustidagi
/// sarlavha + yopish (X) tugmasi · yorliqli maydonlar (Ism-familiya · Telefon)
/// · "Tarif" bo'limi (shablon + tur chiplari · narx) · pastda katta CTA.
///
/// Prototipdagi "dublikat aniqlash / birlashtirish" bloki QO'SHILMADI —
/// backend telefon dublikatini tekshirish va karta birlashtirish endpointini
/// hali bermaydi (ma'lumot-gap). Soxta ma'lumot ishlatilmaydi.
class StudentFormScreen extends ConsumerStatefulWidget {
  const StudentFormScreen({this.existing, super.key});

  /// `null` — yangi shogird, aks holda tahrirlash.
  final Student? existing;

  @override
  ConsumerState<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends ConsumerState<StudentFormScreen> {
  late final TextEditingController _name = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final TextEditingController _phone = TextEditingController(
    text: widget.existing == null
        ? ''
        : PhoneInputFormatter.format(
            widget.existing!.phone.replaceFirst('+998', ''),
          ),
  );
  late final TextEditingController _price = TextEditingController(
    text: widget.existing == null
        ? ''
        : Money.format(widget.existing!.tariffPrice),
  );
  late final TextEditingController _sessions = TextEditingController(
    text: widget.existing?.sessionsTotal?.toString() ?? '',
  );

  late TariffType _type = widget.existing?.tariffType ?? TariffType.monthly;
  bool _busy = false;

  /// 422 maydon xatolari — serverdan kelgan holicha maydonlarga taqsimlanadi.
  Map<String, String> _errors = <String, String>{};

  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _price.dispose();
    _sessions.dispose();
    super.dispose();
  }

  int get _priceValue =>
      int.tryParse(_price.text.replaceAll(RegExp(r'\D'), '')) ?? 0;

  /// Tarif shablonini tanlash — maydonlarni to'ldiradi.
  void _applyTemplate(TariffTemplate t) {
    setState(() {
      _type = t.type;
      _price.text = Money.format(t.price);
      _sessions.text = t.sessionsCount?.toString() ?? '';
    });
  }

  Future<void> _save() async {
    if (_busy) {
      return;
    }
    final AppStrings s = context.s;

    // Lokal validatsiya — serverga bekorga bormaslik uchun.
    final Map<String, String> local = <String, String>{};
    if (_name.text.trim().isEmpty) {
      local['name'] = s.fieldRequired;
    }
    if (!PhoneField.isComplete(_phone.text)) {
      local['phone'] = s.phoneInvalid;
    }
    if (_priceValue <= 0) {
      local['tariff_price'] = s.fieldRequired;
    }
    if (_type == TariffType.package &&
        (int.tryParse(_sessions.text) ?? 0) <= 0) {
      local['sessions_total'] = s.fieldRequired;
    }
    if (local.isNotEmpty) {
      setState(() => _errors = local);
      return;
    }

    setState(() {
      _busy = true;
      _errors = <String, String>{};
    });

    try {
      final int? sessions = _type == TariffType.package
          ? int.tryParse(_sessions.text)
          : null;

      if (_isEdit) {
        await ref
            .read(studentRepositoryProvider)
            .update(
              widget.existing!.id,
              StudentUpdate(
                name: _name.text.trim(),
                phone: PhoneField.toE164(_phone.text),
                tariffType: _type,
                tariffPrice: _priceValue,
                sessionsTotal: sessions,
              ),
            );
        ref.invalidate(studentsProvider);
        ref.invalidate(studentProvider(widget.existing!.id));
        if (mounted) {
          context.pop();
        }
        return;
      }

      final Student created = await ref
          .read(studentRepositoryProvider)
          .create(
            StudentCreate(
              name: _name.text.trim(),
              phone: PhoneField.toE164(_phone.text),
              tariffType: _type,
              tariffPrice: _priceValue,
              sessionsTotal: sessions,
            ),
          );

      ref.invalidate(studentsProvider);
      if (!mounted) {
        return;
      }
      await _showInviteDialog(created);
      if (mounted) {
        context.pop();
      }
    } on ValidationException catch (e) {
      setState(() {
        _busy = false;
        _errors = e.fieldErrors;
      });
      if (mounted && e.fieldErrors.isEmpty) {
        AppToast.show(context, e.message);
      }
    } on AppException catch (e) {
      setState(() => _busy = false);
      if (mounted) {
        AppToast.show(context, e.message);
      }
    }
  }

  /// Saqlagandan keyin — taklif havolasini ulashish.
  Future<void> _showInviteDialog(Student student) async {
    final AppStrings s = context.s;

    String? link;
    try {
      final TgLink tg = await ref
          .read(studentRepositoryProvider)
          .inviteLink(student.id);
      link = tg.link;
    } on AppException {
      // Havola olinmadi — dialogni baribir ko'rsatamiz, ulashishsiz.
      link = null;
    }

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: dialogContext.colors.sheet,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: Text(
          '✓ ${student.name}',
          style: AppText.h18.copyWith(color: dialogContext.colors.ink),
        ),
        content: Text(
          s.inviteSend,
          style: AppText.body14.copyWith(color: dialogContext.colors.soft),
        ),
        actions: <Widget>[
          GhostButton(
            label: s.skip,
            size: AppButtonSize.small,
            expand: false,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          if (link != null)
            GradientButton(
              label: s.inviteSend,
              size: AppButtonSize.small,
              expand: false,
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await SharePlus.instance.share(ShareParams(text: link));
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final AsyncValue<List<TariffTemplate>> tariffs = ref.watch(tariffsProvider);

    return Scaffold(
      backgroundColor: c.bg0,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Ekran ustidagi sarlavha + yopish tugmasi (proto header).
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.md,
                AppSpacing.screenEdge,
                AppSpacing.xl,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _isEdit ? s.edit : s.addStudent,
                      style: AppText.display24.copyWith(color: c.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  GhostIconButton(
                    size: 36,
                    radius: AppRadius.lg,
                    onPressed: context.pop,
                    child: Icon(Icons.close_rounded, size: 18, color: c.soft),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  0,
                  AppSpacing.screenEdge,
                  AppSpacing.x7l,
                ),
                children: <Widget>[
                  // Ism-familiya.
                  AppField(
                    controller: _name,
                    label: s.studentFullName,
                    errorText: _errors['name'],
                    enabled: !_busy,
                    autofocus: !_isEdit,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Telefon (+998 doimiy prefiks).
                  AppField(
                    controller: _phone,
                    label: s.phoneLabel,
                    errorText: _errors['phone'],
                    enabled: !_busy,
                    keyboardType: TextInputType.phone,
                    inputFormatters: const <TextInputFormatter>[
                      PhoneInputFormatter(),
                    ],
                    hintText: '90 123 45 67',
                    prefix: Text(
                      '+998',
                      style: AppText.body145.copyWith(color: c.soft),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.x6l),

                  // Tarif — yorliq (maydon yorliqlari uslubida).
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.lg,
                      left: AppSpacing.xxs,
                    ),
                    child: Text(
                      s.tariff,
                      style: AppText.caption125.copyWith(color: c.soft),
                    ),
                  ),

                  // Tarif shablonlari — bosilganda maydonlarni to'ldiradi.
                  tariffs.maybeWhen(
                    data: (List<TariffTemplate> items) => items.isEmpty
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.lg,
                            ),
                            child: AppChipRow(
                              children: <Widget>[
                                for (final TariffTemplate t in items)
                                  AppChip(
                                    label:
                                        '${t.name} · ${Money.compact(t.price)}',
                                    selected: false,
                                    onTap: _busy
                                        ? null
                                        : () => _applyTemplate(t),
                                  ),
                              ],
                            ),
                          ),
                    orElse: () => const SizedBox.shrink(),
                  ),

                  // Tarif turi — pill chiplar (proto: Oylik / Paket / Bir marta).
                  Row(
                    spacing: AppSpacing.sm,
                    children: <Widget>[
                      for (final TariffType t in TariffType.values)
                        AppChip(
                          label: s.tariffName(t),
                          selected: _type == t,
                          expand: true,
                          onTap: _busy
                              ? null
                              : () => setState(() => _type = t),
                        ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Narx.
                  AppField(
                    controller: _price,
                    label: s.price,
                    errorText: _errors['tariff_price'],
                    enabled: !_busy,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      _MoneyFormatter(),
                    ],
                    suffix: Text(
                      s.sum,
                      style: AppText.caption125.copyWith(color: c.dim),
                    ),
                  ),

                  // Paket tarifda — mashg'ulotlar soni.
                  if (_type == TariffType.package) ...<Widget>[
                    const SizedBox(height: AppSpacing.xxl),
                    AppField(
                      controller: _sessions,
                      label: s.sessionsTotalLabel,
                      errorText: _errors['sessions_total'],
                      enabled: !_busy,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ],

                  const SizedBox(height: AppSpacing.x7l),
                  GradientButton(
                    label: s.save,
                    loading: _busy,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoneyFormatter extends TextInputFormatter {
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
