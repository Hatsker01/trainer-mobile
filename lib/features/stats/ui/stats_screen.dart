import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/dto/dashboard_dto.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/providers.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/utils/money.dart';
import 'package:ustoz_trainer/core/widgets/empty_state.dart';
import 'package:ustoz_trainer/core/widgets/glass_card.dart';
import 'package:ustoz_trainer/core/widgets/list_row.dart';
import 'package:ustoz_trainer/core/widgets/mini_bar_chart.dart';
import 'package:ustoz_trainer/core/widgets/section_header.dart';
import 'package:ustoz_trainer/core/widgets/skeleton.dart';

final AsyncNotifierProvider<StatsNotifier, StatsResponse> statsProvider =
    AsyncNotifierProvider<StatsNotifier, StatsResponse>(StatsNotifier.new);

class StatsNotifier extends AsyncNotifier<StatsResponse> {
  @override
  Future<StatsResponse> build() => ref.read(statsRepositoryProvider).get();

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(statsRepositoryProvider).get(),
    );
  }
}

/// Katta Unbounded raqam (KPI kartalar) — prototip 30px, tabular-nums.
TextStyle _numStyle(double size) => TextStyle(
  fontFamily: AppText.displayFamily,
  fontWeight: FontWeight.w600,
  fontSize: size,
  height: 1,
  letterSpacing: -0.02 * size / 32,
  fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
);

/// S10 — statistika (prototip v3): 2×2 KPI grid · daromad dinamikasi grafigi ·
/// tariflar kesimi.
///
/// Prototipdagi "O'rtacha davomat %", "Davomat dinamikasi (hafta)", top
/// shogirdlar ro'yxati va "Churn radar" bo'limlari backendda hali yo'q
/// (PROTO-V3-MAP.md — ma'lumot-gap). Soxta ma'lumot ishlatilmaydi, shu
/// bo'laklar qo'shilmadi.
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  /// Grafik ustuniga bosilganda — o'sha oy summasi.
  int? _selectedMonth;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final AsyncValue<StatsResponse> async = ref.watch(statsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(statsProvider.notifier).refresh(),
      backgroundColor: c.sheet,
      color: c.anor2,
      child: async.when(
        skipLoadingOnRefresh: true,
        loading: () => const _StatsSkeleton(),
        error: (Object e, StackTrace _) => ListView(
          padding: const EdgeInsets.only(top: 120),
          children: <Widget>[
            EmptyState(
              emoji: '😕',
              title: e is AppException ? e.message : s.errGeneric,
              actionLabel: s.retry,
              onAction: ref.read(statsProvider.notifier).refresh,
            ),
          ],
        ),
        data: (StatsResponse stats) => _Body(
          stats: stats,
          selectedMonth: _selectedMonth,
          onSelectMonth: (int? i) => setState(() => _selectedMonth = i),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.stats,
    required this.selectedMonth,
    required this.onSelectMonth,
  });

  final StatsResponse stats;
  final int? selectedMonth;
  final ValueChanged<int?> onSelectMonth;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    final double? change = stats.changePercent;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.x4l,
        AppSpacing.screenEdge,
        AppSpacing.screenBottom,
      ),
      children: <Widget>[
        Text(s.stats, style: AppText.display24.copyWith(color: c.ink)),

        // 2×2 KPI grid (prototip: 1fr 1fr, gap 12).
        const SizedBox(height: AppSpacing.x3l),
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.lg,
          children: <Widget>[
            _Kpi(
              label: s.statActive,
              value: '${stats.activeStudents}',
              displayFont: true,
            ),
            _Kpi(
              label: s.statRevenue,
              value: Money.compact(stats.monthRevenue),
              delta: change == null
                  ? null
                  : '${change >= 0 ? '▲' : '▼'} '
                        '${change.abs().toStringAsFixed(0)}%',
              deltaColor: change == null
                  ? null
                  : (change >= 0 ? c.ok : c.debt),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.lg,
          children: <Widget>[
            _Kpi(
              label: s.statDebt,
              value: Money.compact(stats.debtTotal),
              valueColor: stats.debtTotal > 0 ? c.debt : null,
              delta: stats.debtorsCount == null || stats.debtorsCount == 0
                  ? null
                  : s.debtorsCount(stats.debtorsCount!),
              deltaColor: c.debt,
            ),
            _Kpi(
              label: s.statPrevMonth,
              value: Money.compact(stats.prevMonthRevenue),
            ),
          ],
        ),

        // Daromad dinamikasi grafigi (real: series, oxirgi 6 oy).
        const SizedBox(height: AppSpacing.sectionGap),
        SectionHeader(
          s.revenueDynamics,
          trailing: selectedMonth == null
              ? s.sixMonths
              : Money.withUnit(stats.series[selectedMonth!].revenue),
        ),
        GlassCard.hero(
          child: stats.series.isEmpty
              ? EmptyState(emoji: '📊', title: s.noStats, compact: true)
              : MiniBarChart(
                  data: <BarDatum>[
                    for (final (int i, StatsSeriesPoint p)
                        in stats.series.indexed)
                      BarDatum(
                        label: _monthLabel(context, p.month),
                        value: p.revenue,
                        hot: i == stats.series.length - 1,
                      ),
                  ],
                  selectedIndex: selectedMonth,
                  onTap: (int i) =>
                      onSelectMonth(selectedMonth == i ? null : i),
                ),
        ),

        // Tariflar kesimi (real: by_tariff).
        if (stats.byTariff != null && stats.byTariff!.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.sectionGap),
          SectionHeader(s.byTariff),
          GlassCard(
            child: ListRowGroup(
              rows: <ListRow>[
                for (final StatsByTariff t in stats.byTariff!)
                  ListRow(
                    title: s.tariffName(t.tariffType),
                    subtitle: s.activeCount(t.students),
                    trailing: Text(
                      Money.compact(t.revenue),
                      style: AppText.money14.copyWith(color: c.ink),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// `"2026-07"` → `Iyl`.
  static String _monthLabel(BuildContext context, String yyyyMm) {
    final List<String> parts = yyyyMm.split('-');
    final int? month = parts.length == 2 ? int.tryParse(parts[1]) : null;
    return month == null ? yyyyMm : context.s.monthShort(month);
  }
}

/// Prototip KPI karta: radius 20, glass sirt, `label · katta raqam · delta`.
class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.label,
    required this.value,
    this.delta,
    this.deltaColor,
    this.valueColor,
    this.displayFont = false,
  });

  final String label;
  final String value;

  /// Kichik rangli delta qatori ("▲ 12%", "3 shogird") — bor bo'lsa.
  final String? delta;
  final Color? deltaColor;
  final Color? valueColor;

  /// Sanoq qiymatlari uchun Unbounded (raqamli) shrift; pul uchun mono.
  final bool displayFont;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Expanded(
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption125.copyWith(color: c.soft),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              maxLines: 1,
              style: displayFont
                  ? _numStyle(28).copyWith(color: valueColor ?? c.ink)
                  : AppText.money21.copyWith(color: valueColor ?? c.ink),
            ),
            SizedBox(height: delta == null ? 3 : AppSpacing.xs),
            Text(
              delta ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption12.copyWith(
                color: deltaColor ?? c.soft,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.x4l,
        AppSpacing.screenEdge,
        AppSpacing.screenBottom,
      ),
      children: const <Widget>[
        Skeleton(height: 28, width: 160),
        SizedBox(height: AppSpacing.x3l),
        Row(
          children: <Widget>[
            Expanded(child: Skeleton(height: 92, radius: AppRadius.card)),
            SizedBox(width: AppSpacing.lg),
            Expanded(child: Skeleton(height: 92, radius: AppRadius.card)),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: <Widget>[
            Expanded(child: Skeleton(height: 92, radius: AppRadius.card)),
            SizedBox(width: AppSpacing.lg),
            Expanded(child: Skeleton(height: 92, radius: AppRadius.card)),
          ],
        ),
        SizedBox(height: AppSpacing.sectionGap),
        Skeleton(height: 20, width: 140),
        SizedBox(height: AppSpacing.sectionHeaderGap),
        Skeleton(height: 190, radius: AppRadius.card),
      ],
    );
  }
}
