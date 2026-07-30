import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ustoz_trainer/core/api/dto/dashboard_dto.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
import 'package:ustoz_trainer/core/api/dto/student_dto.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/router/app_router.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/utils/money.dart';
import 'package:ustoz_trainer/core/widgets/empty_state.dart';
import 'package:ustoz_trainer/core/widgets/money_text.dart';
import 'package:ustoz_trainer/core/widgets/plita_ring.dart';
import 'package:ustoz_trainer/core/widgets/press_scale.dart';
import 'package:ustoz_trainer/core/widgets/skeleton.dart';
import 'package:ustoz_trainer/features/payments/ui/payment_sheet.dart';
import 'package:ustoz_trainer/features/stats/ui/stats_screen.dart';
import 'package:ustoz_trainer/features/students/providers/students_provider.dart';

/// **Kassa** — to'lovlar moduli (TZ §3.6, "mahsulot yuragi").
///
/// Bu ekran ilgari UMUMAN YO'Q edi: to'lov faqat shogird kartasi ichidan
/// kiritilardi va trener "kim qarzdor?" degan savolga bir qarashda javob
/// ololmasdi. TZ §3.0 uni bottom bar'ga qo'yadi.
///
/// Tuzilishi (TZ §3.2 blok 3 · §3.6.3 svetofor):
///   1. Svetofor uchligi — yashil/sariq/qizil, bosilsa filtr
///   2. Qarz summasi — eng muhim raqam, eng katta shrift
///   3. Filtrlangan shogirdlar ro'yxati, har birida "To'lov" tugmasi
class CashScreen extends ConsumerStatefulWidget {
  const CashScreen({super.key});

  @override
  ConsumerState<CashScreen> createState() => _CashScreenState();
}

class _CashScreenState extends ConsumerState<CashScreen> {
  /// `null` — hammasi. Aks holda faqat shu holatdagilar.
  PaymentState? _filter;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final AsyncValue<StudentsState> async = ref.watch(studentsProvider);

    return Scaffold(
      backgroundColor: c.bg0,
      body: RefreshIndicator(
        color: c.anor,
        backgroundColor: c.bg1,
        onRefresh: () => ref.read(studentsProvider.notifier).refresh(),
        child: async.when(
          loading: () => const _CashSkeleton(),
          error: (Object e, StackTrace _) => ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
              EmptyState(
                emoji: '📡',
                title: s.errGeneric,
                message: e.toString(),
                actionLabel: s.retry,
                onAction: () => ref.invalidate(studentsProvider),
              ),
            ],
          ),
          data: (StudentsState st) => _Content(
            students: st.items,
            filter: _filter,
            stats: ref.watch(statsProvider).value,
            onFilter: (PaymentState? f) =>
                setState(() => _filter = _filter == f ? null : f),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.students,
    required this.filter,
    required this.onFilter,
    this.stats,
  });

  final List<Student> students;
  final PaymentState? filter;
  final ValueChanged<PaymentState?> onFilter;
  final StatsResponse? stats;

  /// Svetofor guruhlari (TZ §3.6.3).
  ///
  /// `dueToday` sariqqa qo'shiladi: trener uchun "bugun to'lov kuni" va
  /// "3 kun ichida" bitta harakatga olib keladi — eslatish.
  static bool _isGreen(Student s) => s.paymentState == PaymentState.paid;
  static bool _isAmber(Student s) =>
      s.paymentState == PaymentState.dueSoon ||
      s.paymentState == PaymentState.dueToday;
  static bool _isRed(Student s) => s.paymentState == PaymentState.overdue;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    final List<Student> active = students
        .where((Student x) => x.status == StudentStatus.active)
        .toList(growable: false);

    final int green = active.where(_isGreen).length;
    final int amber = active.where(_isAmber).length;
    final int red = active.where(_isRed).length;

    // Qarz — faqat muddati o'tganlar bo'yicha (TZ §3.2: "Qizillar: 850 000").
    final int debt = active
        .where(_isRed)
        .fold<int>(0, (int sum, Student x) => sum + x.tariffPrice);

    // Hero (prototip v3): tushum (real, statsdan) + kutilmoqda (yaqin
    // to'lovlar summasi) + qarz + o'sish %.
    final int income = stats?.monthRevenue ?? 0;
    final int expected = active
        .where(_isAmber)
        .fold<int>(0, (int sum, Student x) => sum + x.tariffPrice);
    final double? growth = stats?.changePercent;

    final List<Student> visible = switch (filter) {
      null => active,
      PaymentState.paid => active.where(_isGreen).toList(),
      PaymentState.overdue => active.where(_isRed).toList(),
      _ => active.where(_isAmber).toList(),
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        // Suzuvchi tabbar ostidan chiqish uchun.
        120,
      ),
      children: <Widget>[
        Text(s.navCash, style: AppText.display24.copyWith(color: c.ink)),
        const SizedBox(height: AppSpacing.lg),

        // ── Hero: tushum + kutilmoqda / qarz / o'sish ──
        Container(
          padding: const EdgeInsets.all(AppSpacing.x3l),
          decoration: BoxDecoration(
            color: c.glass,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: c.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                s.kpiMonthRevenue,
                style: AppText.caption125.copyWith(color: c.soft),
              ),
              const SizedBox(height: AppSpacing.xxs),
              MoneyText(income, style: AppText.money40, color: c.ink),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: <Widget>[
                  _HeroStat(label: s.cashExpected, value: Money.compact(expected), color: c.warn),
                  const SizedBox(width: AppSpacing.xl),
                  _HeroStat(label: s.cashDebtWord, value: Money.compact(debt), color: c.debt),
                  if (growth != null) ...<Widget>[
                    const SizedBox(width: AppSpacing.xl),
                    _HeroStat(
                      label: s.cashGrowth,
                      value: '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(0)}%',
                      color: growth >= 0 ? c.ok : c.debt,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Svetofor uchligi ──
        Row(
          children: <Widget>[
            Expanded(
              child: _StatusTile(
                count: green,
                label: s.cashPaid,
                icon: Icons.check_rounded,
                fg: c.ok,
                bg: c.okSoft,
                selected: filter == PaymentState.paid,
                onTap: () => onFilter(PaymentState.paid),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatusTile(
                count: amber,
                label: s.cashDueSoon,
                icon: Icons.schedule_rounded,
                fg: c.warn,
                bg: c.warnSoft,
                selected: filter == PaymentState.dueSoon,
                onTap: () => onFilter(PaymentState.dueSoon),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatusTile(
                count: red,
                label: s.cashOverdue,
                icon: Icons.priority_high_rounded,
                fg: c.debt,
                bg: c.debtSoft,
                selected: filter == PaymentState.overdue,
                onTap: () => onFilter(PaymentState.overdue),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxl),
            child: EmptyState(
              emoji: filter == null ? '💳' : '🔍',
              title: filter == null ? s.cashEmptyTitle : s.cashNoMatchTitle,
              message: filter == null
                  ? s.cashEmptyMessage
                  : s.cashNoMatchMessage,
              actionLabel: filter == null ? s.addStudent : s.showAll,
              onAction: () => filter == null
                  ? context.go(Routes.studentNew)
                  : onFilter(null),
            ),
          )
        else
          for (final Student x in visible)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _CashRow(student: x),
            ),
      ],
    );
  }
}

/// Hero mini-stat: yorliq + rangli qiymat (Kutilmoqda / Qarz / O'sish).
class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: AppText.label115.copyWith(color: c.dim)),
        const SizedBox(height: 2),
        Text(value, style: AppText.body14Bold.copyWith(color: color)),
      ],
    );
  }
}

/// Svetofor plitkasi — son + yorliq, bosilsa filtr.
class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.count,
    required this.label,
    required this.icon,
    required this.fg,
    required this.bg,
    required this.selected,
    required this.onTap,
  });

  final int count;
  final String label;
  final IconData icon;
  final Color fg;
  final Color bg;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Semantics(
        label: '$label: $count',
        selected: selected,
        child: Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.md),
            // Tanlangan filtr qalinroq chegara bilan ajraladi — rang
            // yolg'iz signal bo'lmasin.
            border: Border.all(
              color: selected ? fg : fg.withValues(alpha: 0.28),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(icon, size: 14, color: fg),
                  const SizedBox(width: AppSpacing.xxs),
                  Text('$count', style: AppText.h19.copyWith(color: fg)),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption12.copyWith(color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kassa qatori: plita-ring + ism + summa + "To'lov" tugmasi.
class _CashRow extends ConsumerWidget {
  const _CashRow({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    final (Color fg, String label) = switch (student.paymentState) {
      PaymentState.paid => (c.ok, s.cashPaid),
      PaymentState.overdue => (c.debt, s.cashOverdue),
      PaymentState.none => (c.dim, '—'),
      _ => (c.warn, s.cashDueSoon),
    };

    return PressScale(
      onTap: () => context.go(Routes.student(student.id)),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: c.glass,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: c.line),
        ),
        child: Row(
          children: <Widget>[
            PlitaRing(
              value: _periodProgress(student),
              tone: _tone(student.paymentState),
              label: _initials(student.name),
              labelStyle: AppText.badge11.copyWith(color: c.ink),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    student.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body15Bold.copyWith(color: c.ink),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: <Widget>[
                      Text(label, style: AppText.caption12.copyWith(color: fg)),
                      Text(
                        ' · ',
                        style: AppText.caption12.copyWith(color: c.dim),
                      ),
                      Flexible(
                        child: Text(
                          Money.format(student.tariffPrice),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.caption12.copyWith(color: c.soft),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Asosiy amal — to'lov kiritish. Ekran shu uchun mavjud.
            PressScale(
              onTap: () => unawaited(
                showPaymentSheet(
                  context,
                  studentId: student.id,
                  studentName: student.name,
                  amount: student.tariffPrice,
                  tariffType: student.tariffType,
                ),
              ),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: c.anorGradient,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Text(
                  s.addPayment,
                  style: AppText.badge11.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Svetofor holati → ring ohangi.
  static RingTone _tone(PaymentState st) => switch (st) {
    PaymentState.paid => RingTone.ok,
    PaymentState.overdue => RingTone.debt,
    PaymentState.none => RingTone.gradient,
    _ => RingTone.warn,
  };

  /// To'lov davrining o'tgan ulushi — plita-ring yoyi uchun.
  ///
  /// Sana yo'q bo'lsa (paket/bir martalik tarif) halqa to'liq: bu tarifda
  /// "davr" tushunchasi yo'q.
  static double _periodProgress(Student s) {
    final DateTime? due = s.nextDueDate;
    if (due == null) {
      return 1;
    }
    final int left = due.difference(DateTime.now()).inDays;
    if (left <= 0) {
      return 1;
    }
    // 30 kunlik davr taxmini — aniq davr uzunligi API'da yo'q.
    return (1 - left / 30).clamp(0.0, 1.0);
  }

  static String _initials(String name) {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    return (parts[0].characters.first + parts[1].characters.first)
        .toUpperCase();
  }
}

/// Yuklanish holati — haqiqiy tartib bilan bir xil (layout sakramaydi).
class _CashSkeleton extends StatelessWidget {
  const _CashSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        120,
      ),
      children: const <Widget>[
        Skeleton(width: 120, height: 28, radius: 8),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: <Widget>[
            Expanded(child: Skeleton(height: 76, radius: 14)),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: Skeleton(height: 76, radius: 14)),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: Skeleton(height: 76, radius: 14)),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Skeleton(height: 84, radius: 20),
        SizedBox(height: AppSpacing.lg),
        Skeleton(height: 72, radius: 20),
        SizedBox(height: AppSpacing.sm),
        Skeleton(height: 72, radius: 20),
        SizedBox(height: AppSpacing.sm),
        Skeleton(height: 72, radius: 20),
      ],
    );
  }
}
