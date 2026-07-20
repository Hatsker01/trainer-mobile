import 'package:flutter/material.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';

/// Yuklanish skeleti — **shimmer paketisiz**, oddiy pulse opacity
/// (brief T4: "skeleton loading (shimmer paketisiz)").
///
/// Bitta `AnimationController` butun ekran uchun emas, har skelet uchun —
/// lekin ular bir xil davomiylikda, shuning uchun vizual ravishda
/// sinxron ko'rinadi. Gradient shimmer ATAYIN qilinmadi: u har kadrda
/// shader qayta hisoblaydi, pulse esa faqat opacity (arzon).
class Skeleton extends StatefulWidget {
  const Skeleton({
    this.height = 16,
    this.width,
    this.radius = AppRadius.sm,
    super.key,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.45,
        end: 1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: c.glass,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}
