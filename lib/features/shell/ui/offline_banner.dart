import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_motion.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/features/attendance/providers/outbox.dart';

/// Tarmoq holatining oqimi.
final StreamProvider<bool> connectivityProvider = StreamProvider<bool>((
  Ref ref,
) async* {
  bool online(List<ConnectivityResult> r) =>
      r.any((ConnectivityResult e) => e != ConnectivityResult.none);

  // Boshlang'ich holat.
  yield online(await Connectivity().checkConnectivity());
  // O'zgarishlar.
  yield* Connectivity().onConnectivityChanged.map(online);
});

/// Ekran tepasidagi offline chizig'i (T8).
///
/// Tarmoq yo'q bo'lsa yoki outbox'da yuborilmagan belgi bo'lsa ko'rinadi.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    final bool online = ref.watch(connectivityProvider).value ?? true;
    final int pending = ref.watch(outboxProvider).length;

    final bool show = !online || pending > 0;
    final String message = !online ? s.offlineCached : s.pendingSync(pending);

    return AnimatedSize(
      duration: AppDuration.fast,
      curve: AppMotion.short,
      child: show
          ? Container(
              width: double.infinity,
              color: (online ? c.warn : c.dim).withValues(alpha: 0.16),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenH,
                vertical: AppSpacing.sm,
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      online ? Icons.sync : Icons.cloud_off,
                      size: 14,
                      color: c.soft,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: AppText.caption12.copyWith(color: c.soft),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
