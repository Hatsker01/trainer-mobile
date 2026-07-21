import 'package:flutter/material.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_motion.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';

/// Toast — dizayndagi `#toast`.
///
/// ```css
/// left:24; right:24; bottom:110;
/// background:#1E2126; border:1px solid --line; border-radius:16px;
/// padding:14px 16px; font:700 13.5px; text-align:center;
/// box-shadow:0 16px 40px rgba(0,0,0,.5);
/// transition:.32s cubic-bezier(.2,.8,.2,1);
/// hidden: opacity 0, translateY(14px)
/// ```
/// Avtomatik yopilish — 2600 ms.
///
/// Material `SnackBar` ishlatilmadi: uning geometriyasi, animatsiyasi va
/// `ScaffoldMessenger` navbat mantig'i dizayndan butunlay boshqacha.
abstract final class AppToast {
  static OverlayEntry? _current;
  static int _generation = 0;

  /// Toast ko'rsatish. Oldingisi bo'lsa darhol almashtiriladi.
  static void show(BuildContext context, String message) {
    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }

    _dismiss();
    final int generation = ++_generation;

    final OverlayEntry entry = OverlayEntry(
      builder: (BuildContext _) => _ToastView(message: message),
    );
    _current = entry;
    overlay.insert(entry);

    Future<void>.delayed(AppDuration.toast, () {
      // Oraliqda yangi toast chiqqan bo'lsa — eskisi tegmaydi.
      if (generation == _generation) {
        _dismiss();
      }
    });
  }

  static void _dismiss() {
    _current?.remove();
    _current = null;
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({required this.message});

  final String message;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    // Birinchi kadrdan keyin ko'rsatish — kirish animatsiyasi ishlashi uchun.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _shown = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Positioned(
      left: 24,
      right: 24,
      bottom: 110,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _shown ? 1 : 0,
          duration: AppDuration.screenIn,
          curve: AppMotion.house,
          child: AnimatedSlide(
            offset: _shown ? Offset.zero : const Offset(0, 0.35),
            duration: AppDuration.screenIn,
            curve: AppMotion.house,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
                vertical: AppSpacing.xl,
              ),
              decoration: BoxDecoration(
                color: c.toast,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color.fromRGBO(17, 24, 39, 0.28),
                    blurRadius: 32,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              // Toast har doim to'q "pill" — matn oq (temadan mustaqil).
              child: Text(
                widget.message,
                textAlign: TextAlign.center,
                style: AppText.body135Bold.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
