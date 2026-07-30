import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
import 'package:ustoz_trainer/core/i18n/lang_provider.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/utils/money.dart';
import 'package:ustoz_trainer/core/widgets/press_scale.dart';
import 'package:ustoz_trainer/core/widgets/status_badge.dart';
import 'package:ustoz_trainer/features/calendar/providers/calendar_provider.dart';
import 'package:ustoz_trainer/features/dashboard/providers/dashboard_provider.dart';
import 'package:ustoz_trainer/features/payments/ui/payment_sheet.dart';
import 'package:ustoz_trainer/features/stats/ui/stats_screen.dart';

enum CalFilter { all, paid, partial, unpaid }

/// Kalendar (prototip v3 kompozitsiyasi): oy grid + rang-kodli kun kataklari
/// (to'lov holatlari) · filtr segmenti · oy xulosasi · legenda · kun sheeti
/// (shogird qoldiqlari, qoldiq-prefill to'lov).
///
/// Prototipdagi "Jadval" (sessiya taymlayni, Hafta/Kun toggle, slot yaratish,
/// takrorlanish, ta'til bekor qilish, konflikt belgisi) sessiya/slot backend
/// endpointlarini talab qiladi — hozir faqat to'lov kalendari (`GET /calendar`)
/// mavjud. Soxta ma'lumot ishlatilmaydi (ma'lumot-gap sifatida qaytarildi).
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  CalFilter _filter = CalFilter.all;

  String get _key =>
      '${_month.year}-${_month.month.toString().padLeft(2, '0')}';

  void _shift(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  /// Kun rangi: to'lamagan → QIZIL; qisman → SARIQ; hammasi to'lagan →
  /// YASHIL; kelasi due → anor "kutilmoqda"; due yo'q → neytral.
  Color? _statusColor(AppColors c, CalStatus st) => switch (st) {
    CalStatus.unpaid => c.debt,
    CalStatus.partial => c.warn,
    CalStatus.paid => c.ok,
    CalStatus.planned => c.anor2,
    CalStatus.none => null,
  };

  bool _passesFilter(CalStatus st) => switch (_filter) {
    CalFilter.all => true,
    CalFilter.paid => st == CalStatus.paid,
    CalFilter.partial => st == CalStatus.partial,
    CalFilter.unpaid => st == CalStatus.unpaid,
  };

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final Lang lang = ref.watch(langProvider);
    final CalMonth month =
        ref.watch(calendarMonthProvider(_key)).value ?? const CalMonth();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.xxl,
        AppSpacing.screenEdge,
        AppSpacing.screenBottom,
      ),
      children: <Widget>[
        // Sarlavha qatori — til almashtirgich (prototip v3 pill).
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                s.calendarTitle,
                style: AppText.h20.copyWith(color: c.anor2),
              ),
            ),
            PressScale(
              onTap: () => ref
                  .read(langProvider.notifier)
                  .set(lang == Lang.uz ? Lang.ru : Lang.uz),
              child: Container(
                width: 46,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.glassHi,
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  border: Border.all(color: c.line),
                ),
                child: Text(
                  lang == Lang.uz ? 'UZ' : 'RU',
                  style: AppText.body13Bold.copyWith(color: c.anor2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Filtr segmenti (prototip pill-track).
        _FilterBar(
          value: _filter,
          onChanged: (CalFilter f) => setState(() => _filter = f),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Oy kartasi.
        Container(
          decoration: _cardDecoration(c),
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  _chevron(c, Icons.chevron_left_rounded, () => _shift(-1)),
                  Expanded(
                    child: Text(
                      s.monthYear(_month),
                      textAlign: TextAlign.center,
                      style: AppText.body15Bold.copyWith(color: c.anor2),
                    ),
                  ),
                  _chevron(c, Icons.chevron_right_rounded, () => _shift(1)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  for (final String w in s.weekdayShort)
                    Expanded(
                      child: Text(
                        w,
                        textAlign: TextAlign.center,
                        style: AppText.caption12.copyWith(color: c.soft),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _grid(c, s, month),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Oy xulosasi.
        Container(
          decoration: _cardDecoration(c),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.xl,
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.insights_outlined, size: 18, color: c.anor2),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  s.calMonthSummary(
                    _month.month,
                    month.paid,
                    month.partial,
                    month.planned,
                  ),
                  style: AppText.body13.copyWith(color: c.ink),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Legenda.
        Container(
          decoration: _cardDecoration(c),
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                s.legendTitle,
                style: AppText.body15Bold.copyWith(color: c.anor2),
              ),
              const SizedBox(height: AppSpacing.lg),
              _legend(c, c.ok, s.legendPaid),
              const SizedBox(height: AppSpacing.md),
              _legend(c, c.warn, s.legendPartial),
              const SizedBox(height: AppSpacing.md),
              _legend(c, c.debt, s.legendUnpaid),
              const SizedBox(height: AppSpacing.md),
              _legend(c, c.anor2, s.legendPlanned),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chevron(AppColors c, IconData icon, VoidCallback onTap) {
    return PressScale(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: c.glassHi, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: c.anor2),
      ),
    );
  }

  Widget _grid(AppColors c, AppStrings s, CalMonth month) {
    final int daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final int offset = DateTime(_month.year, _month.month, 1).weekday - 1;
    final DateTime now = DateTime.now();

    final List<Widget> cells = <Widget>[];
    for (int i = 0; i < offset; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (int day = 1; day <= daysInMonth; day++) {
      final CalDay d = month.days[day] ?? const CalDay();
      final bool today =
          now.year == _month.year &&
          now.month == _month.month &&
          now.day == day;
      cells.add(_dayCell(c, s, day, d, today));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      childAspectRatio: 1,
      children: cells,
    );
  }

  /// Kun katagi — prototip rounded-rect uslubi: status tini fon + chegara,
  /// bugun to'liq anor gradient.
  Widget _dayCell(AppColors c, AppStrings s, int day, CalDay d, bool today) {
    final bool active = d.status != CalStatus.none && _passesFilter(d.status);
    final Color? statusColor = active ? _statusColor(c, d.status) : null;

    final BoxDecoration deco;
    final Color textColor;
    if (today) {
      deco = BoxDecoration(
        gradient: c.anorGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      );
      textColor = Colors.white;
    } else if (statusColor != null) {
      deco = BoxDecoration(
        color: statusColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: statusColor.withValues(alpha: 0.28)),
      );
      textColor = statusColor;
    } else {
      deco = BoxDecoration(
        color: c.glassHi,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      );
      textColor = c.soft;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: d.isEmpty ? null : () => _showDay(c, s, day, d),
      child: Container(
        alignment: Alignment.center,
        decoration: deco,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('$day', style: AppText.body13Bold.copyWith(color: textColor)),
            if (!today && statusColor != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDay(AppColors c, AppStrings s, int day, CalDay d) {
    final DateTime date = DateTime(_month.year, _month.month, day);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.sheet,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (BuildContext _) =>
          _DaySheet(day: date, calDay: d, monthKey: _key),
    );
  }

  Widget _legend(AppColors c, Color dot, String label) {
    return Row(
      children: <Widget>[
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: AppText.body14.copyWith(color: c.ink),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Prototip karta: `--s1` sirt, `--bd` chegara, radius 20 (AppRadius.card).
BoxDecoration _cardDecoration(AppColors c) => BoxDecoration(
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

// ---------------------------------------------------------------- filtr segmenti

/// Prototip pill-track: `background:var(--s2)` konteyner ichida segment pilllar,
/// tanlangan = anor gradient / oq matn, boshqalar = shaffof / soft matn.
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.value, required this.onChanged});

  final CalFilter value;
  final ValueChanged<CalFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    final List<(CalFilter, String)> items = <(CalFilter, String)>[
      (CalFilter.all, s.all),
      (CalFilter.paid, s.paymentPaid),
      (CalFilter.partial, s.paymentPartial),
      (CalFilter.unpaid, s.legendUnpaid),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: c.glassHi,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: c.line),
      ),
      child: Row(
        children: <Widget>[
          for (final (CalFilter f, String label) in items)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(f),
                child: AnimatedContainer(
                  duration: AppDuration.fast,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: value == f ? c.anorGradient : null,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption125.copyWith(
                      color: value == f ? Colors.white : c.soft,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------- kun sheeti

/// Kun sheeti — shogirdlar ro'yxati (ism, "300 000 / 550 000", status badge,
/// qoldiq-prefill "To'lov qo'shish").
class _DaySheet extends ConsumerWidget {
  const _DaySheet({
    required this.day,
    required this.calDay,
    required this.monthKey,
  });

  final DateTime day;
  final CalDay calDay;
  final String monthKey;

  (String, BadgeTone) _badge(AppStrings s, CalStatus st) => switch (st) {
    CalStatus.paid => (s.paymentPaid, BadgeTone.ok),
    CalStatus.partial => (s.paymentPartial, BadgeTone.warn),
    CalStatus.unpaid => (s.statusUnpaidLabel, BadgeTone.debt),
    CalStatus.planned => (s.calPlanned, BadgeTone.neutral),
    CalStatus.none => (s.calPlanned, BadgeTone.neutral),
  };

  Future<void> _pay(BuildContext context, WidgetRef ref, CalEntry e) async {
    // Qoldiq bo'lsa — o'sha bilan prefill; to'liq to'langan bo'lsa tarif narxi.
    final int prefill = e.remainder > 0 ? e.remainder : e.expected;
    final bool? ok = await showPaymentSheet(
      context,
      studentId: e.studentId,
      studentName: e.name,
      amount: prefill,
    );
    if (ok == true) {
      ref.invalidate(calendarMonthProvider(monthKey));
      await ref.read(dashboardProvider.notifier).invalidateQuietly();
      await ref.read(statsProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x4l,
          AppSpacing.lg,
          AppSpacing.x4l,
          AppSpacing.x4l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Sheet handle.
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: c.soft.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadius.xxs),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              '${s.dayPaymentsTitle} · ${s.fullDate(day)}',
              style: AppText.h18.copyWith(color: c.anor2),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (calDay.entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Text(
                  s.noPaymentsDay,
                  style: AppText.body14.copyWith(color: c.soft),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: calDay.entries.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (BuildContext _, int i) =>
                      _entryRow(context, ref, s, c, calDay.entries[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _entryRow(
    BuildContext context,
    WidgetRef ref,
    AppStrings s,
    AppColors c,
    CalEntry e,
  ) {
    final (String badge, BadgeTone tone) = _badge(s, e.status);
    final bool owes = e.remainder > 0 && e.status != CalStatus.planned;

    return Container(
      decoration: BoxDecoration(
        color: c.glassHi,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: c.line),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        e.name,
                        style: AppText.body14Bold.copyWith(color: c.ink),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    StatusBadge(badge, tone: tone),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: Money.format(e.paid),
                        style: AppText.money12.copyWith(
                          color: e.status == CalStatus.paid ? c.ok : c.ink,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${Money.format(e.expected)} ${Money.unit}',
                        style: AppText.money12.copyWith(color: c.soft),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (owes) ...<Widget>[
            const SizedBox(width: AppSpacing.md),
            PressScale(
              onTap: () => _pay(context, ref, e),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: c.anorGradient,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Text(
                  s.addPayment,
                  style: AppText.body13Bold.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
