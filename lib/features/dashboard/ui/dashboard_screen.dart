import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/dto/dashboard_dto.dart';
import 'package:ustoz_trainer/core/api/dto/session_dto.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/router/app_router.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/utils/money.dart';
import 'package:ustoz_trainer/core/widgets/empty_state.dart';
import 'package:ustoz_trainer/core/widgets/press_scale.dart';
import 'package:ustoz_trainer/core/widgets/skeleton.dart';
import 'package:ustoz_trainer/features/attendance/ui/attendance_sheet.dart';
import 'package:ustoz_trainer/features/dashboard/providers/dashboard_provider.dart';
import 'package:ustoz_trainer/features/dashboard/providers/sessions_provider.dart';
import 'package:ustoz_trainer/features/payments/ui/payment_sheet.dart';
import 'package:ustoz_trainer/features/schedule_requests/ui/link_requests_card.dart';
import 'package:ustoz_trainer/features/schedule_requests/ui/schedule_requests_card.dart';
import 'package:ustoz_trainer/features/stats/ui/stats_screen.dart';

/// S4 — Bosh sahifa (prototip v3 kompozitsiyasi): salom qatori · Kassa svetofori
/// (to'langan/yaqin/qarzdor) · stat kartalar (Bugun keldi · Faol shogird) ·
/// BUGUN ro'yxati · tezkor amallar.
///
/// Churn radar, streak va "Bugungi lenta" (sessiyalar) backend endpointlari
/// tayyor bo'lgach qo'shiladi (PROTO-V3-MAP.md — ma'lumot-gap). Soxta ma'lumot
/// ishlatilmaydi.
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

/// Prototip karta: `--s1` sirt, `--bd` chegara, radius 20 (AppRadius.card).
BoxDecoration _cardDecoration(AppColors c, {double radius = AppRadius.card}) {
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

/// Katta Unbounded raqam (stat kartalar / svetofor) — prototip 24–32px.
TextStyle _numStyle(double size) => TextStyle(
  fontFamily: AppText.displayFamily,
  fontWeight: FontWeight.w600,
  fontSize: size,
  height: 1,
  letterSpacing: -0.02 * size / 32,
  fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
);

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = context.s;
    final DashboardResponse d = data.value;

    final StatsResponse? stats = ref.watch(statsProvider).value;
    final int debtTotal = stats?.debtTotal ?? d.totals?.overdueAmount ?? 0;
    final int active = stats?.activeStudents ?? 0;
    final List<ChurnCard> churn = stats?.churn ?? const <ChurnCard>[];
    final List<SessionDto> sessions = ref
        .watch(todaySessionsProvider)
        .maybeWhen(
          data: (List<SessionDto> x) => x,
          orElse: () => const <SessionDto>[],
        );

    // Kassa svetofori countlari (real).
    final int soon = d.dueSoon.length;
    final int debt = d.overdue.length;
    // "to'langan" = faol shogirdlardan yaqin/qarzdor/bugun-to'lovlarni ayirib.
    final int paid = (active - soon - debt - d.dueToday.length).clamp(
      0,
      active <= 0 ? 0 : active,
    );

    // BUGUN — kechikkanlar avval, keyin bugun to'lashi kerak. Maksimal 3.
    final List<DashboardStudent> today = <DashboardStudent>[
      ...d.overdue,
      ...d.dueToday,
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.xxl,
        AppSpacing.screenEdge,
        AppSpacing.screenBottom,
      ),
      children: <Widget>[
        _GreetingRow(
          name: d.greetingName,
          notif: d.overdue.length,
          streakDays: d.streakDays,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Inbound bog'lanish so'rovlari (D122 sync) — bo'lsa ko'rinadi.
        const LinkRequestsCard(),

        // «Kelolmayman» so'rovlari (D122) — bo'lsa ko'rinadi.
        const ScheduleRequestsCard(),

        // Kassa svetofori.
        _KassaSvetofori(
          paid: paid,
          soon: soon,
          debt: debt,
          debtTotal: debtTotal,
          onTap: () => context.go(Routes.cash),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Stat kartalar: Bugun keldi · Faol shogird.
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: _StatCard(
                label: s.cameToday,
                value: '${d.attendanceToday.markedCount}',
                accent: context.colors.ok,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _StatCard(
                label: s.kpiActiveStudents,
                value: '$active',
                accent: context.colors.anor2,
                onTap: () => context.go(Routes.students),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sectionGapDense),

        // Churn radar — eng shoshilinch risk kartasi (bor bo'lsa).
        if (churn.isNotEmpty) ...<Widget>[
          _ChurnCardView(card: churn.first),
          const SizedBox(height: AppSpacing.sectionGapDense),
        ],

        // Bugungi lenta — bugungi mashg'ulot slotlari (real /sessions).
        if (sessions.isNotEmpty) ...<Widget>[
          Text(s.todayFeed, style: _sectionStyle(context)),
          const SizedBox(height: AppSpacing.md),
          for (final SessionDto sess in sessions)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _SessionRow(session: sess),
            ),
          const SizedBox(height: AppSpacing.sectionGapDense),
        ],

        // BUGUN.
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

        // Tezkor amallar.
        const SizedBox(height: AppSpacing.sectionGapDense),
        const _QuickActions(),
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
    this.streakDays = 0,
  });

  final String name;
  final int notif;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Text(
            s.greeting(name),
            style: AppText.h20.copyWith(color: c.anor2),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (streakDays > 0) ...<Widget>[
          _StreakPill(days: streakDays),
          const SizedBox(width: AppSpacing.sm),
        ],
        GestureDetector(
          onTap: () => context.push(Routes.notifications),
          child: _BellButton(count: notif),
        ),
      ],
    );
  }
}

/// Faollik streaki pili — alanga + "N kun" (prototip v3 header).
class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: c.warnSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.warn.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.local_fire_department_rounded, size: 15, color: c.warn),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            context.s.streakLabel(days),
            style: AppText.body13Bold.copyWith(color: c.warn),
          ),
        ],
      ),
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
            decoration: BoxDecoration(
              color: c.glassHi,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: c.line),
            ),
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

// ------------------------------------------------------------- Kassa svetofori

class _KassaSvetofori extends StatelessWidget {
  const _KassaSvetofori({
    required this.paid,
    required this.soon,
    required this.debt,
    required this.debtTotal,
    required this.onTap,
  });

  final int paid;
  final int soon;
  final int debt;
  final int debtTotal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    return PressScale(
      onTap: onTap,
      child: Container(
        decoration: _cardDecoration(c),
        padding: const EdgeInsets.all(AppSpacing.x3l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    s.kassaTrafficLight,
                    style: AppText.caption125.copyWith(color: c.soft),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 18, color: c.dim),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: <Widget>[
                Expanded(
                  child: _TrafficTile(
                    icon: Icons.check_rounded,
                    count: paid,
                    label: s.tlPaid,
                    fg: c.ok,
                    bg: c.okSoft,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _TrafficTile(
                    icon: Icons.schedule_rounded,
                    count: soon,
                    label: s.tlSoon,
                    fg: c.warn,
                    bg: c.warnSoft,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _TrafficTile(
                    icon: Icons.warning_amber_rounded,
                    count: debt,
                    label: s.tlDebt,
                    fg: c.debt,
                    bg: c.debtSoft,
                  ),
                ),
              ],
            ),
            if (debt > 0) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Text(
                s.redsDebt(Money.compact(debtTotal)),
                style: AppText.body13Bold.copyWith(color: c.debt),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrafficTile extends StatelessWidget {
  const _TrafficTile({
    required this.icon,
    required this.count,
    required this.label,
    required this.fg,
    required this.bg,
  });

  final IconData icon;
  final int count;
  final String label;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: fg.withValues(alpha: 0.22)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 13, color: fg),
              const SizedBox(width: 5),
              Text('$count', style: _numStyle(24).copyWith(color: fg)),
            ],
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: AppText.label115.copyWith(color: context.colors.soft),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ stat karta

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.accent,
    this.onTap,
  });

  final String label;
  final String value;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Widget card = Container(
      decoration: _cardDecoration(c),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(label, style: AppText.caption125.copyWith(color: c.soft)),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: _numStyle(30).copyWith(color: accent)),
        ],
      ),
    );
    if (onTap == null) {
      return card;
    }
    return PressScale(onTap: onTap!, child: card);
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

// ---------------------------------------------------------------- churn radar

/// "Ketish riski" kartasi — riskdagi shogird + tez amallar (prototip v3).
class _ChurnCardView extends StatelessWidget {
  const _ChurnCardView({required this.card});

  final ChurnCard card;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    return Container(
      decoration: BoxDecoration(
        color: c.debtSoft,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: c.debt.withValues(alpha: 0.35)),
      ),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.debt,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.gps_fixed_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      s.churnRiskTitle(card.name),
                      style: AppText.body14Bold.copyWith(color: c.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.churnReason(card.reason),
                      style: AppText.body13.copyWith(color: c.soft),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: PressScale(
                  onTap: () => context.push(Routes.student(card.studentId)),
                  child: Container(
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.debt,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Text(
                      s.churnSendMessage,
                      style: AppText.body13Bold.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              PressScale(
                onTap: () => context.go(Routes.stats),
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.glass,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: c.line),
                  ),
                  child: Text(
                    s.churnRadar,
                    style: AppText.body13Bold.copyWith(color: c.ink),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- bugungi lenta

/// "Bugungi lenta" qatori — vaqt + shogird/guruh + konflikt belgisi (real slot).
class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session});

  final SessionDto session;

  /// Asia/Tashkent (UTC+5) devor-soati "HH:mm".
  String get _hhmm {
    final DateTime t = session.startsAt.toUtc().add(const Duration(hours: 5));
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool done = session.status == 'done';

    final Widget row = Container(
      decoration: _cardDecoration(c),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadDense,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: <Widget>[
          Text(_hhmm, style: _numStyle(16).copyWith(color: c.ink)),
          const SizedBox(width: AppSpacing.md),
          Container(width: 1, height: 30, color: c.line),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    session.displayName,
                    style: AppText.body14Bold.copyWith(color: c.ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (session.conflict) ...<Widget>[
                  const SizedBox(width: AppSpacing.xs),
                  Icon(Icons.warning_amber_rounded, size: 15, color: c.warn),
                ],
              ],
            ),
          ),
          if (done)
            Icon(Icons.check_circle_rounded, size: 18, color: c.ok)
          else
            Icon(Icons.chevron_right_rounded, size: 18, color: c.dim),
        ],
      ),
    );

    if (session.studentId == null) {
      return row;
    }
    return GestureDetector(
      onTap: () => context.push(Routes.student(session.studentId!)),
      child: row,
    );
  }
}

// ------------------------------------------------------------------ skeleton

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
        Skeleton(height: 118, radius: AppRadius.card),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: <Widget>[
            Expanded(child: Skeleton(height: 86, radius: AppRadius.card)),
            SizedBox(width: AppSpacing.lg),
            Expanded(child: Skeleton(height: 86, radius: AppRadius.card)),
          ],
        ),
        SizedBox(height: AppSpacing.sectionGapDense),
        Skeleton(height: 20, width: 100),
        SizedBox(height: AppSpacing.md),
        Skeleton(height: 56, radius: AppRadius.card),
        SizedBox(height: AppSpacing.sm),
        Skeleton(height: 56, radius: AppRadius.card),
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
