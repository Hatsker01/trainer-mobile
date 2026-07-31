import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/widgets/app_toast.dart';
import 'package:ustoz_trainer/features/schedule_requests/providers/schedule_requests_provider.dart';

/// «Kelolmayman» so'rovlari kartasi — trener «Bugun» ekranida (C5, D122).
///
/// Shogird jadval o'zgarishini so'raganда shu yerda ko'rinadi; trener
/// tasdiqlaydi / rad etadi / yangi vaqt taklif qiladi. So'rov bo'lmasa —
/// karta ko'rinmaydi (bo'sh joy egallamaydi).
class ScheduleRequestsCard extends ConsumerWidget {
  const ScheduleRequestsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ScheduleRequest>> reqs =
        ref.watch(pendingScheduleRequestsProvider);
    final list = reqs.asData?.value ?? const <ScheduleRequest>[];
    if (list.isEmpty) return const SizedBox.shrink();

    final AppColors c = context.colors;
    final AppStrings s = context.s;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.glass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.warn.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.event_busy, size: 18, color: c.warn),
              const SizedBox(width: 8),
              Text(s.srTitle, style: AppText.section15.copyWith(color: c.ink)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: c.warn.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${list.length}',
                    style: AppText.body13Bold.copyWith(color: c.warn)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final ScheduleRequest r in list)
            _RequestRow(req: r),
        ],
      ),
    );
  }
}

class _RequestRow extends ConsumerWidget {
  const _RequestRow({required this.req});

  final ScheduleRequest req;

  Future<void> _respond(
    BuildContext context,
    WidgetRef ref,
    String action, {
    String? proposedTime,
  }) async {
    final AppStrings s = context.s;
    try {
      await ref
          .read(scheduleRequestsRepoProvider)
          .respond(req.id, action, proposedTime: proposedTime);
      ref.invalidate(pendingScheduleRequestsProvider);
      if (context.mounted) AppToast.show(context, s.srDone);
    } on Exception {
      if (context.mounted) AppToast.show(context, s.retry);
    }
  }

  Future<void> _reschedule(BuildContext context, WidgetRef ref) async {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final ctrl = TextEditingController();
    final String? time = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: c.sheet,
      isScrollControlled: true,
      builder: (BuildContext ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(s.srReschedule, style: AppText.section15.copyWith(color: c.ink)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.datetime,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                LengthLimitingTextInputFormatter(5),
              ],
              style: AppText.body14.copyWith(color: c.ink),
              decoration: InputDecoration(
                hintText: s.srNewTime,
                hintStyle: AppText.body14.copyWith(color: c.dim),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
              child: Text(s.srSend),
            ),
          ],
        ),
      ),
    );
    if (time == null || time.isEmpty) return;
    if (!context.mounted) return;
    await _respond(context, ref, 'reschedule', proposedTime: time);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: c.bg1,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text('${req.studentName} · ${req.date}',
                    style: AppText.body14.copyWith(color: c.ink)),
              ),
            ],
          ),
          if (req.reason != null && req.reason!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Text(s.srReason(req.reason!),
                style: AppText.body13.copyWith(color: c.soft)),
          ],
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              _Action(
                label: s.srApprove,
                color: c.ok,
                onTap: () => _respond(context, ref, 'approve'),
              ),
              const SizedBox(width: 8),
              _Action(
                label: s.srReject,
                color: c.debt,
                onTap: () => _respond(context, ref, 'reject'),
              ),
              const SizedBox(width: 8),
              _Action(
                label: s.srReschedule,
                color: c.anor2,
                onTap: () => _reschedule(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            label,
            style: AppText.body13Bold.copyWith(color: color),
          ),
        ),
      ),
    );
  }
}
