import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
import 'package:ustoz_trainer/core/api/dto/student_dto.dart';
import 'package:ustoz_trainer/core/i18n/lang_provider.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/router/app_router.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/utils/money.dart';
import 'package:ustoz_trainer/core/widgets/avatar.dart';
import 'package:ustoz_trainer/core/widgets/empty_state.dart';
import 'package:ustoz_trainer/core/widgets/skeleton.dart';
import 'package:ustoz_trainer/features/payments/ui/payment_sheet.dart';
import 'package:ustoz_trainer/features/students/providers/students_provider.dart';

/// S5 — Shogirdlar ro'yxati (REDESIGN, root-1-11): boy kartalar (avatar,
/// balans, jami to'langan, To'lov qo'shish) + segment filtrlar.
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
              AppSpacing.x4l,
              AppSpacing.screenEdge,
              0,
            ),
            sliver: SliverList.list(
              children: <Widget>[
                _Header(students: s.students),
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
          AppSpacing.screenEdge,
          0,
          AppSpacing.screenEdge,
          AppSpacing.screenBottom,
        ),
        sliver: SliverList.separated(
          itemCount: data.items.length + (data.loadingMore ? 1 : 0),
          separatorBuilder: (BuildContext _, int _) =>
              const SizedBox(height: AppSpacing.xl),
          itemBuilder: (BuildContext context, int i) {
            if (i >= data.items.length) {
              return const Skeleton(height: 68, radius: 18);
            }
            return _StudentCard(student: data.items[i]);
          },
        ),
      ),
    ];
  }
}

BoxDecoration cardDecoration(AppColors c, {double radius = 18}) {
  return BoxDecoration(
    color: c.glass,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: c.line),
    boxShadow: const <BoxShadow>[
      BoxShadow(
        color: Color.fromRGBO(17, 24, 39, 0.05),
        blurRadius: 18,
        offset: Offset(0, 6),
      ),
    ],
  );
}

class _Header extends ConsumerWidget {
  const _Header({required this.students});

  final String students;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final Lang lang = ref.watch(langProvider);

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            students,
            style: AppText.display24.copyWith(color: c.anor2),
          ),
        ),
        GestureDetector(
          onTap: () => ref
              .read(langProvider.notifier)
              .set(lang == Lang.uz ? Lang.ru : Lang.uz),
          child: Container(
            width: 48,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.glassHi,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              lang == Lang.uz ? 'UZ' : 'RU',
              style: AppText.body13Bold.copyWith(color: c.anor2),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        GestureDetector(
          onTap: () => context.push(Routes.studentNew),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.anor2, shape: BoxShape.circle),
            child: const Icon(Icons.add, size: 24, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _StudentCard extends ConsumerWidget {
  const _StudentCard({required this.student});

  final Student student;

  Future<void> _pay(BuildContext context, WidgetRef ref) async {
    final bool? saved = await showPaymentSheet(
      context,
      studentId: student.id,
      studentName: student.name,
      amount: student.tariffPrice,
    );
    if (saved ?? false) {
      await ref.read(studentsProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    // F3: bitta semantik signal — holat nuqtasi + bitta ikkilamchi qator.
    final (
      Color dot,
      String? sub,
      Color subColor,
      bool showPay,
    ) = switch (student.paymentState) {
      PaymentState.overdue => (
        c.debt,
        '${s.daysLate(student.daysOverdue ?? 0)} · '
            '${Money.compact(student.balance?.abs() ?? student.tariffPrice)}',
        c.debt,
        true,
      ),
      PaymentState.dueToday => (c.warn, s.today, c.warn, true),
      PaymentState.dueSoon => (
        c.warn,
        student.nextDueDate == null ? null : s.dayMonth(student.nextDueDate!),
        c.soft,
        false,
      ),
      PaymentState.paid || PaymentState.none => (c.ok, null, c.soft, false),
    };

    return GestureDetector(
      onTap: () => context.push(Routes.student(student.id)),
      child: Container(
        decoration: cardDecoration(c),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.md),
            Avatar.small(student.name, url: student.avatarUrl),
            const SizedBox(width: AppSpacing.md),
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
                  if (sub != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: AppText.body13.copyWith(color: subColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (showPay)
              GestureDetector(
                onTap: () => _pay(context, ref),
                child: Container(
                  height: 34,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    color: c.anor2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    s.payment,
                    style: AppText.body13Bold.copyWith(color: Colors.white),
                  ),
                ),
              )
            else
              Icon(Icons.chevron_right, size: 22, color: c.dim),
          ],
        ),
      ),
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

    return Container(
      decoration: BoxDecoration(
        color: c.glass,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: c.line),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xl,
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.search, size: 18, color: c.dim),
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
      child: Row(
        children: <Widget>[
          for (final (StudentFilter f, String label) in filters)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _FilterTab(
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

class _FilterTab extends StatelessWidget {
  const _FilterTab({
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
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4l,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected ? c.anor2 : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: AppText.body14Bold.copyWith(
            color: selected ? Colors.white : c.soft,
          ),
        ),
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
      sliver: SliverList.separated(
        itemCount: 4,
        separatorBuilder: (BuildContext _, int _) =>
            const SizedBox(height: AppSpacing.xl),
        itemBuilder: (BuildContext _, int _) =>
            const Skeleton(height: 68, radius: 18),
      ),
    );
  }
}
