import 'package:flutter/material.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_motion.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/widgets/app_button.dart';

/// Bottom sheet — dizayndagi `#sheet`.
///
/// ```css
/// background:#17191E; border-radius:32px 32px 0 0;
/// border-top:1px solid rgba(255,255,255,.08);
/// padding:10px 22px 34px;
/// transform: translateY(105%) → none;
/// transition: transform .38s cubic-bezier(.2,.9,.25,1);
/// scrim: rgba(0,0,0,.55) + blur(3px)
/// ```
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required String title,
  required Widget child,
  bool dismissible = true,
}) {
  final AppColors c = context.colors;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: dismissible,
    enableDrag: dismissible,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    // Dizaynda scrim `rgba(0,0,0,.55) + backdrop-filter: blur(3px)`.
    // `barrierColor` blur bera olmaydi, blur'li scrim esa o'z modal
    // route'ini yozishni talab qiladi. 55% qora qatlam ostida 3px blur
    // amalda ko'rinmaydi — rang olinadi, blur olinmaydi (D106).
    barrierColor: c.scrim,
    sheetAnimationStyle: const AnimationStyle(
      duration: AppDuration.sheet,
      curve: AppMotion.sheet,
      reverseDuration: AppDuration.sheet,
      reverseCurve: AppMotion.sheet,
    ),
    builder: (BuildContext ctx) => AppSheetShell(title: title, child: child),
  );
}

/// Sheet korpusi: handle + sarlavha qatori + kontent.
///
/// Alohida widget — `showAppSheet` dan tashqarida (masalan gallereyada)
/// ham ko'rsatish mumkin bo'lishi uchun.
class AppSheetShell extends StatelessWidget {
  const AppSheetShell({
    required this.title,
    required this.child,
    this.onClose,
    super.key,
  });

  final String title;
  final Widget child;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final MediaQueryData mq = MediaQuery.of(context);

    return Padding(
      // Klaviatura ochilganda sheet ustiga chiqadi — kiritish maydoni
      // yopilib qolmasligi uchun (T9 adaptivlik matritsasi).
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: c.sheet,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
          border: Border(top: BorderSide(color: c.line)),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x5l,
          AppSpacing.md,
          AppSpacing.x5l,
          AppSpacing.x7l,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Handle — 44×5, r3, margin 6 auto 18.
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(
                    top: AppSpacing.xs,
                    bottom: AppSpacing.x3l,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.18),
                    borderRadius: BorderRadius.circular(AppRadius.xxs),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style: AppText.h18.copyWith(color: c.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GhostIconButton(
                    size: 36,
                    radius: AppRadius.lg,
                    onPressed:
                        onClose ?? () => Navigator.of(context).maybePop(),
                    child: Icon(Icons.close_rounded, size: 18, color: c.soft),
                  ),
                ],
              ),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
