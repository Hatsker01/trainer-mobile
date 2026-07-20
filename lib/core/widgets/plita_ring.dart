import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_motion.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';

/// Ring ohangi — yoy rangi qaysi holatni bildiradi.
///
/// Dizaynda: hero daromad va kechikkan profil — gradient (`#FF6A3D→#E2264B`);
/// qarzdor — `#FF5340`; bugun to'lov — `#FFC24D`; aktiv — `#3DD68C`.
enum RingTone { gradient, ok, warn, debt }

/// Ring o'lchamlari — dizayndagi uchta aniq variant.
enum RingSize {
  /// Hero (oylik daromad): viewBox 118, r50, stroke 11, teshik r14 + hoshiya.
  hero(box: 118, radius: 50, stroke: 11, hole: 14, holeRim: true),

  /// Shogird profili hero: viewBox 96, r40, stroke 9, teshik r11.
  profile(box: 96, radius: 40, stroke: 9, hole: 11, holeRim: false),

  /// StudentCard: viewBox 50, r20, stroke 5, teshik r6.
  card(box: 50, radius: 20, stroke: 5, hole: 6, holeRim: false);

  const RingSize({
    required this.box,
    required this.radius,
    required this.stroke,
    required this.hole,
    required this.holeRim,
  });

  final double box;
  final double radius;
  final double stroke;
  final double hole;

  /// Hero ringda teshik atrofida `rgba(255,255,255,.1)` 1.5px hoshiya bor.
  final bool holeRim;
}

/// "Plita" ring — gym plitasi metaforasi (markazda teshik).
///
/// Dizayn: `<svg>` `rotate(-90deg)` (0% soat 12 dan boshlanadi, soat yo'nalishi),
/// `stroke-linecap: round`, `transition: stroke-dashoffset 1s cubic-bezier(.2,.8,.2,1)`.
///
/// Progress har safar ekran ko'ringanda 0 dan qayta animatsiya qilinadi
/// (HTML'dagi `animRings()` xatti-harakati) — buning uchun
/// `TweenAnimationBuilder` ishlatiladi.
class PlitaRing extends StatelessWidget {
  const PlitaRing({
    required this.value,
    this.size = RingSize.card,
    this.tone = RingTone.gradient,
    this.label,
    this.sublabel,
    this.labelStyle,
    this.sublabelStyle,
    this.animate = true,
    super.key,
  });

  /// 0..1 oralig'ida. Chegaradan chiqsa qisiladi.
  final double value;
  final RingSize size;
  final RingTone tone;

  /// Markazdagi asosiy yorliq ("68%", "3 kun", "!").
  final String? label;

  /// Yorliq ostidagi kichik matn ("KECHIKDI").
  final String? sublabel;
  final TextStyle? labelStyle;
  final TextStyle? sublabelStyle;

  /// Testlarda/gallereyada animatsiyani o'chirish uchun.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final double target = value.clamp(0.0, 1.0);

    final Color? solid = switch (tone) {
      RingTone.gradient => null,
      RingTone.ok => c.ok,
      RingTone.warn => c.warn,
      RingTone.debt => c.anor,
    };

    Widget painter(double v) => CustomPaint(
      size: Size.square(size.box),
      painter: _PlitaRingPainter(
        value: v,
        size: size,
        solid: solid,
        gradient: solid == null ? c.ringGradient : null,
        track: const Color.fromRGBO(255, 255, 255, 0.09),
        holeColor: c.bg0,
      ),
    );

    final Widget ring = animate
        ? TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: target),
            duration: AppDuration.chart,
            curve: AppMotion.house,
            builder: (BuildContext _, double v, Widget? _) => painter(v),
          )
        : painter(target);

    if (label == null) {
      return SizedBox.square(dimension: size.box, child: ring);
    }

    return SizedBox.square(
      dimension: size.box,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          ring,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(label!, style: labelStyle ?? _defaultLabelStyle(c)),
              if (sublabel != null)
                Text(
                  sublabel!,
                  style: sublabelStyle ?? _defaultSublabelStyle(c),
                ),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle _defaultLabelStyle(AppColors c) => switch (size) {
    RingSize.hero => AppText.ringValue17.copyWith(color: c.ink),
    RingSize.profile ||
    RingSize.card => AppText.ringValue13.copyWith(color: c.debt),
  };

  TextStyle _defaultSublabelStyle(AppColors c) =>
      AppText.ringSub9.copyWith(color: c.dim);
}

class _PlitaRingPainter extends CustomPainter {
  const _PlitaRingPainter({
    required this.value,
    required this.size,
    required this.solid,
    required this.gradient,
    required this.track,
    required this.holeColor,
  });

  final double value;
  final RingSize size;
  final Color? solid;
  final Gradient? gradient;
  final Color track;
  final Color holeColor;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    // viewBox 118 uchun mo'ljallangan o'lchamlar — boshqa o'lchamda chizilsa
    // proporsional masshtablanadi (textScale / kichik ekran holatlari).
    final double k = canvasSize.shortestSide / size.box;
    final Offset center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final double r = size.radius * k;
    final double stroke = size.stroke * k;
    final Rect rect = Rect.fromCircle(center: center, radius: r);

    // 1. Track — to'liq aylana.
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );

    // 2. Qiymat yoyi — soat 12 dan (-90°) soat yo'nalishi bo'yicha.
    if (value > 0) {
      final Paint valuePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;

      if (gradient != null) {
        valuePaint.shader = gradient!.createShader(rect);
      } else {
        valuePaint.color = solid!;
      }

      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * value,
        false,
        valuePaint,
      );
    }

    // 3. "Plita teshigi" — markazdagi fon rangli to'ldirilgan doira.
    final double hole = size.hole * k;
    canvas.drawCircle(center, hole, Paint()..color = holeColor);

    // 4. Teshik hoshiyasi (faqat hero ringda).
    if (size.holeRim) {
      canvas.drawCircle(
        center,
        hole,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * k
          ..color = const Color.fromRGBO(255, 255, 255, 0.1),
      );
    }
  }

  /// T9 performance: FAQAT qiymat yoki ohang o'zgarganda qayta chizish.
  @override
  bool shouldRepaint(_PlitaRingPainter old) =>
      old.value != value ||
      old.solid != solid ||
      old.size != size ||
      old.holeColor != holeColor;
}
