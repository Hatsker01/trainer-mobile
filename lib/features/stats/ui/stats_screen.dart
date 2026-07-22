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
import 'package:ustoz_trainer/core/widgets/status_badge.dart';

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

/// S10 — statistika.
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
      color: c.anor,
      child: async.when(
        skipLoadingOnRefresh: true,
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.screenEdge),
          children: const <Widget>[
            SizedBox(height: AppSpacing.x4l),
            Skeleton(height: 28, width: 160),
            SizedBox(height: AppSpacing.x3l),
            Skeleton(height: 96, radius: AppRadius.card),
            SizedBox(height: AppSpacing.cardGap),
            Skeleton(height: 96, radius: AppRadius.card),
            SizedBox(height: AppSpacing.sectionGap),
            Skeleton(height: 190, radius: AppRadius.card),
          ],
        ),
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

        // 2×2 KPI.
        const SizedBox(height: AppSpacing.x3l),
        Row(
          spacing: AppSpacing.md,
          children: <Widget>[
            _Kpi(
              label: s.statRevenue,
              value: Money.compact(stats.monthRevenue),
              badge: change == null
                  ? null
                  : StatusBadge(
                      '${change >= 0 ? '▲' : '▼'} '
                      '${change.abs().toStringAsFixed(0)}%',
                      tone: change >= 0 ? BadgeTone.ok : BadgeTone.debt,
                    ),
            ),
            _Kpi(
              label: s.statDebt,
              value: Money.compact(stats.debtTotal),
              valueColor: stats.debtTotal > 0 ? c.debt : null,
              badge: stats.debtorsCount == null
                  ? null
                  : StatusBadge(
                      s.debtorsCount(stats.debtorsCount!),
                      tone: BadgeTone.debt,
                    ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.cardGap),
        Row(
          spacing: AppSpacing.md,
          children: <Widget>[
            _Kpi(label: s.statActive, value: '${stats.activeStudents}'),
            _Kpi(
              label: s.monthIncome(''),
              value: Money.compact(stats.prevMonthRevenue),
            ),
          ],
        ),

        // Grafik.
        const SizedBox(height: AppSpacing.sectionGap),
        SectionHeader(
          s.revenueDynamics,
          trailing: selectedMonth == null
              ? s.sixMonths
              : Money.withUnit(stats.series[selectedMonth!].revenue),
        ),
        GlassCard(
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

        // Tariflar kesimi.
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

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.label,
    required this.value,
    this.badge,
    this.valueColor,
  });

  final String label;
  final String value;
  final Widget? badge;
  final Color? valueColor;

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
              style: AppText.label115.copyWith(color: c.dim),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              maxLines: 1,
              style: AppText.money21.copyWith(color: valueColor ?? c.ink),
            ),
            if (badge != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Align(alignment: Alignment.centerLeft, child: badge!),
            ],
          ],
        ),
      ),
    );
  }
}
