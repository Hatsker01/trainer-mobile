import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/router/app_router.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/utils/money.dart';
import 'package:ustoz_trainer/core/widgets/app_button.dart';
import 'package:ustoz_trainer/core/widgets/avatar.dart';
import 'package:ustoz_trainer/core/widgets/empty_state.dart';
import 'package:ustoz_trainer/core/widgets/skeleton.dart';
import 'package:ustoz_trainer/features/notifications/providers/notifications_provider.dart';
import 'package:ustoz_trainer/features/payments/ui/payment_sheet.dart';

/// Bildirishnomalar (REDESIGN, root-1-7): to'lov muddati ogohlantirishlari.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final AsyncValue<List<NotifItem>> async = ref.watch(notificationsProvider);
    final List<NotifItem> items = async.value ?? const <NotifItem>[];
    final int unread = items.where((NotifItem n) => n.unread).length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Header.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                AppSpacing.lg,
                AppSpacing.screenH,
                AppSpacing.lg,
              ),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: context.pop,
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: c.glassHi,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: c.anor2,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          s.notificationsTitle,
                          style: AppText.h20.copyWith(color: c.anor2),
                        ),
                        Text(
                          s.newCount(unread),
                          style: AppText.body13.copyWith(color: c.soft),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.done_all, size: 22, color: c.anor2),
                ],
              ),
            ),
            Expanded(
              child: async.when(
                skipLoadingOnRefresh: true,
                loading: () => ListView(
                  padding: const EdgeInsets.all(AppSpacing.screenH),
                  children: const <Widget>[
                    Skeleton(height: 96, radius: 18),
                    SizedBox(height: AppSpacing.xl),
                    Skeleton(height: 96, radius: 18),
                    SizedBox(height: AppSpacing.xl),
                    Skeleton(height: 96, radius: 18),
                  ],
                ),
                error: (Object _, StackTrace _) =>
                    EmptyState(emoji: '🔔', title: s.noNotifications),
                data: (List<NotifItem> data) {
                  if (data.isEmpty) {
                    return EmptyState(emoji: '🔔', title: s.noNotifications);
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH,
                      AppSpacing.sm,
                      AppSpacing.screenH,
                      AppSpacing.screenBottom,
                    ),
                    itemCount: data.length,
                    separatorBuilder: (BuildContext _, int _) =>
                        const SizedBox(height: AppSpacing.xl),
                    itemBuilder: (BuildContext context, int i) =>
                        _NotifCard(item: data[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifCard extends ConsumerWidget {
  const _NotifCard({required this.item});

  final NotifItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    final bool overdue = item.daysOverdue > 0;
    final String message = overdue
        ? s.dueOverdueDays(item.daysOverdue)
        : s.dueTodayMsg;
    final String? ago = item.createdAt == null
        ? null
        : s.weeksAgo(DateTime.now().difference(item.createdAt!).inDays ~/ 7);

    return GestureDetector(
      onTap: () => _showDetail(context, ref),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: c.glass,
            border: Border.all(color: c.line),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color.fromRGBO(17, 24, 39, 0.05),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(width: 4, color: c.anor2),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _AvatarBadge(
                          name: item.studentName,
                          url: item.avatarUrl,
                          overdue: overdue,
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                item.studentName,
                                style: AppText.body15Bold.copyWith(
                                  color: c.ink,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                message,
                                style: AppText.body13.copyWith(color: c.soft),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                Money.withUnit(item.amount),
                                style: AppText.body15Bold.copyWith(
                                  color: c.debt,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            if (item.unread)
                              Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: c.anor2,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            const SizedBox(height: AppSpacing.x4l),
                            if (ago != null)
                              Text(
                                ago,
                                style: AppText.caption12.copyWith(color: c.dim),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDetail(BuildContext context, WidgetRef ref) async {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.sheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) => Padding(
        padding: const EdgeInsets.all(AppSpacing.x4l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              s.notifDetailTitle,
              style: AppText.h18.copyWith(color: c.anor2),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: <Widget>[
                Avatar(item.studentName, size: 52, url: item.avatarUrl),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        item.studentName,
                        style: AppText.body15Bold.copyWith(color: c.ink),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        Money.withUnit(item.amount),
                        style: AppText.money17.copyWith(color: c.debt),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x4l),
            GradientButton(
              label: s.addPayment,
              onPressed: () async {
                Navigator.of(sheetContext).pop();
                await showPaymentSheet(
                  context,
                  studentId: item.studentId,
                  studentName: item.studentName,
                  amount: item.amount,
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            GhostButton(
              label: s.viewProfile,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                context.push(Routes.student(item.studentId));
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

/// Avatar + kichik holat belgisi (qizil=o'tgan, amber=bugun).
class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.name, required this.overdue, this.url});

  final String name;
  final bool overdue;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Avatar(name, size: 52, url: url),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: overdue ? c.debt : c.warn,
                shape: BoxShape.circle,
                border: Border.all(color: c.bg0, width: 2),
              ),
              child: const Icon(
                Icons.event_busy,
                size: 11,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
