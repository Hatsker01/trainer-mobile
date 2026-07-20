import 'package:flutter/material.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';

/// Bosilganda `scale(.97)` — dizayndagi YAGONA bosilish reaksiyasi
/// (`.btn:active { transform: scale(.97) }`, `transition: transform .15s`).
///
/// Material "ripple" dizaynda yo'q — `AppTheme` da o'chirilgan.
///
/// `onTap` `null` bo'lsa widget passiv bo'ladi (bosilmaydi, scale qilmaydi) —
/// tugmaning `disabled` holati shu orqali beriladi.
class PressScale extends StatefulWidget {
  const PressScale({
    required this.child,
    this.onTap,
    this.scale = 0.97,
    this.behavior = HitTestBehavior.opaque,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final HitTestBehavior behavior;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  void _set(bool value) {
    if (_down != value && mounted) {
      setState(() => _down = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onTap != null;

    return GestureDetector(
      behavior: widget.behavior,
      onTap: widget.onTap,
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled ? (_) => _set(false) : null,
      onTapCancel: enabled ? () => _set(false) : null,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: AppDuration.fast,
        curve: Curves.ease,
        child: widget.child,
      ),
    );
  }
}
