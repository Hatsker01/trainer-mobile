import 'package:flutter/material.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/utils/money.dart';
import 'package:ustoz_trainer/core/widgets/app_bottom_sheet.dart';
import 'package:ustoz_trainer/core/widgets/app_button.dart';
import 'package:ustoz_trainer/core/widgets/app_chip.dart';
import 'package:ustoz_trainer/core/widgets/app_toast.dart';
import 'package:ustoz_trainer/core/widgets/avatar.dart';
import 'package:ustoz_trainer/core/widgets/empty_state.dart';
import 'package:ustoz_trainer/core/widgets/glass_card.dart';
import 'package:ustoz_trainer/core/widgets/heatmap.dart';
import 'package:ustoz_trainer/core/widgets/list_row.dart';
import 'package:ustoz_trainer/core/widgets/mini_bar_chart.dart';
import 'package:ustoz_trainer/core/widgets/plita_ring.dart';
import 'package:ustoz_trainer/core/widgets/section_header.dart';
import 'package:ustoz_trainer/core/widgets/status_badge.dart';
import 'package:ustoz_trainer/core/widgets/student_card.dart';
import 'package:ustoz_trainer/core/widgets/timeline_tile.dart';

/// Komponent galereyasi — T1 ning qabul mezoni.
///
/// Hamma design-system komponenti har holatida bir sahifada. Dizayn HTML'i
/// bilan yonma-yon solishtirish uchun. **Faqat debug buildda** ochiladi
/// (`Env.devTools` + `kDebugMode` — router'da tekshiriladi).
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int _filter = 0;
  int _method = 0;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.x4l,
            AppSpacing.screenH,
            AppSpacing.screenBottom,
          ),
          children: <Widget>[
            Text('Gallery', style: AppText.display24.copyWith(color: c.ink)),
            Text(
              'design/ustoz-v2.1-tavsiyalar.html bilan solishtirish uchun',
              style: AppText.caption12.copyWith(color: c.dim),
            ),

            // ---------------------------------------------------- tipografiya
            _Group(
              'Tipografiya',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.sm,
                children: <Widget>[
                  Text(
                    'Display24 · Unbounded 700',
                    style: AppText.display24.copyWith(color: c.ink),
                  ),
                  Text(
                    'Section15 · Unbounded 600',
                    style: AppText.section15.copyWith(color: c.ink),
                  ),
                  Text(
                    'Body15Bold · Manrope 700',
                    style: AppText.body15Bold.copyWith(color: c.ink),
                  ),
                  Text(
                    'Body14 · Manrope 400',
                    style: AppText.body14.copyWith(color: c.soft),
                  ),
                  Text(
                    'Caption12 · Manrope 400',
                    style: AppText.caption12.copyWith(color: c.dim),
                  ),
                  Text(
                    Money.format(6800000),
                    style: AppText.money24.copyWith(color: c.ink),
                  ),
                  Text(
                    '${Money.compact(6800000)} · ${Money.compact(800000)} · '
                    '${Money.withUnit(400000)}',
                    style: AppText.money14.copyWith(color: c.soft),
                  ),
                ],
              ),
            ),

            // --------------------------------------------------------- ranglar
            _Group(
              'Ranglar',
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  _Swatch('bg0', c.bg0),
                  _Swatch('glass', c.glass),
                  _Swatch('ink', c.ink),
                  _Swatch('soft', c.soft),
                  _Swatch('dim', c.dim),
                  _Swatch('anor', c.anor),
                  _Swatch('anor2', c.anor2),
                  _Swatch('ok', c.ok),
                  _Swatch('warn', c.warn),
                  _Swatch('debt', c.debt),
                ],
              ),
            ),

            // --------------------------------------------------------- tugmalar
            _Group(
              'Tugmalar',
              child: Column(
                spacing: AppSpacing.md,
                children: <Widget>[
                  GradientButton(label: "To'lovni saqlash", onPressed: () {}),
                  GradientButton(
                    label: 'Yuklanmoqda',
                    onPressed: () {},
                    loading: _loading,
                  ),
                  const GradientButton(label: 'Disabled', onPressed: null),
                  GhostButton(label: 'Eslatish', onPressed: () {}),
                  Row(
                    spacing: AppSpacing.sm,
                    children: <Widget>[
                      Expanded(
                        child: GradientButton(
                          label: "✓ To'landi",
                          onPressed: () => setState(() => _loading = !_loading),
                          size: AppButtonSize.small,
                        ),
                      ),
                      Expanded(
                        child: GhostButton(
                          label: 'Eslatish',
                          onPressed: () =>
                              AppToast.show(context, '✓ Eslatma yuborildi'),
                          size: AppButtonSize.small,
                        ),
                      ),
                      GhostIconButton(
                        onPressed: () {},
                        child: Icon(
                          Icons.call_outlined,
                          size: 18,
                          color: c.ink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --------------------------------------------------- badge va chip
            _Group(
              'Badge · Chip · Avatar',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.lg,
                children: <Widget>[
                  const Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: <Widget>[
                      StatusBadge('AKTIV', tone: BadgeTone.ok),
                      StatusBadge('BUGUN', tone: BadgeTone.warn),
                      StatusBadge('QARZDOR', tone: BadgeTone.debt),
                      StatusBadge('TG ✓'),
                    ],
                  ),
                  AppChipRow(
                    children: <Widget>[
                      for (final (int i, (String label, int? n))
                          in <(String, int?)>[
                            ('Hammasi', 23),
                            ('Qarzdor', 2),
                            ('Yaqin', 3),
                            ('Paket', 6),
                            ('Arxiv', null),
                          ].indexed)
                        AppChip(
                          label: label,
                          count: n,
                          selected: _filter == i,
                          labelColor: i == 1 ? c.debt : null,
                          onTap: () => setState(() => _filter = i),
                        ),
                    ],
                  ),
                  const Row(
                    spacing: AppSpacing.lg,
                    children: <Widget>[
                      Avatar('Aziz Karimov'),
                      Avatar('Aziz Karimov', debt: true),
                      Avatar.small('Dilnoza Mirzayeva'),
                      Avatar('J'),
                    ],
                  ),
                ],
              ),
            ),

            // ----------------------------------------------------------- ringlar
            const _Group(
              'PlitaRing',
              child: Wrap(
                spacing: AppSpacing.x4l,
                runSpacing: AppSpacing.x4l,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  PlitaRing(value: 0.68, size: RingSize.hero, label: '68%'),
                  PlitaRing(
                    value: 1,
                    size: RingSize.profile,
                    label: '3 kun',
                    sublabel: 'KECHIKDI',
                  ),
                  PlitaRing(value: 1, tone: RingTone.debt, label: '!'),
                  PlitaRing(value: 0.12, tone: RingTone.warn),
                  PlitaRing(value: 0.83, tone: RingTone.ok),
                ],
              ),
            ),

            // ------------------------------------------------------- kartalar
            _Group(
              'GlassCard · StudentCard',
              child: Column(
                spacing: AppSpacing.cardGap,
                children: <Widget>[
                  GlassCard.hero(
                    overlay: const RadialGradient(
                      center: Alignment(-0.6, -1),
                      radius: 1.1,
                      colors: <Color>[
                        Color.fromRGBO(255, 83, 64, 0.14),
                        Colors.transparent,
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        const PlitaRing(
                          value: 0.68,
                          size: RingSize.hero,
                          label: '68%',
                        ),
                        const SizedBox(width: AppSpacing.x4l),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'Iyul daromadi',
                                style: AppText.caption125.copyWith(
                                  color: c.soft,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                Money.format(6800000),
                                style: AppText.money24.copyWith(color: c.ink),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              const StatusBadge(
                                "▲ 12% o'tgan oyga",
                                tone: BadgeTone.ok,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  StudentCard(
                    name: 'Aziz Karimov',
                    subtitle: const Text('Oylik · 400 000'),
                    ringValue: 1,
                    ringTone: RingTone.debt,
                    ringLabel: '!',
                    debt: true,
                    badge: const StatusBadge(
                      '3 KUN KECHIKDI',
                      tone: BadgeTone.debt,
                    ),
                    trailingText: Money.format(400000),
                    onTap: () {},
                  ),
                  StudentCard(
                    name: 'Sardor Bekmurodov',
                    subtitle: const Text('Paket 12 · 9 qoldi'),
                    ringValue: 0.83,
                    ringTone: RingTone.ok,
                    badge: const StatusBadge('AKTIV', tone: BadgeTone.ok),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // ------------------------------------------------- ro'yxat qatorlari
            _Group(
              'SectionHeader · ListRow',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SectionHeader(
                    "Bugun to'lov",
                    count: 2,
                    trailing: "800 000 so'm",
                  ),
                  const SectionHeader(
                    '3 kun ichida',
                    count: 3,
                    countTone: SectionCountTone.warn,
                  ),
                  SectionHeader(
                    'Tavsiyalar',
                    count: 3,
                    trailing: "+ Qo'shish",
                    onTrailingTap: () {},
                  ),
                  GlassCard(
                    child: ListRowGroup(
                      rows: <ListRow>[
                        const ListRow(
                          title: 'Dilnoza Mirzayeva',
                          subtitle: 'Oylik · 400 000',
                          leading: Avatar.small('Dilnoza Mirzayeva'),
                          trailing: StatusBadge('2 KUN', tone: BadgeTone.warn),
                        ),
                        ListRow(
                          title: 'Iyun oyi uchun',
                          subtitle: 'Naqd · 16-iyun',
                          trailing: Text(
                            Money.format(400000),
                            style: AppText.money14.copyWith(color: c.ink),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --------------------------------------------------------- timeline
            const _Group(
              'Timeline',
              child: GlassCard(
                child: Timeline(
                  events: <TimelineEvent>[
                    TimelineEvent(
                      time: '07:00',
                      name: 'Sardor B.',
                      state: TimelineState.done,
                      statusLabel: 'KELDI',
                    ),
                    TimelineEvent(
                      time: '18:00',
                      name: 'Aziz K.',
                      state: TimelineState.now,
                      statusLabel: 'HOZIR',
                    ),
                    TimelineEvent(
                      time: '19:30',
                      name: 'Malika S.',
                      state: TimelineState.upcoming,
                      statusLabel: 'KUTILMOQDA',
                    ),
                  ],
                ),
              ),
            ),

            // --------------------------------------------------------- grafiklar
            _Group(
              'Heatmap · MiniBarChart',
              child: Column(
                spacing: AppSpacing.cardGap,
                children: <Widget>[
                  GlassCard(
                    child: Heatmap(
                      levels: List<int>.generate(
                        56,
                        (int i) => <int>[0, 2, 0, 3, 0, 1, 3][i % 7],
                      ),
                    ),
                  ),
                  const GlassCard(
                    child: MiniBarChart(
                      data: <BarDatum>[
                        BarDatum(label: 'Fev', value: 4200000),
                        BarDatum(label: 'Mar', value: 5500000),
                        BarDatum(label: 'Apr', value: 4800000),
                        BarDatum(label: 'May', value: 7000000),
                        BarDatum(label: 'Iyn', value: 6100000),
                        BarDatum(label: 'Iyl', value: 8800000, hot: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ------------------------------------------------- bo'sh holat / sheet
            _Group(
              "Bo'sh holat · Sheet · Toast",
              child: Column(
                spacing: AppSpacing.cardGap,
                children: <Widget>[
                  GlassCard(
                    child: EmptyState(
                      emoji: '💪',
                      title: 'Bugun hammasi joyida',
                      message: "To'lov kutilayotgan shogird yo'q",
                      actionLabel: "Shogird qo'shish",
                      onAction: () {},
                    ),
                  ),
                  GhostButton(
                    label: 'Sheet ochish',
                    onPressed: () => showAppSheet<void>(
                      context: context,
                      title: "To'lov qo'shish",
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const SizedBox(height: AppSpacing.x6l),
                          Text(
                            Money.format(400000),
                            style: AppText.money40.copyWith(color: c.ink),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            "✓ Keyingi to'lov: 16-avgust, 2026",
                            style: AppText.caption125.copyWith(color: c.ok),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          AppChipRow(
                            children: <Widget>[
                              for (final (int i, String m) in <String>[
                                'Naqd',
                                'Karta',
                                'Payme',
                                'Click',
                              ].indexed)
                                StatefulBuilder(
                                  builder:
                                      (BuildContext _, StateSetter setSheet) =>
                                          AppChip(
                                            label: m,
                                            selected: _method == i,
                                            onTap: () =>
                                                setSheet(() => _method = i),
                                          ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.x4l),
                          GradientButton(
                            label: "To'lovni saqlash",
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GhostButton(
                    label: 'Toast ko\'rsatish',
                    onPressed: () => AppToast.show(
                      context,
                      "✓ Saqlandi. Keyingi to'lov: 16-avgust",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group(this.title, {required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[SectionHeader(title), child],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.color);

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 56,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: c.line),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(name, style: AppText.label11.copyWith(color: c.dim)),
      ],
    );
  }
}
