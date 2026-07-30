import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/dto/auth_dto.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
import 'package:ustoz_trainer/core/api/dto/payment_dto.dart';
import 'package:ustoz_trainer/core/i18n/lang_provider.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/providers.dart';
import 'package:ustoz_trainer/core/router/app_router.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/theme/theme_mode_provider.dart';
import 'package:ustoz_trainer/core/utils/money.dart';
import 'package:ustoz_trainer/core/widgets/app_button.dart';
import 'package:ustoz_trainer/core/widgets/app_chip.dart';
import 'package:ustoz_trainer/core/widgets/app_toast.dart';
import 'package:ustoz_trainer/core/widgets/avatar.dart';
import 'package:ustoz_trainer/core/widgets/empty_state.dart';
import 'package:ustoz_trainer/core/widgets/glass_card.dart';
import 'package:ustoz_trainer/core/widgets/list_row.dart';
import 'package:ustoz_trainer/core/widgets/press_scale.dart';
import 'package:ustoz_trainer/core/widgets/section_header.dart';
import 'package:ustoz_trainer/features/auth/providers/session_provider.dart';
import 'package:ustoz_trainer/features/students/providers/students_provider.dart';

/// S11 — Menyu / sozlamalar (prototip v3): profil kartasi · USTOZ PRO havolasi ·
/// menyu guruhlari (tarif shablonlari · statistika · eslatma vaqti · bot) ·
/// tema/til toggle · chiqish.
///
/// Prototipdagi "Mini-sayt", "Qurilmalar" va "Eslatma shablonlari" bo'limlari
/// backendda yo'q (data-gap) — soxta ma'lumot ishlatilmaydi, ular qo'shilmadi.
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

    final ThemeMode mode = ref.watch(themeModeProvider);
    final bool isDark =
        mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.sm,
        AppSpacing.screenEdge,
        AppSpacing.screenBottom,
      ),
      children: <Widget>[
        Text(s.menu, style: AppText.display24.copyWith(color: c.ink)),
        const SizedBox(height: AppSpacing.xl),

        // Profil kartasi — bosilganda tahrirlash.
        _ProfileCard(me: me, onTap: () => _editProfile(context, ref, me)),
        const SizedBox(height: AppSpacing.xl),

        // USTOZ PRO — obuna tanlash sahifasi (paywall route hali yo'q →
        // mavjud tarif tanlash sheet'ini ochamiz).
        _ProCard(me: me, onTap: () => _showPlanPicker(context, me)),
        const SizedBox(height: AppSpacing.xl),

        // 1-guruh: funksiyalar.
        _MenuGroup(
          rows: <Widget>[
            _MenuRow(
              label: s.tariffTemplates,
              onTap: () => _showTariffs(context),
            ),
            _MenuRow(
              label: s.stats,
              onTap: () => context.go(Routes.stats),
            ),
            _MenuRow(
              label: s.remindTime,
              value: me.remindTime ?? '09:00',
              valueColor: c.soft,
              chevron: false,
              onTap: () => _pickTime(context, ref, me),
            ),
            _MenuRow(
              label: s.botSettings,
              value: me.tgConnected ? s.connected : s.notConnected,
              valueColor: me.tgConnected ? c.ok : c.soft,
              chevron: false,
              onTap: () => _shareTgLink(context, ref),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // 2-guruh: ko'rinish.
        _MenuGroup(
          rows: <Widget>[
            _MenuRow(
              label: s.theme,
              value: isDark ? s.themeDark : s.themeLight,
              valueColor: c.anor2,
              chevron: false,
              onTap: () => ref.read(themeModeProvider.notifier).toggle(),
            ),
            _MenuRow(
              label: s.language,
              value: me.lang == Lang.uz ? s.langUz : s.langRu,
              valueColor: c.anor2,
              chevron: false,
              onTap: () => _setLang(
                context,
                ref,
                me,
                me.lang == Lang.uz ? Lang.ru : Lang.uz,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x5l),

        // Chiqish.
        PressScale(
          onTap: () => _signOut(context, ref),
          child: SizedBox(
            height: 52,
            child: Center(
              child: Text(
                s.signOut,
                style: AppText.body14Bold.copyWith(color: c.debt),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------- aksiyalar

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

  void _showTariffs(BuildContext context) {
    final AppColors c = context.colors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.sheet,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (BuildContext _) => const _TariffSheet(),
    );
  }

  void _showPlanPicker(BuildContext context, Me me) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.sheet,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (BuildContext sheetContext) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(s.choosePlanTitle, style: AppText.h18.copyWith(color: c.anor2)),
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

// ------------------------------------------------------------- profil kartasi

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.me, required this.onTap});

  final Me me;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return PressScale(
      onTap: onTap,
      child: Container(
        decoration: _menuCardDecoration(c),
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Row(
          children: <Widget>[
            Avatar(me.name, size: 56),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    me.name,
                    style: AppText.body15Bold.copyWith(color: c.ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _prettyPhone(me.phone),
                    style: AppText.body13.copyWith(color: c.soft),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: c.dim),
          ],
        ),
      ),
    );
  }

  /// `+998901234567` → `+998 90 123 45 67`.
  static String _prettyPhone(String raw) {
    final String p = raw.replaceAll(RegExp(r'\s+'), '');
    if (p.length != 13 || !p.startsWith('+998')) {
      return raw;
    }
    final String d = p.substring(4);
    return '+998 ${d.substring(0, 2)} ${d.substring(2, 5)} '
        '${d.substring(5, 7)} ${d.substring(7, 9)}';
  }
}

// ------------------------------------------------------------- USTOZ PRO karta

class _ProCard extends StatelessWidget {
  const _ProCard({required this.me, required this.onTap});

  final Me me;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final bool pro = me.plan == Plan.pro;

    return PressScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: c.anor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: c.anor.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.all(AppSpacing.x3l),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: c.anorGradient,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(s.proTitle, style: AppText.body16.copyWith(color: c.ink)),
                  const SizedBox(height: 3),
                  Text(
                    pro ? s.subscriptionActive : s.menuProUpsell,
                    style: AppText.caption125.copyWith(color: c.soft),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: c.anor2),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------- menyu guruhi

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final List<Widget> children = <Widget>[];
    for (int i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i != rows.length - 1) {
        children.add(Divider(height: 1, thickness: 1, color: c.line));
      }
    }
    return Container(
      decoration: _menuCardDecoration(c),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.label,
    required this.onTap,
    this.value,
    this.valueColor,
    this.chevron = true,
  });

  final String label;
  final VoidCallback onTap;
  final String? value;
  final Color? valueColor;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: AppText.body15Bold.copyWith(color: c.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (value != null)
                Text(
                  value!,
                  style: AppText.body13Bold.copyWith(
                    color: valueColor ?? c.soft,
                  ),
                ),
              if (chevron) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.chevron_right_rounded, size: 18, color: c.dim),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Menyu kartasi sirti (prototip: `--s1` sirt, `--bd` chegara, radius 20).
BoxDecoration _menuCardDecoration(AppColors c) => BoxDecoration(
  color: c.glass,
  borderRadius: BorderRadius.circular(AppRadius.card),
  border: Border.all(color: c.line),
  boxShadow: const <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(17, 24, 39, 0.05),
      blurRadius: 14,
      offset: Offset(0, 5),
    ),
  ],
);

// --------------------------------------------------------- tarif shablonlari

/// Tarif shablonlari CRUD sheet (T7) — tugmadan ochiladi.
class _TariffSheet extends ConsumerWidget {
  const _TariffSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final AsyncValue<List<TariffTemplate>> async = ref.watch(tariffsProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
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

// ------------------------------------------------------------------ tarif reja

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
