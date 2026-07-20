import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/dto/dashboard_dto.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
import 'package:ustoz_trainer/core/api/dto/student_dto.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/providers.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/widgets/app_bottom_sheet.dart';
import 'package:ustoz_trainer/core/widgets/app_button.dart';
import 'package:ustoz_trainer/core/widgets/app_toast.dart';
import 'package:ustoz_trainer/core/widgets/avatar.dart';
import 'package:ustoz_trainer/core/widgets/empty_state.dart';
import 'package:ustoz_trainer/core/widgets/skeleton.dart';
import 'package:ustoz_trainer/features/attendance/providers/outbox.dart';
import 'package:ustoz_trainer/features/dashboard/providers/dashboard_provider.dart';

/// Davomad sheeti (S9).
Future<void> showAttendanceSheet(BuildContext context) => showAppSheet<void>(
  context: context,
  title: context.s.markAttendance,
  child: const AttendanceSheet(),
);

/// Aktiv shogirdlar ro'yxati + checkboxlar + bulk yuborish.
///
/// Offline (T8): tarmoq yo'q bo'lsa navbatga tushadi, banner ko'rsatiladi.
class AttendanceSheet extends ConsumerStatefulWidget {
  const AttendanceSheet({super.key});

  @override
  ConsumerState<AttendanceSheet> createState() => _AttendanceSheetState();
}

class _AttendanceSheetState extends ConsumerState<AttendanceSheet> {
  final Set<String> _selected = <String>{};
  bool _busy = false;

  late final Future<List<Student>> _students = ref
      .read(studentRepositoryProvider)
      .list(filter: StudentFilter.active, limit: 100)
      .then((PagedStudents p) => p.items);

  Future<void> _submit() async {
    if (_busy || _selected.isEmpty) {
      return;
    }
    setState(() => _busy = true);

    final AppStrings s = context.s;
    final DateTime today = DateTime.now();
    final AttendanceBulkRequest request = AttendanceBulkRequest(
      date: today,
      studentIds: _selected.toList(),
    );

    try {
      final AttendanceBulkResponse r = await ref
          .read(attendanceRepositoryProvider)
          .markBulk(request);

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      AppToast.show(context, s.attendanceSaved(r.marked));
      unawaited(ref.read(dashboardProvider.notifier).invalidateQuietly());
    } on NetworkException {
      // T8: offline — navbatga.
      await ref
          .read(outboxProvider.notifier)
          .enqueue(OutboxEntry(date: today, studentIds: _selected.toList()));
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      AppToast.show(context, s.offlineBanner);
    } on TimeoutException {
      await ref
          .read(outboxProvider.notifier)
          .enqueue(OutboxEntry(date: today, studentIds: _selected.toList()));
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      AppToast.show(context, s.offlineBanner);
    } on AppException catch (e) {
      setState(() => _busy = false);
      if (mounted) {
        AppToast.show(context, e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings s = context.s;

    return FutureBuilder<List<Student>>(
      future: _students,
      builder: (BuildContext context, AsyncSnapshot<List<Student>> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.x4l),
            child: Column(
              spacing: AppSpacing.md,
              children: <Widget>[
                Skeleton(height: 52, radius: AppRadius.xxl),
                Skeleton(height: 52, radius: AppRadius.xxl),
                Skeleton(height: 52, radius: AppRadius.xxl),
              ],
            ),
          );
        }

        if (snap.hasError) {
          return EmptyState(
            emoji: '😕',
            title: snap.error is AppException
                ? (snap.error! as AppException).message
                : s.errGeneric,
            compact: true,
          );
        }

        final List<Student> students = snap.data ?? const <Student>[];
        if (students.isEmpty) {
          return EmptyState(emoji: '🤷', title: s.noStudents, compact: true);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: students.length,
                itemBuilder: (BuildContext context, int i) {
                  final Student student = students[i];
                  return _StudentRow(
                    student: student,
                    checked: _selected.contains(student.id),
                    onToggle: _busy
                        ? null
                        : () => setState(() {
                            if (!_selected.remove(student.id)) {
                              _selected.add(student.id);
                            }
                          }),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxl),
              child: GradientButton(
                label: '${s.save} (${_selected.length})',
                loading: _busy,
                onPressed: _selected.isEmpty ? null : _submit,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({
    required this.student,
    required this.checked,
    required this.onToggle,
  });

  final Student student;
  final bool checked;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final int? left = student.sessionsLeft;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: <Widget>[
            _CheckBox(checked: checked),
            const SizedBox(width: AppSpacing.lg),
            Avatar.small(student.name),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    student.name,
                    style: AppText.body14Bold.copyWith(color: c.ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Paketlilarga "N qoldi".
                  if (left != null)
                    Text(
                      s.sessionsLeft(left),
                      style: AppText.caption12.copyWith(
                        color: left <= 2 ? c.warn : c.dim,
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

/// Dizayndagi `.chk .box` — 20×20, r7, tanlanganda anor gradient.
class _CheckBox extends StatelessWidget {
  const _CheckBox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return AnimatedContainer(
      duration: AppDuration.fast,
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: checked ? c.anorGradient : null,
        borderRadius: BorderRadius.circular(AppRadius.chk),
        border: Border.all(
          color: checked ? Colors.transparent : c.dim,
          width: 1.5,
        ),
      ),
      child: checked
          ? const Icon(Icons.check, size: 13, color: Colors.white)
          : null,
    );
  }
}
