import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
import 'package:ustoz_trainer/core/api/dto/student_dto.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/router/app_router.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/utils/money.dart';
import 'package:ustoz_trainer/core/widgets/avatar.dart';
import 'package:ustoz_trainer/core/widgets/empty_state.dart';
import 'package:ustoz_trainer/core/widgets/press_scale.dart';
import 'package:ustoz_trainer/core/widgets/skeleton.dart';
import 'package:ustoz_trainer/features/students/providers/students_provider.dart';

/// S5 — Shogirdlar ro'yxati (prototip v3 kompozitsiyasi): sarlavha + son pilli ·
/// pill-shaklidagi qidiruv · gorizontal filtr chiplari · status-ring avatarli
/// qatorlar (ism + status qatori + tarif·narx meta + status nuqta).
///
/// Prototip qatoridagi avatar-ring PROGRESSI (davomat foizi) backendda hali
/// yo'q — shuning uchun ring FAQAT status rangini ko'rsatadi, foiz emas
/// (ma'lumot-gap, PROTO-V3-MAP.md). Soxta ma'lumot ishlatilmaydi.
class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  final TextEditingController _search = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
      unawaited(ref.read(studentsProvider.notifier).loadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final AsyncValue<StudentsState> async = ref.watch(studentsProvider);
    final int count = async.value?.total ?? async.value?.items.length ?? 0;

    return RefreshIndicator(
      onRefresh: () => ref.read(studentsProvider.notifier).refresh(),
      backgroundColor: c.sheet,
      color: c.anor2,
      child: CustomScrollView(
        controller: _scroll,
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenEdge,
              AppSpacing.sm,
              AppSpacing.screenEdge,
              0,
            ),
            sliver: SliverList.list(
              children: <Widget>[
                _Header(count: count),
                const SizedBox(height: AppSpacing.xl),
                _SearchBar(
                  controller: _search,
                  onChanged: ref.read(studentsProvider.notifier).search,
                ),
                const SizedBox(height: AppSpacing.lg),
                _Filters(
                  current: async.value?.filter ?? StudentFilter.all,
                  onSelect: ref.read(studentsProvider.notifier).setFilter,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
          ...async.when(
            skipLoadingOnRefresh: true,
            loading: () => <Widget>[const _ListSkeleton()],
            error: (Object e, StackTrace _) => <Widget>[
              SliverToBoxAdapter(
                child: EmptyState(
                  emoji: '😕',
                  title: e is AppException ? e.message : s.errGeneric,
                  actionLabel: s.retry,
                  onAction: ref.read(studentsProvider.notifier).refresh,
                ),
              ),
            ],
            data: (StudentsState data) => _list(context, data),
          ),
        ],
      ),
    );
  }

  List<Widget> _list(BuildContext context, StudentsState data) {
    final AppStrings s = context.s;

    if (data.items.isEmpty) {
      return <Widget>[
        SliverToBoxAdapter(
          child: EmptyState(
            emoji: data.query.isEmpty ? '🤷' : '🔍',
            title: data.query.isEmpty ? s.noStudents : s.noStudentsFound,
            actionLabel: data.query.isEmpty ? s.addStudent : null,
            onAction: data.query.isEmpty
                ? () => context.push(Routes.studentNew)
                : null,
          ),
        ),
      ];
    }

    return <Widget>[
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenEdge,
          0,
          AppSpacing.screenEdge,
          AppSpacing.screenBottom,
        ),
        sliver: SliverList.separated(
          itemCount: data.items.length + 1 + (data.loadingMore ? 1 : 0),
          separatorBuilder: (BuildContext _, int _) =>
              const SizedBox(height: AppSpacing.md),
          itemBuilder: (BuildContext context, int i) {
            if (i < data.items.length) {
              return _StudentCard(student: data.items[i]);
            }
            if (data.loadingMore && i == data.items.length) {
              return const Skeleton(height: 76, radius: AppRadius.card);
            }
            // Oxirgi element — arxiv izohi.
            return Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                context.s.archivedHint,
                textAlign: TextAlign.center,
                style: AppText.caption12.copyWith(
                  color: context.colors.dim,
                  height: 1.5,
                ),
              ),
            );
          },
        ),
      ),
    ];
  }
}

/// Prototip karta: `--s1` sirt, `--bd` chegara, radius 20 (AppRadius.card).
BoxDecoration _cardDecoration(AppColors c) {
  return BoxDecoration(
    color: c.glass,
    borderRadius: BorderRadius.circular(AppRadius.card),
    border: Border.all(color: c.line),
    boxShadow: const <BoxShadow>[
      BoxShadow(
        color: Color.fromRGBO(17, 24, 39, 0.05),
        blurRadius: 14,
        offset: Offset(0, 5),
      ),
    ],
  );
}

// -------------------------------------------------------------------- sarlavha

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(s.students, style: AppText.display24.copyWith(color: c.ink)),
        ),
        // Son pilli (prototip: "N / 5 bepul"). Bepul-limit backendda yo'q —
        // shuning uchun faqat jami son ko'rsatiladi (ma'lumot-gap).
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.glassHi,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            s.studentsCount(count),
            style: AppText.body13Bold.copyWith(
              color: c.soft,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        PressScale(
          onTap: () => context.push(Routes.studentNew),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: c.anorGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_rounded, size: 24, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------------- qidiruv

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: c.glass,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: c.line),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Row(
        children: <Widget>[
          Icon(Icons.search_rounded, size: 19, color: c.dim),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppText.body145.copyWith(color: c.ink),
              cursorColor: c.anor2,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: context.s.searchHint,
                hintStyle: AppText.body145.copyWith(color: c.dim),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------- filtrlar

class _Filters extends StatelessWidget {
  const _Filters({required this.current, required this.onSelect});

  final StudentFilter current;
  final ValueChanged<StudentFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;

    final List<(StudentFilter, String)> filters = <(StudentFilter, String)>[
      (StudentFilter.all, s.all),
      (StudentFilter.debtors, s.filterDebtors),
      (StudentFilter.upcoming, s.filterUpcoming),
      (StudentFilter.active, s.filterActive),
      (StudentFilter.archived, s.filterArchived),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: <Widget>[
          for (final (StudentFilter f, String label) in filters)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _FilterChip(
                label: label,
                selected: current == f,
                onTap: () => onSelect(f),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDuration.fast,
        height: 36,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        decoration: BoxDecoration(
          color: selected ? c.anor2 : c.glass,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: selected ? c.anor2 : c.line),
        ),
        child: Text(
          label,
          style: AppText.body13Bold.copyWith(
            color: selected ? Colors.white : c.soft,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- shogird qatori

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final bool archived = student.isArchived;

    // Bitta semantik signal: status rangi (ring + nuqta) + status qatori.
    final (Color statusColor, String? statusLine) = archived
        ? (c.dim, s.archived)
        : switch (student.paymentState) {
            PaymentState.overdue => (
              c.debt,
              '${s.daysLate(student.daysOverdue ?? 0)} · '
                  '${Money.compact((student.balance ?? student.tariffPrice).abs())}',
            ),
            PaymentState.dueToday => (c.warn, s.today),
            PaymentState.dueSoon => (
              c.warn,
              student.nextDueDate == null
                  ? null
                  : s.dayMonth(student.nextDueDate!),
            ),
            PaymentState.paid || PaymentState.none => (c.ok, null),
          };

    final String meta =
        '${s.tariffName(student.tariffType)} · ${Money.compact(student.tariffPrice)}';

    return PressScale(
      onTap: () => context.push(Routes.student(student.id)),
      child: Opacity(
        opacity: archived ? 0.6 : 1,
        child: Container(
          decoration: _cardDecoration(c),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: <Widget>[
              _StatusRingAvatar(
                name: student.name,
                url: student.avatarUrl,
                ringColor: statusColor,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      student.name,
                      style: AppText.body15Bold.copyWith(color: c.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (statusLine != null) ...<Widget>[
                      const SizedBox(height: 3),
                      Text(
                        statusLine,
                        style: AppText.caption125.copyWith(color: statusColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      meta,
                      style: AppText.caption12.copyWith(color: c.dim),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Icon(Icons.chevron_right_rounded, size: 18, color: c.dim),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Prototip 54px "plita" avatari — status rangidagi halqa + ichida initsiallar.
/// Progress (davomat foizi) backendda yo'q, shuning uchun halqa to'liq va
/// FAQAT status rangini bildiradi (ma'lumot-gap).
class _StatusRingAvatar extends StatelessWidget {
  const _StatusRingAvatar({
    required this.name,
    required this.ringColor,
    this.url,
  });

  final String name;
  final Color ringColor;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor.withValues(alpha: 0.9), width: 2.5),
        color: c.glass,
      ),
      child: Avatar(name, size: 42, url: url),
    );
  }
}

// -------------------------------------------------------------------- skeleton

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
      sliver: SliverList.separated(
        itemCount: 5,
        separatorBuilder: (BuildContext _, int _) =>
            const SizedBox(height: AppSpacing.md),
        itemBuilder: (BuildContext _, int _) =>
            const Skeleton(height: 76, radius: AppRadius.card),
      ),
    );
  }
}
