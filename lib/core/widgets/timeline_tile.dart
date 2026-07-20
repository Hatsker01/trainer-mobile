import 'package:flutter/material.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';

/// Jadval qatorining holati — dizayndagi `.ev` / `.ev.done` / `.ev.now`.
enum TimelineState {
  /// Kelgan — to'ldirilgan yashil nuqta.
  done,

  /// Hozir davom etmoqda — anor chegara + halo.
  now,

  /// Kutilmoqda — bo'sh dim nuqta.
  upcoming,
}

/// Bugungi jadval — dizayndagi `.tl` (rels) + `.ev` (hodisa).
///
/// ```css
/// .tl { position:relative; padding-left:22px }
/// .tl::before { left:6; top:8; bottom:8; width:2px; background:--line }
/// .ev { padding:10px 0 }
/// .ev::before { left:-21; top:16; 12×12; border-radius:50%;
///               background:--bg0; border:2.5px solid --dim }
/// ```
class Timeline extends StatelessWidget {
  const Timeline({required this.events, super.key});

  final List<TimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Stack(
      children: <Widget>[
        // Rels — birinchi va oxirgi nuqtadan 8px ichkarida tugaydi.
        Positioned(
          left: 6,
          top: AppSpacing.sm,
          bottom: AppSpacing.sm,
          width: 2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: c.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.x5l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: events,
          ),
        ),
      ],
    );
  }
}

/// Jadvaldagi bitta hodisa: vaqt — ism — holat.
class TimelineEvent extends StatelessWidget {
  const TimelineEvent({
    required this.time,
    required this.name,
    required this.state,
    required this.statusLabel,
    super.key,
  });

  /// "07:00".
  final String time;
  final String name;
  final TimelineState state;

  /// "KELDI" · "HOZIR" · "KUTILMOQDA".
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    final Color statusColor = switch (state) {
      TimelineState.done => c.ok,
      TimelineState.now => c.anor,
      TimelineState.upcoming => c.dim,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: <Widget>[
          // Nuqta — `.ev::before` (chapga 21px chiqadi).
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: _Dot(state: state, colors: c),
          ),
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: time,
                    style: AppText.body14Bold.copyWith(color: c.ink),
                  ),
                  TextSpan(
                    text: ' — $name',
                    style: AppText.body14.copyWith(color: c.soft),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            statusLabel,
            style:
                (state == TimelineState.upcoming
                        ? AppText.caption12Heavy.copyWith(
                            fontWeight: FontWeight.w700,
                          )
                        : AppText.caption12Heavy)
                    .copyWith(color: statusColor),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.state, required this.colors});

  final TimelineState state;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final Color border = switch (state) {
      TimelineState.done => colors.ok,
      TimelineState.now => colors.anor,
      TimelineState.upcoming => colors.dim,
    };

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        // "done" to'liq to'ldirilgan, qolganlari ichi fon rangida.
        color: state == TimelineState.done ? colors.ok : colors.bg0,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 2.5),
        boxShadow: state == TimelineState.now
            ? const <BoxShadow>[
                // `0 0 0 5px rgba(255,83,64,.18)` — blur emas, halo.
                BoxShadow(
                  color: Color.fromRGBO(255, 83, 64, 0.18),
                  spreadRadius: 5,
                ),
              ]
            : null,
      ),
    );
  }
}
