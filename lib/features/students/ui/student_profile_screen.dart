import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/dto/auth_dto.dart';
import 'package:ustoz_trainer/core/api/dto/dashboard_dto.dart';
import 'package:ustoz_trainer/core/api/dto/payment_dto.dart';
import 'package:ustoz_trainer/core/api/dto/student_dto.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/providers.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/utils/money.dart';
import 'package:ustoz_trainer/core/widgets/app_button.dart';
import 'package:ustoz_trainer/core/widgets/app_toast.dart';
import 'package:ustoz_trainer/core/widgets/empty_state.dart';
import 'package:ustoz_trainer/core/widgets/glass_card.dart';
import 'package:ustoz_trainer/core/widgets/heatmap.dart';
import 'package:ustoz_trainer/core/widgets/list_row.dart';
import 'package:ustoz_trainer/core/widgets/plita_ring.dart';
import 'package:ustoz_trainer/core/widgets/section_header.dart';
import 'package:ustoz_trainer/core/widgets/skeleton.dart';
import 'package:ustoz_trainer/core/widgets/status_badge.dart';
import 'package:ustoz_trainer/features/dashboard/providers/dashboard_provider.dart';
import 'package:ustoz_trainer/features/payments/ui/payment_sheet.dart';
import 'package:ustoz_trainer/features/students/providers/students_provider.dart';
import 'package:ustoz_trainer/features/students/ui/student_form_screen.dart';

/// S6 — shogird profili.
class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final AsyncValue<Student> async = ref.watch(studentProvider(id));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: c.ink),
          onPressed: context.pop,
        ),
        title: Text(s.student, style: AppText.h17.copyWith(color: c.ink)),
        actions: <Widget>[
          async.maybeWhen(
            data: (Student student) => _MenuButton(student: student),
            orElse: () => const SizedBox.shrink(),
          ),
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

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.student});

  final Student student;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  int _tab = 0;

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

  Future<void> _remind() async {
    final AppStrings s = context.s;
    try {
      final RemindResponse r = await ref
          .read(studentRepositoryProvider)
          .remind(widget.student.id);
      if (mounted) {
        AppToast.show(context, r.warning ?? s.reminderSent);
      }
    } on ValidationException catch (e) {
      // Kontrakt: 422 `student_not_connected`.
      if (mounted) {
        AppToast.show(context, e.message);
      }
    } on AppException catch (e) {
      if (mounted) {
        AppToast.show(context, e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final Student student = widget.student;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.sm,
        AppSpacing.screenH,
        AppSpacing.x7l,
      ),
      children: <Widget>[
        _Hero(student: student, onPay: _pay, onRemind: _remind),

        const SizedBox(height: AppSpacing.xl),
        _StatTiles(student: student),

        // Tablar.
        const SizedBox(height: AppSpacing.sectionGap),
        Row(
          spacing: AppSpacing.sm,
          children: <Widget>[
            for (final (int i, String label) in <String>[
              s.paymentHistory,
              s.attendance,
            ].indexed)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _tab = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _tab == i ? c.anor : c.line,
                          width: _tab == i ? 2 : 1,
                        ),
                      ),
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: AppText.body13Bold.copyWith(
                        color: _tab == i ? c.ink : c.dim,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        if (_tab == 0)
          _PaymentsTab(studentId: student.id)
        else
          _AttendanceTab(studentId: student.id),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.student,
    required this.onPay,
    required this.onRemind,
  });

  final Student student;
  final VoidCallback onPay;
  final VoidCallback onRemind;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    final int overdue = student.daysOverdue ?? 0;
    final bool debt = overdue > 0;

    return GlassCard.hero(
      overlay: const RadialGradient(
        center: Alignment(0.6, -1),
        radius: 1.1,
        colors: <Color>[Color.fromRGBO(255, 83, 64, 0.12), Colors.transparent],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              PlitaRing(
                value: debt ? 1 : 0.7,
                size: RingSize.profile,
                tone: debt ? RingTone.gradient : RingTone.ok,
                label: debt ? '$overdue' : null,
                sublabel: debt ? s.overdue.toUpperCase() : null,
              ),
              const SizedBox(width: AppSpacing.x3l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      student.name,
                      style: AppText.h19.copyWith(color: c.ink),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      student.phone,
                      style: AppText.body13.copyWith(color: c.soft),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: <Widget>[
                        StatusBadge(
                          debt
                              ? '${s.filterDebtors} · '
                                    '${Money.format(student.tariffPrice)}'
                              : s.filterActive,
                          tone: debt ? BadgeTone.debt : BadgeTone.ok,
                        ),
                        StatusBadge(
                          student.tgConnected
                              ? '${s.telegram} ✓'
                              : s.tgNotConnected,
                          tone: student.tgConnected
                              ? BadgeTone.ok
                              : BadgeTone.neutral,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x3l),
          Row(
            spacing: AppSpacing.sm,
            children: <Widget>[
              Expanded(
                child: GradientButton(
                  label: s.addPayment,
                  size: AppButtonSize.small,
                  onPressed: onPay,
                ),
              ),
              Expanded(
                child: GhostButton(
                  label: s.remind,
                  size: AppButtonSize.small,
                  onPressed: student.tgConnected ? onRemind : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTiles extends StatelessWidget {
  const _StatTiles({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    final int? left = student.sessionsLeft;
    final int months =
        DateTime.now().difference(student.createdAt).inDays ~/ 30;

    return Row(
      spacing: AppSpacing.md,
      children: <Widget>[
        _Tile(
          value: Money.compact(student.tariffPrice),
          label: s.tariff.toUpperCase(),
        ),
        _Tile(
          value: '$months',
          label: s.streakDays(0).replaceAll('0 ', '').toUpperCase(),
        ),
        _Tile(
          value: left == null ? '${student.sessionsUsed}' : '$left',
          label: s.attendance.toUpperCase(),
          color: left != null && left <= 2 ? c.warn : null,
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.value, required this.label, this.color});

  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              value,
              style: AppText.money17.copyWith(color: color ?? c.ink),
              maxLines: 1,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.label11.copyWith(color: c.dim),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentsTab extends ConsumerWidget {
  const _PaymentsTab({required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    return FutureBuilder<PagedPayments>(
      future: ref.read(studentRepositoryProvider).payments(studentId),
      builder: (BuildContext context, AsyncSnapshot<PagedPayments> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Skeleton(height: 160, radius: AppRadius.card);
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
          return GlassCard(
            child: EmptyState(emoji: '🧾', title: s.noPayments, compact: true),
          );
        }

        return GlassCard(
          child: ListRowGroup(
            rows: <ListRow>[
              for (final Payment p in items)
                ListRow(
                  title: p.periodFrom == null
                      ? s.dayMonth(p.paidAt)
                      : s.dayMonth(p.periodFrom!),
                  subtitle:
                      '${s.methodName(p.method)} · ${s.dayMonth(p.paidAt)}',
                  trailing: Text(
                    Money.format(p.amount),
                    style: AppText.money14.copyWith(color: c.ink),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AttendanceTab extends ConsumerWidget {
  const _AttendanceTab({required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = context.s;
    final DateTime today = DateTime.now();

    return FutureBuilder<AttendanceList>(
      future: ref
          .read(studentRepositoryProvider)
          .attendance(
            studentId,
            from: today.subtract(const Duration(days: 55)),
            to: today,
          ),
      builder: (BuildContext context, AsyncSnapshot<AttendanceList> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Skeleton(height: 160, radius: AppRadius.card);
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SectionHeader(s.attendance, trailing: s.lastWeeks),
            GlassCard(
              child: Heatmap(
                levels: Heatmap.fromDays(attended: list.days, end: today),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
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
      icon: Icon(Icons.more_horiz, color: c.ink),
      color: c.sheet,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      onSelected: (String action) async {
        switch (action) {
          case 'edit':
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext _) =>
                    StudentFormScreen(existing: student),
              ),
            );
          case 'invite':
            await _invite(context, ref);
          case 'archive':
            await _archive(context, ref);
        }
      },
      itemBuilder: (BuildContext _) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit',
          child: Text(s.edit, style: AppText.body14.copyWith(color: c.ink)),
        ),
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
        Skeleton(height: 200, radius: AppRadius.card),
        SizedBox(height: AppSpacing.xl),
        Skeleton(height: 78, radius: AppRadius.card),
        SizedBox(height: AppSpacing.sectionGap),
        Skeleton(height: 160, radius: AppRadius.card),
      ],
    );
  }
}
