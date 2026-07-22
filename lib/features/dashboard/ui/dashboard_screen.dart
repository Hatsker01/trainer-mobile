import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/dto/dashboard_dto.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
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
import 'package:ustoz_trainer/core/widgets/status_badge.dart';
import 'package:ustoz_trainer/features/attendance/ui/attendance_sheet.dart';
import 'package:ustoz_trainer/features/auth/providers/session_provider.dart';
import 'package:ustoz_trainer/features/dashboard/providers/dashboard_provider.dart';
import 'package:ustoz_trainer/features/dashboard/ui/goal_sheet.dart';
import 'package:ustoz_trainer/features/payments/ui/payment_sheet.dart';
import 'package:ustoz_trainer/features/stats/ui/stats_screen.dart';

/// S4 — Bosh sahifa (G2 ZICHLIK qayta kompozitsiya): kompakt salom + yig'ma
/// hero (daromad + maqsad ringi + mini qarz/faol) + BUGUN bo'limi + tezkor
/// amallar + so'nggi faoliyat. Zich moliyaviy ilova standarti.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DashboardData> async = ref.watch(dashboardProvider);
    final AppStrings s = context.s;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(dashboardProvider.notifier).refresh();
        await ref.read(statsProvider.notifier).refresh();
      },
      backgroundColor: context.colors.sheet,
      color: context.colors.anor2,
      child: async.when(
        skipLoadingOnRefresh: true,
        loading: () => const _DashboardSkeleton(),
        error: (Object e, StackTrace _) => _DashboardError(
          message: e is AppException ? e.message : s.errGeneric,
          onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
        ),
        data: (DashboardData data) => _DashboardBody(data: data),
      ),
    );
  }
}

/// Zich oq karta — yumshoq soya + ochiq chegara.
BoxDecoration _cardDecoration(AppColors c, {double radius = 16}) {
  return BoxDecoration(
    color: c.glass,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: c.line),
    boxShadow: const <BoxShadow>[
      BoxShadow(
        color: Color.fromRGBO(17, 24, 39, 0.05),
        blurRadius: 14,
        offset: Offset(0, 5),
      ),
    ],
  );
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = context.s;
    final DashboardResponse d = data.value;

    final StatsResponse? stats = ref.watch(statsProvider).value;
    final int monthRevenue = stats?.monthRevenue ?? 0;
    final int debtTotal = stats?.debtTotal ?? 0;
    final int debtors = stats?.debtorsCount ?? d.overdue.length;
    final int active = stats?.activeStudents ?? 0;

    // Yig'im % (G4): backend `collected/expected_this_month` (D060) bo'lsa
    // o'shandan; bo'lmasa proksi: yig'ilgan / (yig'ilgan + qarz) (D209).
    final int collected = d.collectedThisMonth ?? monthRevenue;
    final int expected = d.expectedThisMonth ?? (monthRevenue + debtTotal);
    final int collectedPct = expected == 0
        ? 0
        : ((collected * 100) / expected).round().clamp(0, 100);

    // Oylik maqsad (G4) — sessiyadan (faqat goal int'iga bog'lanamiz).
    final int? goal = ref.watch(
      sessionProvider.select(
        (SessionState s) => s is SessionActive ? s.me.monthlyGoal : null,
      ),
    );

    // BUGUN — kechikkanlar avval, keyin bugun to'lashi kerak. Maksimal 3.
    final List<DashboardStudent> today = <DashboardStudent>[
      ...d.overdue,
      ...d.dueToday,
    ];

    // So'nggi faoliyat — e'tibor ro'yxatidan (5 ta, zich).
    final List<DashboardStudent> activity = <DashboardStudent>[
      ...d.overdue,
      ...d.dueToday,
      ...d.dueSoon,
    ].take(5).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.xxl,
        AppSpacing.screenEdge,
        AppSpacing.screenBottom,
      ),
      children: <Widget>[
        // 1) Kompakt salom qatori.
        _GreetingRow(
          name: d.greetingName,
          notif: d.overdue.length,
          collectedPct: collectedPct,
        ),
        const SizedBox(height: AppSpacing.xl),

        // 2) Yig'ma hero: daromad + maqsad ringi + mini qarz/faol.
        _GoalHero(
          monthRevenue: monthRevenue,
          goal: goal,
          debtTotal: debtTotal,
          debtors: debtors,
          active: active,
        ),
        const SizedBox(height: AppSpacing.sectionGapDense),

        // 3) BUGUN.
        Text(s.todaySection, style: _sectionStyle(context)),
        const SizedBox(height: AppSpacing.md),
        if (today.isEmpty)
          _AllClearRow()
        else
          for (final DashboardStudent st in today.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _TodayRow(student: st),
            ),
        if (today.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxs),
            child: GestureDetector(
              onTap: () => context.go(Routes.students),
              child: Text(
                '+${today.length - 3} · ${s.seeAll}',
                style: AppText.body13Bold.copyWith(color: context.colors.anor2),
              ),
            ),
          ),

        // 4) Tezkor amallar — bitta qatorda 3 kichik.
        const SizedBox(height: AppSpacing.sectionGapDense),
        const _QuickActions(),

        // 5) So'nggi faoliyat.
        const SizedBox(height: AppSpacing.sectionGapDense),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(s.recentActivity, style: _sectionStyle(context)),
            ),
            GestureDetector(
              onTap: () => context.go(Routes.students),
              child: Text(
                s.seeAll,
                style: AppText.body13Bold.copyWith(color: context.colors.anor2),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (activity.isEmpty)
          Container(
            decoration: _cardDecoration(context.colors),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: EmptyState(emoji: '💪', title: s.allClear),
          )
        else
          for (final DashboardStudent st in activity)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _ActivityRow(student: st),
            ),
      ],
    );
  }
}

TextStyle _sectionStyle(BuildContext context) =>
    AppText.section15.copyWith(color: context.colors.ink, letterSpacing: 0.4);

// ---------------------------------------------------------------- salom qatori

class _GreetingRow extends StatelessWidget {
  const _GreetingRow({
    required this.name,
    required this.notif,
    required this.collectedPct,
  });

  final String name;
  final int notif;
  final int collectedPct;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                s.greeting(name),
                style: AppText.h20.copyWith(color: c.anor2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                s.collectedPercent(collectedPct),
                style: AppText.caption125.copyWith(color: c.soft),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.push(Routes.notifications),
          child: _BellButton(count: notif),
        ),
      ],
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.glassHi, shape: BoxShape.circle),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 21,
              color: c.anor2,
            ),
          ),
          if (count > 0)
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                padding: const EdgeInsets.all(3),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.debt,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.bg0, width: 2),
                ),
                child: Text(
                  '$count',
                  style: AppText.badge11.copyWith(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ hero + ring

class _GoalHero extends StatelessWidget {
  const _GoalHero({
    required this.monthRevenue,
    required this.goal,
    required this.debtTotal,
    required this.debtors,
    required this.active,
  });

  final int monthRevenue;
  final int? goal;
  final int debtTotal;
  final int debtors;
  final int active;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final int? goal = this.goal;
    final double pct = (goal == null || goal == 0)
        ? 0
        : (monthRevenue / goal).clamp(0.0, 1.0);
    final int pctInt = (pct * 100).round();

    return Container(
      decoration: _cardDecoration(c),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      s.kpiMonthRevenue,
                      style: AppText.caption125.copyWith(color: c.soft),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    MoneyText(
                      monthRevenue,
                      style: AppText.money24,
                      color: c.anor2,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (goal != null && goal > 0)
                      _GoalProgressLine(
                        revenue: monthRevenue,
                        goal: goal,
                        pct: pctInt,
                      )
                    else
                      PressScale(
                        onTap: () => showGoalSheet(context),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.flag_outlined, size: 15, color: c.anor2),
                            const SizedBox(width: AppSpacing.xxs),
                            Flexible(
                              child: Text(
                                s.setGoalPrompt,
                                style: AppText.body13Bold.copyWith(
                                  color: c.anor2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (goal != null && goal > 0) ...<Widget>[
                const SizedBox(width: AppSpacing.md),
                GestureDetector(
                  onTap: () => showGoalSheet(context, current: goal),
                  child: PlitaRing(
                    value: pct,
                    size: RingSize.profile,
                    tone: RingTone.gradient,
                    label: '$pctInt%',
                    labelStyle: AppText.ringValue17.copyWith(color: c.ink),
                    sublabel: s.goal.toUpperCase(),
                    sublabelStyle: AppText.ringSub9.copyWith(color: c.soft),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(height: 1, color: c.line),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: <Widget>[
              Expanded(
                child: _MiniStat(
                  label: s.overdue,
                  value: MoneyText(
                    debtTotal,
                    style: AppText.money15,
                    color: c.debt,
                    compact: true,
                  ),
                  hint: s.studentsCount(debtors),
                  dot: c.debt,
                ),
              ),
              Container(width: 1, height: 30, color: c.line),
              Expanded(
                child: _MiniStat(
                  label: s.kpiActiveStudents,
                  value: Text(
                    '$active',
                    style: AppText.money15.copyWith(color: c.ok),
                  ),
                  hint: s.statusPaidShort,
                  dot: c.ok,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalProgressLine extends StatelessWidget {
  const _GoalProgressLine({
    required this.revenue,
    required this.goal,
    required this.pct,
  });

  final int revenue;
  final int goal;
  final int pct;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final double frac = (revenue / goal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '${Money.compact(revenue)} / ${Money.compact(goal)} — $pct%',
          style: AppText.body13.copyWith(color: c.soft),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 5,
            child: Stack(
              children: <Widget>[
                Positioned.fill(child: ColoredBox(color: c.glassHi)),
                FractionallySizedBox(
                  widthFactor: frac,
                  child: DecoratedBox(
                    decoration: BoxDecoration(gradient: c.anorGradient),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.hint,
    required this.dot,
  });

  final String label;
  final Widget value;
  final String hint;
  final Color dot;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                style: AppText.caption12.copyWith(color: c.soft),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        value,
        Text(
          hint,
          style: AppText.caption12.copyWith(color: c.dim),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// -------------------------------------------------------------------- BUGUN

class _AllClearRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      decoration: _cardDecoration(c),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadDense,
        vertical: AppSpacing.xl,
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.check_circle_rounded, size: 20, color: c.ok),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              context.s.allClear,
              style: AppText.body14Bold.copyWith(color: c.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayRow extends ConsumerWidget {
  const _TodayRow({required this.student});

  final DashboardStudent student;

  Future<void> _pay(BuildContext context, WidgetRef ref) async {
    final bool? ok = await showPaymentSheet(
      context,
      studentId: student.id,
      studentName: student.name,
      amount: student.tariffPrice,
    );
    if (ok == true) {
      await ref.read(dashboardProvider.notifier).invalidateQuietly();
      await ref.read(statsProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final bool overdue = student.isDebtor;
    final String signal = overdue
        ? '${s.daysOverdueShort(student.daysOverdue ?? 0)} · ${Money.compact(student.tariffPrice)}'
        : '${s.today} · ${Money.compact(student.tariffPrice)}';

    return GestureDetector(
      onTap: () => context.push(Routes.student(student.id)),
      child: Container(
        decoration: _cardDecoration(c),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadDense,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: AppSpacing.md),
              decoration: BoxDecoration(
                color: overdue ? c.debt : c.warn,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    student.name,
                    style: AppText.body14Bold.copyWith(color: c.ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    signal,
                    style: AppText.caption12.copyWith(
                      color: overdue ? c.debt : c.soft,
                    ),
                  ),
                ],
              ),
            ),
            PressScale(
              onTap: () => _pay(context, ref),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  gradient: c.anorGradient,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Text(
                  s.qaPayment,
                  style: AppText.body13Bold.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------- tezkor amallar

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;
    return Row(
      children: <Widget>[
        Expanded(
          child: _QuickAction(
            icon: Icons.add_card_outlined,
            label: s.qaPayment,
            onTap: () => context.go(Routes.students),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _QuickAction(
            icon: Icons.person_add_alt_1_outlined,
            label: s.qaStudent,
            onTap: () => context.push(Routes.studentNew),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _QuickAction(
            icon: Icons.event_available_outlined,
            label: s.qaAttendance,
            onTap: () => showAttendanceSheet(context),
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return PressScale(
      onTap: onTap,
      child: Container(
        decoration: _cardDecoration(c),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.anor2.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 19, color: c.anor2),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: AppText.caption125.copyWith(color: c.ink)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- faoliyat

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.student});

  final DashboardStudent student;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    final (String badge, BadgeTone tone) = switch (student.paymentState) {
      PaymentState.overdue => (s.activityOverdue, BadgeTone.debt),
      PaymentState.dueToday => (s.today, BadgeTone.warn),
      PaymentState.dueSoon => (s.statusPendingShort, BadgeTone.warn),
      PaymentState.paid || PaymentState.none => (s.activityPaid, BadgeTone.ok),
    };

    final String dateText = student.nextDueDate == null
        ? ''
        : s.dayMonth(student.nextDueDate!);

    return GestureDetector(
      onTap: () => context.push(Routes.student(student.id)),
      child: Container(
        decoration: _cardDecoration(c),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadDense,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    student.name,
                    style: AppText.body14Bold.copyWith(color: c.ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (dateText.isNotEmpty)
                    Text(
                      dateText,
                      style: AppText.caption12.copyWith(color: c.soft),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MoneyText(
                  student.tariffPrice,
                  style: AppText.money12,
                  color: c.ink,
                  compact: true,
                ),
                const SizedBox(height: 2),
                StatusBadge(badge, tone: tone),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.xxl,
        AppSpacing.screenEdge,
        AppSpacing.screenBottom,
      ),
      children: const <Widget>[
        Skeleton(height: 44, width: 200),
        SizedBox(height: AppSpacing.xl),
        Skeleton(height: 172, radius: 16),
        SizedBox(height: AppSpacing.sectionGapDense),
        Skeleton(height: 20, width: 100),
        SizedBox(height: AppSpacing.md),
        Skeleton(height: 56, radius: 16),
        SizedBox(height: AppSpacing.sm),
        Skeleton(height: 56, radius: 16),
        SizedBox(height: AppSpacing.sectionGapDense),
        Skeleton(height: 78, radius: 16),
      ],
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 120),
      children: <Widget>[
        EmptyState(
          emoji: '😕',
          title: message,
          actionLabel: context.s.retry,
          onAction: onRetry,
        ),
      ],
    );
  }
}
