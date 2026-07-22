import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/dto/auth_dto.dart';
import 'package:ustoz_trainer/core/api/dto/dashboard_dto.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
import 'package:ustoz_trainer/core/api/dto/payment_dto.dart';
import 'package:ustoz_trainer/core/api/dto/student_dto.dart';
import 'package:ustoz_trainer/core/i18n/lang_provider.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/providers.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/utils/money.dart';
import 'package:ustoz_trainer/core/widgets/app_button.dart';
import 'package:ustoz_trainer/core/widgets/app_toast.dart';
import 'package:ustoz_trainer/core/widgets/avatar.dart';
import 'package:ustoz_trainer/core/widgets/empty_state.dart';
import 'package:ustoz_trainer/core/widgets/heatmap.dart';
import 'package:ustoz_trainer/core/widgets/skeleton.dart';
import 'package:ustoz_trainer/core/widgets/status_badge.dart';
import 'package:ustoz_trainer/features/dashboard/providers/dashboard_provider.dart';
import 'package:ustoz_trainer/features/payments/ui/payment_sheet.dart';
import 'package:ustoz_trainer/features/recommendations/ui/recommendations_view.dart';
import 'package:ustoz_trainer/features/students/providers/students_provider.dart';
import 'package:ustoz_trainer/features/students/ui/student_form_screen.dart';

/// S6 — Shogird profili (REDESIGN, root-1-17).
class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final AsyncValue<Student> async = ref.watch(studentProvider(id));
    final Lang lang = ref.watch(langProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: c.anor2),
          onPressed: context.pop,
        ),
        titleSpacing: 0,
        title: Text(
          s.studentProfileTitle,
          style: AppText.h20.copyWith(color: c.anor2),
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () => ref
                .read(langProvider.notifier)
                .set(lang == Lang.uz ? Lang.ru : Lang.uz),
            child: Container(
              width: 44,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.glassHi,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                lang == Lang.uz ? 'UZ' : 'RU',
                style: AppText.body13Bold.copyWith(color: c.anor2),
              ),
            ),
          ),
          async.maybeWhen(
            data: (Student student) => _MenuButton(student: student),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: async.when(
        loading: () => const _ProfileSkeleton(),
        error: (Object e, StackTrace _) => EmptyState(
          emoji: '😕',
          title: e is AppException ? e.message : s.errGeneric,
          actionLabel: s.retry,
          onAction: () => ref.read(studentProvider(id).notifier).refresh(),
        ),
        data: (Student student) => _Body(student: student),
      ),
    );
  }
}

BoxDecoration _card(AppColors c, {double radius = 18}) => BoxDecoration(
  color: c.glass,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: c.line),
  boxShadow: const <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(17, 24, 39, 0.05),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ],
);

String _dmy(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year}';
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.student});

  final Student student;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  int _tab = 0; // 0 = to'lovlar, 1 = davomad (H2), 2 = tavsiyalar

  Future<void> _pay() async {
    final Student student = widget.student;
    final bool? saved = await showPaymentSheet(
      context,
      studentId: student.id,
      studentName: student.name,
      amount: student.tariffPrice,
      tariffType: student.tariffType,
    );

    if (saved ?? false) {
      await ref.read(studentProvider(student.id).notifier).refresh();
      ref.invalidate(studentsProvider);
      unawaited(ref.read(dashboardProvider.notifier).invalidateQuietly());
    }
  }

  Future<void> _edit() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext _) =>
            StudentFormScreen(existing: widget.student),
      ),
    );
    if (mounted) {
      await ref.read(studentProvider(widget.student.id).notifier).refresh();
    }
  }

  Widget _profileTab(AppColors c, String label, int idx) {
    final bool sel = _tab == idx;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _tab = idx),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: AppText.body15Bold.copyWith(color: sel ? c.anor2 : c.dim),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 28,
            color: sel ? c.anor2 : Colors.transparent,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final Student student = widget.student;

    final bool debtor = student.isDebtor;
    final int balance = student.balance ?? (debtor ? -student.tariffPrice : 0);
    final int totalPaid = student.totalPaid ?? 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.xl,
        AppSpacing.screenH,
        AppSpacing.x7l,
      ),
      children: <Widget>[
        // ── Profil kartasi ──
        Container(
          decoration: _card(c),
          padding: const EdgeInsets.all(AppSpacing.x4l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Avatar(student.name, size: 88, url: student.avatarUrl),
                  const SizedBox(width: AppSpacing.x3l),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          student.name,
                          style: AppText.h20.copyWith(color: c.ink),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          debtor ? s.badgeDebt : s.badgePaid,
                          style: AppText.body13Bold.copyWith(
                            color: debtor ? c.debt : c.ok,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x4l),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _MiniStat(
                      label: s.monthlyFeeLabel,
                      value: Money.withUnit(student.tariffPrice),
                      color: c.anor2,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: _MiniStat(
                      label: s.totalPaidLabel,
                      value: Money.withUnit(totalPaid),
                      color: c.ok,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // ── Joriy balans (navy karta) ──
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: c.anor2,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(AppSpacing.x4l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      s.currentBalance,
                      style: AppText.body14.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      Money.withUnit(balance),
                      style: AppText.money24.copyWith(
                        color: balance < 0
                            ? const Color(0xFFFF8A78)
                            : Colors.white,
                        fontSize: 28,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Expanded(
                    child: GradientButton(label: s.addPayment, onPressed: _pay),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  GhostIconButton(
                    size: 54,
                    radius: 16,
                    onPressed: _edit,
                    child: Icon(Icons.edit_outlined, size: 22, color: c.anor2),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // ── To'lovlar tarixi / Tavsiyalar (F2) ──
        Container(
          decoration: _card(c),
          padding: const EdgeInsets.all(AppSpacing.x4l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _profileTab(c, s.paymentHistory, 0),
                  const SizedBox(width: AppSpacing.md),
                  _profileTab(c, s.attendance, 1),
                  const SizedBox(width: AppSpacing.md),
                  _profileTab(c, s.recommendationsTab, 2),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              switch (_tab) {
                0 => _PaymentsHistory(
                  studentId: student.id,
                  tariffPrice: student.tariffPrice,
                ),
                1 => _AttendanceTab(studentId: student.id),
                _ => RecommendationsTab(
                  studentId: student.id,
                  studentName: student.name,
                ),
              },
            ],
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
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: c.glassHi,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: AppText.body13.copyWith(color: c.soft),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppText.body15Bold.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PaymentsHistory extends ConsumerWidget {
  const _PaymentsHistory({required this.studentId, required this.tariffPrice});

  final String studentId;
  final int tariffPrice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    return FutureBuilder<PagedPayments>(
      future: ref.read(studentRepositoryProvider).payments(studentId),
      builder: (BuildContext context, AsyncSnapshot<PagedPayments> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Skeleton(height: 140, radius: 12);
        }
        if (snap.hasError) {
          return EmptyState(
            emoji: '😕',
            title: snap.error is AppException
                ? (snap.error! as AppException).message
                : s.errGeneric,
            compact: true,
          );
        }

        final List<Payment> items = snap.data?.items ?? const <Payment>[];
        if (items.isEmpty) {
          return EmptyState(emoji: '🧾', title: s.noPayments, compact: true);
        }

        return Column(
          children: <Widget>[
            for (final Payment p in items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Container(
                  decoration: BoxDecoration(
                    color: c.glassHi,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              Money.withUnit(p.amount),
                              style: AppText.body15Bold.copyWith(color: c.ink),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              _dmy(p.paidAt),
                              style: AppText.body13.copyWith(color: c.soft),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(
                        p.amount >= tariffPrice
                            ? s.paymentPaid
                            : s.paymentPartial,
                        tone: p.amount >= tariffPrice
                            ? BadgeTone.ok
                            : BadgeTone.warn,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Davomad tabi (H2) — `/students/{id}/attendance` → heatmap.
class _AttendanceTab extends ConsumerWidget {
  const _AttendanceTab({required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    return FutureBuilder<AttendanceList>(
      future: ref.read(studentRepositoryProvider).attendance(studentId),
      builder: (BuildContext context, AsyncSnapshot<AttendanceList> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Skeleton(height: 160, radius: 12);
        }
        if (snap.hasError) {
          return EmptyState(
            emoji: '😕',
            title: snap.error is AppException
                ? (snap.error! as AppException).message
                : s.errGeneric,
            compact: true,
          );
        }
        final AttendanceList list =
            snap.data ?? const AttendanceList(items: <AttendanceDay>[]);
        if (list.items.isEmpty) {
          return EmptyState(emoji: '📅', title: s.noAttendance, compact: true);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(s.lastWeeks, style: AppText.body13.copyWith(color: c.soft)),
            const SizedBox(height: AppSpacing.lg),
            Heatmap(
              levels: Heatmap.fromDays(
                attended: list.days,
                end: DateTime.now(),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Amallar menyusi: tahrirlash · taklif · arxivlash.
class _MenuButton extends ConsumerWidget {
  const _MenuButton({required this.student});

  final Student student;

  Future<void> _invite(BuildContext context, WidgetRef ref) async {
    try {
      final TgLink link = await ref
          .read(studentRepositoryProvider)
          .inviteLink(student.id);
      await SharePlus.instance.share(ShareParams(text: link.link));
    } on AppException catch (e) {
      if (context.mounted) {
        AppToast.show(context, e.message);
      }
    }
  }

  Future<void> _archive(BuildContext context, WidgetRef ref) async {
    final AppStrings s = context.s;
    final AppColors c = context.colors;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: c.sheet,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(s.delete, style: AppText.h18.copyWith(color: c.ink)),
        content: Text(
          s.archiveConfirm,
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
            label: s.delete,
            size: AppButtonSize.small,
            expand: false,
            color: c.debt,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await ref.read(studentProvider(student.id).notifier).archive();
        if (context.mounted) {
          AppToast.show(context, s.archived);
        }
      } on AppException catch (e) {
        if (context.mounted) {
          AppToast.show(context, e.message);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz, color: c.anor2),
      color: c.sheet,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      onSelected: (String action) async {
        switch (action) {
          case 'invite':
            await _invite(context, ref);
          case 'archive':
            await _archive(context, ref);
        }
      },
      itemBuilder: (BuildContext _) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'invite',
          child: Text(
            s.inviteSend,
            style: AppText.body14.copyWith(color: c.ink),
          ),
        ),
        PopupMenuItem<String>(
          value: 'archive',
          child: Text(s.delete, style: AppText.body14.copyWith(color: c.debt)),
        ),
      ],
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenH),
      children: const <Widget>[
        Skeleton(height: 280, radius: 18),
        SizedBox(height: AppSpacing.xl),
        Skeleton(height: 200, radius: 18),
      ],
    );
  }
}
