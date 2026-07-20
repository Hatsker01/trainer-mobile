import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/dto/dashboard_dto.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
import 'package:ustoz_trainer/core/api/dto/student_dto.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/providers.dart';
import 'package:ustoz_trainer/core/router/app_router.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/utils/money.dart';
import 'package:ustoz_trainer/core/widgets/app_button.dart';
import 'package:ustoz_trainer/core/widgets/app_toast.dart';
import 'package:ustoz_trainer/core/widgets/empty_state.dart';
import 'package:ustoz_trainer/core/widgets/glass_card.dart';
import 'package:ustoz_trainer/core/widgets/plita_ring.dart';
import 'package:ustoz_trainer/core/widgets/section_header.dart';
import 'package:ustoz_trainer/core/widgets/skeleton.dart';
import 'package:ustoz_trainer/core/widgets/status_badge.dart';
import 'package:ustoz_trainer/core/widgets/student_card.dart';
import 'package:ustoz_trainer/features/dashboard/providers/dashboard_provider.dart';
import 'package:ustoz_trainer/features/payments/ui/payment_sheet.dart';

/// S4 — flagman ekran.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DashboardData> async = ref.watch(dashboardProvider);
    final AppStrings s = context.s;

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
      backgroundColor: context.colors.sheet,
      color: context.colors.anor,
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

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final DashboardResponse d = data.value;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.x4l,
        AppSpacing.screenH,
        AppSpacing.screenBottom,
      ),
      children: <Widget>[
        _Header(date: d.date, name: d.greetingName, stale: data.stale),
        const SizedBox(height: AppSpacing.x4l),
        _HeroCard(data: d),

        if (d.isAllClear)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sectionGap),
            child: GlassCard(
              child: EmptyState(emoji: '💪', title: s.allClear),
            ),
          ),

        if (d.overdue.isNotEmpty)
          _StudentSection(
            title: s.overdue,
            students: d.overdue,
            tone: SectionCountTone.anor,
            total: d.totals?.overdueAmount,
          ),

        if (d.dueToday.isNotEmpty)
          _StudentSection(
            title: s.dueToday,
            students: d.dueToday,
            tone: SectionCountTone.warn,
            total: d.totals?.dueTodayAmount,
          ),

        if (d.dueSoon.isNotEmpty)
          _StudentSection(
            title: s.dueSoon,
            students: d.dueSoon,
            tone: SectionCountTone.warn,
          ),

        // Bugungi davomad — kontraktda faqat `marked_count` bor,
        // shuning uchun timeline emas, hisob ko'rsatiladi.
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sectionGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SectionHeader(s.attendance),
              GlassCard(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.check_circle_outline, size: 20, color: c.ok),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Text(
                        s.attendanceSaved(d.attendanceToday.markedCount),
                        style: AppText.body14Bold.copyWith(color: c.ink),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.date, required this.name, required this.stale});

  final DateTime date;
  final String name;
  final bool stale;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                s.weekdayDayMonth(date),
                style: AppText.body13.copyWith(color: c.dim),
              ),
              const SizedBox(height: 3),
              Text(
                s.greeting(name),
                style: AppText.display24.copyWith(color: c.ink),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // T8: kesh ko'rsatilayotgani haqida indikator.
        if (stale) const StatusBadge('⟳'),
      ],
    );
  }
}

/// Hero — oylik daromad ringi.
///
/// **Diqqat:** `/dashboard` da daromad summasi YO'Q (kontraktda faqat
/// `totals.due_today_amount` / `overdue_amount`). Oylik daromad
/// `/stats` da. Shuning uchun hero ring qarzdorlik ulushini ko'rsatadi:
/// bu dashboard'dagi eng muhim raqam va u mavjud ma'lumotdan hisoblanadi.
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.data});

  final DashboardResponse data;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    final int overdueAmount = data.totals?.overdueAmount ?? 0;
    final int dueTodayAmount = data.totals?.dueTodayAmount ?? 0;
    final int expected = overdueAmount + dueTodayAmount;

    // Ring: bugun kutilayotgan summaning nechasi hali yig'ilmagan.
    final double progress = expected == 0
        ? 1
        : (dueTodayAmount / expected).clamp(0.0, 1.0);

    final RingTone tone = overdueAmount > 0
        ? RingTone.debt
        : dueTodayAmount > 0
        ? RingTone.warn
        : RingTone.ok;

    return GlassCard.hero(
      overlay: const RadialGradient(
        center: Alignment(-0.6, -1),
        radius: 1.1,
        colors: <Color>[Color.fromRGBO(255, 83, 64, 0.14), Colors.transparent],
      ),
      child: Row(
        children: <Widget>[
          PlitaRing(
            value: progress,
            size: RingSize.hero,
            tone: tone,
            label: '${data.dueToday.length + data.overdue.length}',
            labelStyle: AppText.ringValue17.copyWith(color: c.ink),
          ),
          const SizedBox(width: AppSpacing.x4l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  s.dueToday,
                  style: AppText.caption125.copyWith(color: c.soft),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  Money.format(dueTodayAmount),
                  style: AppText.money24.copyWith(color: c.ink),
                ),
                if (overdueAmount > 0) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  StatusBadge(
                    '${s.overdue}: ${Money.compact(overdueAmount)}',
                    tone: BadgeTone.debt,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shogirdlar bloki — karta + amal tugmalari.
class _StudentSection extends ConsumerWidget {
  const _StudentSection({
    required this.title,
    required this.students,
    required this.tone,
    this.total,
  });

  final String title;
  final List<DashboardStudent> students;
  final SectionCountTone tone;
  final int? total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SectionHeader(
            title,
            count: students.length,
            countTone: tone,
            trailing: total == null ? null : Money.withUnit(total!),
          ),
          for (final DashboardStudent student in students)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
              child: _DashboardStudentCard(student: student),
            ),
        ],
      ),
    );
  }
}

class _DashboardStudentCard extends ConsumerStatefulWidget {
  const _DashboardStudentCard({required this.student});

  final DashboardStudent student;

  @override
  ConsumerState<_DashboardStudentCard> createState() =>
      _DashboardStudentCardState();
}

class _DashboardStudentCardState extends ConsumerState<_DashboardStudentCard> {
  bool _reminding = false;

  Future<void> _remind() async {
    if (_reminding) {
      return;
    }
    setState(() => _reminding = true);

    final AppStrings s = context.s;
    try {
      final RemindResponse r = await ref
          .read(studentRepositoryProvider)
          .remind(widget.student.id);

      if (!mounted) {
        return;
      }
      // Kontrakt: `warning` — kuniga 3 martadan ko'p eslatilgan.
      AppToast.show(context, r.warning ?? s.reminderSent);
    } on AppException catch (e) {
      if (mounted) {
        AppToast.show(context, e.message);
      }
    } finally {
      if (mounted) {
        setState(() => _reminding = false);
      }
    }
  }

  Future<void> _pay() async {
    final bool? saved = await showPaymentSheet(
      context,
      studentId: widget.student.id,
      studentName: widget.student.name,
      amount: widget.student.tariffPrice,
    );
    if (saved ?? false) {
      await ref.read(dashboardProvider.notifier).invalidateQuietly();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;
    final DashboardStudent student = widget.student;

    final (
      RingTone tone,
      BadgeTone badgeTone,
      String badgeLabel,
    ) = switch (student.paymentState) {
      PaymentState.overdue => (
        RingTone.debt,
        BadgeTone.debt,
        '${student.daysOverdue ?? 0} ${s.streakDays(student.daysOverdue ?? 0)}',
      ),
      PaymentState.dueToday => (RingTone.warn, BadgeTone.warn, s.today),
      PaymentState.dueSoon => (
        RingTone.warn,
        BadgeTone.warn,
        student.nextDueDate == null
            ? s.dueSoon
            : s.dayMonth(student.nextDueDate!),
      ),
      PaymentState.paid ||
      PaymentState.none => (RingTone.ok, BadgeTone.ok, s.filterActive),
    };

    return StudentCard(
      name: student.name,
      subtitle: Text(Money.format(student.tariffPrice)),
      ringValue: student.paymentState == PaymentState.overdue ? 1 : 0.5,
      ringTone: tone,
      ringLabel: student.isDebtor ? '!' : null,
      debt: student.isDebtor,
      badge: StatusBadge(badgeLabel, tone: badgeTone),
      trailingText: Money.format(student.tariffPrice),
      onTap: () => context.push(Routes.student(student.id)),
      actions: Row(
        spacing: AppSpacing.sm,
        children: <Widget>[
          Expanded(
            child: GradientButton(
              label: s.markPaid,
              size: AppButtonSize.small,
              onPressed: _pay,
            ),
          ),
          Expanded(
            child: GhostButton(
              label: s.remind,
              size: AppButtonSize.small,
              onPressed: _reminding ? null : _remind,
            ),
          ),
        ],
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
        AppSpacing.screenH,
        AppSpacing.x4l,
        AppSpacing.screenH,
        AppSpacing.screenBottom,
      ),
      children: const <Widget>[
        Skeleton(height: 28, width: 180),
        SizedBox(height: AppSpacing.x4l),
        Skeleton(height: 162, radius: AppRadius.card),
        SizedBox(height: AppSpacing.sectionGap),
        Skeleton(height: 20, width: 140),
        SizedBox(height: AppSpacing.sectionHeaderGap),
        Skeleton(height: 130, radius: AppRadius.card),
        SizedBox(height: AppSpacing.cardGap),
        Skeleton(height: 130, radius: AppRadius.card),
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
    // `ListView` — `RefreshIndicator` ishlashi uchun scroll kerak.
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
