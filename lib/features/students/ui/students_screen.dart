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
import 'package:ustoz_trainer/core/widgets/app_chip.dart';
import 'package:ustoz_trainer/core/widgets/empty_state.dart';
import 'package:ustoz_trainer/core/widgets/glass_card.dart';
import 'package:ustoz_trainer/core/widgets/plita_ring.dart';
import 'package:ustoz_trainer/core/widgets/skeleton.dart';
import 'package:ustoz_trainer/core/widgets/status_badge.dart';
import 'package:ustoz_trainer/core/widgets/student_card.dart';
import 'package:ustoz_trainer/features/students/providers/students_provider.dart';

/// S5 — shogirdlar ro'yxati.
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
    // Oxiriga 400px qolganda keyingi sahifani so'raymiz.
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
      unawaited(ref.read(studentsProvider.notifier).loadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final AsyncValue<StudentsState> async = ref.watch(studentsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(studentsProvider.notifier).refresh(),
      backgroundColor: c.sheet,
      color: c.anor,
      child: CustomScrollView(
        controller: _scroll,
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.x4l,
              AppSpacing.screenH,
              0,
            ),
            sliver: SliverList.list(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        s.students,
                        style: AppText.display24.copyWith(color: c.ink),
                      ),
                    ),
                    Text(
                      s.activeCount(async.value?.total ?? 0),
                      style: AppText.body13Bold.copyWith(color: c.dim),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                _SearchBar(
                  controller: _search,
                  onChanged: ref.read(studentsProvider.notifier).search,
                ),
                const SizedBox(height: AppSpacing.xl),
                _Filters(
                  current: async.value?.filter ?? StudentFilter.all,
                  onSelect: ref.read(studentsProvider.notifier).setFilter,
                ),
                const SizedBox(height: AppSpacing.x3l),
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
          AppSpacing.screenH,
          0,
          AppSpacing.screenH,
          AppSpacing.screenBottom,
        ),
        sliver: SliverList.separated(
          itemCount: data.items.length + (data.loadingMore ? 1 : 0),
          separatorBuilder: (BuildContext _, int _) =>
              const SizedBox(height: AppSpacing.cardGap),
          itemBuilder: (BuildContext context, int i) {
            if (i >= data.items.length) {
              return const Skeleton(height: 92, radius: AppRadius.card);
            }
            return _StudentTile(student: data.items[i]);
          },
        ),
      ),
    ];
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;
    final int? left = student.sessionsLeft;

    final (
      RingTone tone,
      BadgeTone badgeTone,
      String label,
      double value,
    ) = switch (student.paymentState) {
      PaymentState.overdue => (
        RingTone.debt,
        BadgeTone.debt,
        s.filterDebtors,
        1.0,
      ),
      PaymentState.dueToday => (RingTone.warn, BadgeTone.warn, s.today, 0.12),
      PaymentState.dueSoon => (RingTone.warn, BadgeTone.warn, s.dueSoon, 0.4),
      PaymentState.paid ||
      PaymentState.none => (RingTone.ok, BadgeTone.ok, s.filterActive, 0.83),
    };

    return StudentCard(
      name: student.name,
      subtitle: Text(
        left == null
            ? '${s.tariffName(student.tariffType)} · '
                  '${Money.format(student.tariffPrice)}'
            : '${s.tariffName(student.tariffType)} '
                  '${student.sessionsTotal} · ${s.sessionsLeft(left)}',
      ),
      ringValue: value,
      ringTone: tone,
      ringLabel: student.isDebtor ? '!' : null,
      debt: student.isDebtor,
      badge: StatusBadge(label, tone: badgeTone),
      trailingText: student.isDebtor ? Money.format(student.tariffPrice) : null,
      onTap: () => context.push(Routes.student(student.id)),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.lg,
      ),
      radius: AppRadius.xxl,
      child: Row(
        children: <Widget>[
          Icon(Icons.search, size: 17, color: c.dim),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppText.body145.copyWith(color: c.ink),
              cursorColor: c.anor,
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

class _Filters extends StatelessWidget {
  const _Filters({required this.current, required this.onSelect});

  final StudentFilter current;
  final ValueChanged<StudentFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    // Hisoblagichlar SERVERDAN kelmaydi (kontraktda filtr bo'yicha
    // sonlar yo'q) — shuning uchun chiplar sonsiz. Dizayndagi sonlar
    // uchun `GET /students?filter=X` ni har filtr uchun chaqirish
    // kerak bo'lardi: 5 ta ortiqcha so'rov, arzimaydi.
    final List<(StudentFilter, String, Color?)> filters =
        <(StudentFilter, String, Color?)>[
          (StudentFilter.all, s.all, null),
          (StudentFilter.debtors, s.filterDebtors, c.debt),
          (StudentFilter.upcoming, s.filterUpcoming, null),
          (StudentFilter.active, s.filterActive, null),
          (StudentFilter.archived, s.filterArchived, null),
        ];

    return AppChipRow(
      children: <Widget>[
        for (final (StudentFilter f, String label, Color? color) in filters)
          AppChip(
            label: label,
            selected: current == f,
            labelColor: color,
            onTap: () => onSelect(f),
          ),
      ],
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      sliver: SliverList.separated(
        itemCount: 5,
        separatorBuilder: (BuildContext _, int _) =>
            const SizedBox(height: AppSpacing.cardGap),
        itemBuilder: (BuildContext _, int _) =>
            const Skeleton(height: 92, radius: AppRadius.card),
      ),
    );
  }
}
