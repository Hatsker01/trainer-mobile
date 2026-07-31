import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/widgets/app_toast.dart';
import 'package:ustoz_trainer/features/schedule_requests/providers/link_requests_provider.dart';

/// Inbound bog'lanish so'rovlari kartasi — trener «Bugun»da (C5, D122 sync).
///
/// Shogird kod kiritib trenerni tanlaganда shu yerda ko'rinadi; trener
/// qabul qiladi (shogird qo'shiladi) yoki rad etadi. So'rov bo'lmasa —
/// karta ko'rinmaydi.
class LinkRequestsCard extends ConsumerWidget {
  const LinkRequestsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list =
        ref.watch(pendingLinkRequestsProvider).asData?.value ??
        const <LinkRequest>[];
    if (list.isEmpty) return const SizedBox.shrink();

    final AppColors c = context.colors;
    final AppStrings s = context.s;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.glass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.anor2.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.person_add_alt_1, size: 18, color: c.anor2),
              const SizedBox(width: 8),
              Text(s.lrTitle, style: AppText.section15.copyWith(color: c.ink)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: c.anor2.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${list.length}',
                    style: AppText.body13Bold.copyWith(color: c.anor2)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final LinkRequest r in list) _LinkRow(req: r),
        ],
      ),
    );
  }
}

class _LinkRow extends ConsumerWidget {
  const _LinkRow({required this.req});

  final LinkRequest req;

  Future<void> _decide(
    BuildContext context,
    WidgetRef ref,
    bool approve,
  ) async {
    final AppStrings s = context.s;
    try {
      final LinkRequestsRepo repo = ref.read(linkRequestsRepoProvider);
      if (approve) {
        await repo.approve(req.id);
      } else {
        await repo.reject(req.id);
      }
      ref.invalidate(pendingLinkRequestsProvider);
      if (context.mounted) {
        AppToast.show(context, approve ? s.lrApproved : s.lrRejected);
      }
    } on Exception {
      if (context.mounted) AppToast.show(context, s.retry);
    }
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
          Text(req.name, style: AppText.body14.copyWith(color: c.ink)),
          const SizedBox(height: 2),
          Text(req.phoneMasked,
              style: AppText.body13.copyWith(color: c.soft)),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              _Btn(
                label: s.lrApprove,
                color: c.ok,
                onTap: () => _decide(context, ref, true),
              ),
              const SizedBox(width: 8),
              _Btn(
                label: s.lrReject,
                color: c.debt,
                onTap: () => _decide(context, ref, false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.label, required this.color, required this.onTap});

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
          child: Text(label,
              style: AppText.body13Bold.copyWith(color: color)),
        ),
      ),
    );
  }
}
