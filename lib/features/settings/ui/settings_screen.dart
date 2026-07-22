import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/dto/auth_dto.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
import 'package:ustoz_trainer/core/api/dto/payment_dto.dart';
import 'package:ustoz_trainer/core/i18n/lang_provider.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/providers.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/utils/money.dart';
import 'package:ustoz_trainer/core/widgets/app_button.dart';
import 'package:ustoz_trainer/core/widgets/app_chip.dart';
import 'package:ustoz_trainer/core/widgets/app_toast.dart';
import 'package:ustoz_trainer/core/widgets/avatar.dart';
import 'package:ustoz_trainer/core/widgets/empty_state.dart';
import 'package:ustoz_trainer/core/widgets/glass_card.dart';
import 'package:ustoz_trainer/core/widgets/list_row.dart';
import 'package:ustoz_trainer/core/widgets/section_header.dart';
import 'package:ustoz_trainer/core/widgets/status_badge.dart';
import 'package:ustoz_trainer/features/auth/providers/session_provider.dart';
import 'package:ustoz_trainer/features/students/providers/students_provider.dart';

/// S11 — sozlamalar / profil.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final SessionState session = ref.watch(sessionProvider);

    if (session is! SessionActive) {
      return const SizedBox.shrink();
    }
    final Me me = session.me;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.x4l,
        AppSpacing.screenEdge,
        AppSpacing.screenBottom,
      ),
      children: <Widget>[
        // Header + chiqish.
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                s.settings,
                style: AppText.display24.copyWith(color: c.anor2),
              ),
            ),
            GestureDetector(
              onTap: () => _signOut(context, ref),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.debtSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.logout, size: 20, color: c.debt),
              ),
            ),
          ],
        ),

        // Profil.
        const SizedBox(height: AppSpacing.x3l),
        Container(
          decoration: settingsCard(c),
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Row(
            children: <Widget>[
              Avatar(me.name, size: 56),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      me.name,
                      style: AppText.h18.copyWith(color: c.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      me.gymName ?? s.trainerRole,
                      style: AppText.body13.copyWith(color: c.soft),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _editProfile(context, ref, me),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.anor2,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        // Til sozlamalari.
        const SizedBox(height: AppSpacing.xl),
        Container(
          decoration: settingsCard(c),
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                s.languageSettings,
                style: AppText.h20.copyWith(color: c.anor2),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.glassHi,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.language, size: 20, color: c.anor2),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Text(
                      s.language,
                      style: AppText.body15Bold.copyWith(color: c.ink),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _setLang(
                      context,
                      ref,
                      me,
                      me.lang == Lang.uz ? Lang.ru : Lang.uz,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x4l,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: c.anor2,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        me.lang == Lang.uz ? s.langUz : s.langRu,
                        style: AppText.body14Bold.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Obuna.
        const SizedBox(height: AppSpacing.xl),
        _ObunaCard(me: me),

        // Eslatma vaqti.
        const SizedBox(height: AppSpacing.sectionGap),
        SectionHeader(s.remindTime),
        GlassCard(
          child: ListRowGroup(
            rows: <ListRow>[
              ListRow(
                title: s.remindTime,
                subtitle: me.remindTime ?? '09:00',
                trailing: Icon(Icons.schedule, size: 18, color: c.soft),
                onTap: () => _pickTime(context, ref, me),
                last: true,
              ),
            ],
          ),
        ),

        // Telegram.
        const SizedBox(height: AppSpacing.sectionGap),
        SectionHeader(s.telegram),
        GlassCard(
          child: ListRowGroup(
            rows: <ListRow>[
              ListRow(
                title: me.tgConnected ? s.tgConnected : s.connectTg,
                subtitle: me.tgConnected ? null : s.connectTg,
                trailing: StatusBadge(
                  me.tgConnected ? '✓' : '—',
                  tone: me.tgConnected ? BadgeTone.ok : BadgeTone.neutral,
                ),
                onTap: () => _shareTgLink(context, ref),
                last: true,
              ),
            ],
          ),
        ),

        // Tarif shablonlari.
        const SizedBox(height: AppSpacing.sectionGap),
        const _TariffTemplates(),

        // Chiqish.
        const SizedBox(height: AppSpacing.x7l),
        GhostButton(
          label: s.signOut,
          color: c.debt,
          onPressed: () => _signOut(context, ref),
        ),
      ],
    );
  }

  Future<void> _setLang(
    BuildContext context,
    WidgetRef ref,
    Me me,
    Lang lang,
  ) async {
    if (me.lang == lang) {
      return;
    }
    // Avval lokal — UI DARHOL almashadi (server javobini kutmaydi).
    await ref.read(langProvider.notifier).set(lang);

    try {
      final Me updated = await ref
          .read(meRepositoryProvider)
          .updateMe(MeUpdate(lang: lang));
      ref.read(sessionProvider.notifier).setMe(updated);
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.show(context, e.message);
      }
    }
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref, Me me) async {
    final List<String> parts = (me.remindTime ?? '09:00').split(':');
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts.first) ?? 9,
        minute: int.tryParse(parts.last) ?? 0,
      ),
    );
    if (picked == null) {
      return;
    }

    final String value =
        '${picked.hour.toString().padLeft(2, '0')}:'
        '${picked.minute.toString().padLeft(2, '0')}';

    try {
      final Me updated = await ref
          .read(meRepositoryProvider)
          .updateMe(MeUpdate(remindTime: value));
      ref.read(sessionProvider.notifier).setMe(updated);
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.show(context, e.message);
      }
    }
  }

  Future<void> _shareTgLink(BuildContext context, WidgetRef ref) async {
    try {
      final TgLink link = await ref
          .read(meRepositoryProvider)
          .getTrainerTgLink();
      await SharePlus.instance.share(ShareParams(text: link.link));
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.show(context, e.message);
      }
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final AppStrings s = context.s;
    final AppColors c = context.colors;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: c.sheet,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: Text(s.signOut, style: AppText.h18.copyWith(color: c.ink)),
        content: Text(
          s.signOutConfirm,
          style: AppText.body14.copyWith(color: c.soft),
        ),
        actions: <Widget>[
          GhostButton(
            label: s.cancel,
            size: AppButtonSize.small,
            expand: false,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          GhostButton(
            label: s.signOut,
            size: AppButtonSize.small,
            expand: false,
            color: c.debt,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      // Kesh ham tozalanadi — boshqa trener kirsa eski ma'lumot ko'rinmasin.
      await ref.read(localStoreProvider).clearAll();
      await ref.read(sessionProvider.notifier).signOut();
    }
  }

  Future<void> _editProfile(BuildContext context, WidgetRef ref, Me me) async {
    final AppStrings s = context.s;
    final AppColors c = context.colors;
    final TextEditingController name = TextEditingController(text: me.name);
    final TextEditingController gym = TextEditingController(
      text: me.gymName ?? '',
    );

    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext d) => AlertDialog(
        backgroundColor: c.sheet,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(s.edit, style: AppText.h18.copyWith(color: c.ink)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: name,
              style: AppText.body145.copyWith(color: c.ink),
              cursorColor: c.anor2,
              decoration: InputDecoration(
                labelText: s.fieldName,
                labelStyle: AppText.caption125.copyWith(color: c.dim),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: gym,
              style: AppText.body145.copyWith(color: c.ink),
              cursorColor: c.anor2,
              decoration: InputDecoration(
                labelText: s.gymNameLabel,
                labelStyle: AppText.caption125.copyWith(color: c.dim),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          GhostButton(
            label: s.cancel,
            size: AppButtonSize.small,
            expand: false,
            onPressed: () => Navigator.of(d).pop(false),
          ),
          GradientButton(
            label: s.save,
            size: AppButtonSize.small,
            expand: false,
            onPressed: () => Navigator.of(d).pop(true),
          ),
        ],
      ),
    );

    if (ok ?? false) {
      try {
        final Me updated = await ref
            .read(meRepositoryProvider)
            .updateMe(
              MeUpdate(
                name: name.text.trim(),
                gymName: gym.text.trim().isEmpty ? null : gym.text.trim(),
              ),
            );
        ref.read(sessionProvider.notifier).setMe(updated);
      } on AppException catch (e) {
        if (context.mounted) {
          AppToast.show(context, e.message);
        }
      }
    }
    name.dispose();
    gym.dispose();
  }
}

BoxDecoration settingsCard(AppColors c) => BoxDecoration(
  color: c.glass,
  borderRadius: BorderRadius.circular(18),
  border: Border.all(color: c.line),
  boxShadow: const <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(17, 24, 39, 0.05),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ],
);

/// Obuna kartasi (root-1-26) — S12 paywall UI (D202: flag ortida ishlaydi).
class _ObunaCard extends ConsumerWidget {
  const _ObunaCard({required this.me});

  final Me me;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    final bool pro = me.plan == Plan.pro;
    final int? daysLeft = me.planUntil?.difference(DateTime.now()).inDays;

    return Container(
      decoration: settingsCard(c),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            s.subscriptionTitle,
            style: AppText.h20.copyWith(color: c.anor2),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            decoration: BoxDecoration(
              gradient: c.anorGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        s.currentPlanLabel,
                        style: AppText.body13.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: c.ok,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        s.badgePaid,
                        style: AppText.badge11.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  pro ? s.planPremium : s.planFree,
                  style: AppText.h20.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _navyRow(
                  s.nextPaymentLabel,
                  me.planUntil == null ? '—' : s.fullDate(me.planUntil!),
                ),
                const SizedBox(height: AppSpacing.xs),
                _navyRow(
                  s.daysLeftLabel,
                  daysLeft == null ? '—' : s.streakDays(daysLeft),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GradientButton(
            label: s.changePlan,
            onPressed: () => _showPlanPicker(context),
          ),
          const SizedBox(height: AppSpacing.md),
          GhostButton(
            label: s.paymentHistory,
            onPressed: () => _showBilling(context),
          ),
        ],
      ),
    );
  }

  Widget _navyRow(String label, String value) {
    return Builder(
      builder: (BuildContext context) {
        return Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: AppText.body13.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ),
            Text(
              value,
              style: AppText.body14Bold.copyWith(color: Colors.white),
            ),
          ],
        );
      },
    );
  }

  void _showBilling(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.sheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext _) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(s.paymentHistory, style: AppText.h18.copyWith(color: c.anor2)),
            const SizedBox(height: AppSpacing.xl),
            Text(
              s.noBillingHistory,
              style: AppText.body14.copyWith(color: c.soft),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _showPlanPicker(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.sheet,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              s.choosePlanTitle,
              style: AppText.h18.copyWith(color: c.anor2),
            ),
            const SizedBox(height: AppSpacing.xl),
            _PlanOption(
              name: s.planFree,
              price: '0 ${Money.unit}${s.perMonth}',
              features: s.planFreeFeatures,
              selected: me.plan == Plan.free,
            ),
            const SizedBox(height: AppSpacing.lg),
            _PlanOption(
              name: s.planPremium,
              price: '${Money.format(50000)} ${Money.unit}${s.perMonth}',
              features: s.planPremiumFeatures,
              selected: me.plan == Plan.pro,
            ),
            const SizedBox(height: AppSpacing.xl),
            GradientButton(
              label: s.confirmAndPay,
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

class _PlanOption extends StatelessWidget {
  const _PlanOption({
    required this.name,
    required this.price,
    required this.features,
    required this.selected,
  });

  final String name;
  final String price;
  final List<String> features;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: c.glass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? c.anor2 : c.line,
          width: selected ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(name, style: AppText.h18.copyWith(color: c.ink)),
              ),
              Text(price, style: AppText.body14Bold.copyWith(color: c.anor2)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final String f in features)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: <Widget>[
                  Icon(Icons.check_circle, size: 18, color: c.ok),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      f,
                      style: AppText.body14.copyWith(color: c.ink),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Tarif shablonlari CRUD (T7).
class _TariffTemplates extends ConsumerWidget {
  const _TariffTemplates();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final AsyncValue<List<TariffTemplate>> async = ref.watch(tariffsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionHeader(
          s.tariffTemplates,
          trailing: '+ ${s.tariffNew}',
          onTrailingTap: () => _showEditor(context, ref),
        ),
        async.when(
          loading: () => const SizedBox(height: 60),
          error: (Object _, StackTrace _) => GlassCard(
            child: EmptyState(emoji: '😕', title: s.errGeneric, compact: true),
          ),
          data: (List<TariffTemplate> items) => items.isEmpty
              ? GlassCard(
                  child: EmptyState(
                    emoji: '🏷',
                    title: s.tariffTemplates,
                    actionLabel: s.tariffNew,
                    compact: true,
                    onAction: () => _showEditor(context, ref),
                  ),
                )
              : GlassCard(
                  child: ListRowGroup(
                    rows: <ListRow>[
                      for (final TariffTemplate t in items)
                        ListRow(
                          title: t.name,
                          subtitle:
                              '${s.tariffName(t.type)}'
                              '${t.sessionsCount == null ? '' : ' · ${t.sessionsCount}'}',
                          trailing: Text(
                            Money.format(t.price),
                            style: AppText.money14.copyWith(color: c.ink),
                          ),
                          onTap: () => _showEditor(context, ref, existing: t),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _showEditor(
    BuildContext context,
    WidgetRef ref, {
    TariffTemplate? existing,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext _) => _TariffDialog(existing: existing),
    );
  }
}

class _TariffDialog extends ConsumerStatefulWidget {
  const _TariffDialog({this.existing});

  final TariffTemplate? existing;

  @override
  ConsumerState<_TariffDialog> createState() => _TariffDialogState();
}

class _TariffDialogState extends ConsumerState<_TariffDialog> {
  late final TextEditingController _name = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final TextEditingController _price = TextEditingController(
    text: widget.existing == null ? '' : '${widget.existing!.price}',
  );
  late final TextEditingController _sessions = TextEditingController(
    text: widget.existing?.sessionsCount?.toString() ?? '',
  );

  late TariffType _type = widget.existing?.type ?? TariffType.monthly;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _sessions.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) {
      return;
    }
    final int? price = int.tryParse(_price.text.replaceAll(RegExp(r'\D'), ''));
    if (_name.text.trim().isEmpty || price == null || price <= 0) {
      return;
    }

    setState(() => _busy = true);
    try {
      final int? sessions = _type == TariffType.package
          ? int.tryParse(_sessions.text)
          : null;

      if (widget.existing == null) {
        await ref
            .read(tariffsProvider.notifier)
            .create(
              TariffCreate(
                name: _name.text.trim(),
                type: _type,
                price: price,
                sessionsCount: sessions,
              ),
            );
      } else {
        // Kontrakt: `type` va `sessions_count` O'ZGARTIRILMAYDI.
        await ref
            .read(tariffsProvider.notifier)
            .edit(
              widget.existing!.id,
              TariffUpdate(name: _name.text.trim(), price: price),
            );
      }
      if (mounted) {
        Navigator.of(context).pop();
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
    final bool isEdit = widget.existing != null;

    return AlertDialog(
      backgroundColor: c.sheet,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      title: Text(
        isEdit ? s.edit : s.tariffNew,
        style: AppText.h18.copyWith(color: c.ink),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _name,
              enabled: !_busy,
              style: AppText.body145.copyWith(color: c.ink),
              cursorColor: c.anor,
              decoration: InputDecoration(
                labelText: s.tariff,
                labelStyle: AppText.caption125.copyWith(color: c.dim),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _price,
              enabled: !_busy,
              keyboardType: TextInputType.number,
              style: AppText.money17.copyWith(color: c.ink),
              cursorColor: c.anor,
              decoration: InputDecoration(
                labelText: s.price,
                labelStyle: AppText.caption125.copyWith(color: c.dim),
              ),
            ),
            if (!isEdit) ...<Widget>[
              const SizedBox(height: AppSpacing.xxl),
              Row(
                spacing: AppSpacing.xs,
                children: <Widget>[
                  for (final TariffType t in TariffType.values)
                    AppChip(
                      label: s.tariffName(t),
                      selected: _type == t,
                      expand: true,
                      onTap: _busy ? null : () => setState(() => _type = t),
                    ),
                ],
              ),
              if (_type == TariffType.package) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _sessions,
                  enabled: !_busy,
                  keyboardType: TextInputType.number,
                  style: AppText.body145.copyWith(color: c.ink),
                  cursorColor: c.anor,
                  decoration: InputDecoration(
                    labelText: s.sessionsOf(0).replaceAll('0 ', ''),
                    labelStyle: AppText.caption125.copyWith(color: c.dim),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
      actions: <Widget>[
        GhostButton(
          label: s.cancel,
          size: AppButtonSize.small,
          expand: false,
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
        ),
        GradientButton(
          label: s.save,
          size: AppButtonSize.small,
          expand: false,
          loading: _busy,
          onPressed: _save,
        ),
      ],
    );
  }
}
