import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/utils/money.dart';
import 'package:ustoz_trainer/core/widgets/app_button.dart';
import 'package:ustoz_trainer/core/widgets/app_toast.dart';
import 'package:ustoz_trainer/core/widgets/empty_state.dart';
import 'package:ustoz_trainer/core/widgets/skeleton.dart';
import 'package:ustoz_trainer/features/recommendations/providers/recommendations_provider.dart';

const List<String> kRecCategories = <String>[
  'sportpit',
  'water',
  'sleep',
  'nutrition',
  'training',
  'other',
];

Color catColor(AppColors c, String cat) => switch (cat) {
  'water' => c.warn,
  'sleep' || 'nutrition' => c.ok,
  'other' => c.soft,
  _ => c.anor2,
};

/// S6 profil — "Tavsiyalar" tabi.
class RecommendationsTab extends ConsumerWidget {
  const RecommendationsTab({
    required this.studentId,
    required this.studentName,
    super.key,
  });

  final String studentId;
  final String studentName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppStrings s = context.s;
    final AsyncValue<List<Recommendation>> async = ref.watch(
      recommendationsProvider(studentId),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GradientButton(
          label: s.addRecommendation,
          icon: const Icon(Icons.add),
          onPressed: () =>
              showAddRecommendationSheet(context, studentId, studentName),
        ),
        const SizedBox(height: AppSpacing.lg),
        async.when(
          loading: () => const Skeleton(height: 120, radius: 12),
          error: (Object _, StackTrace _) => EmptyState(
            emoji: '💡',
            title: s.noRecommendations,
            compact: true,
          ),
          data: (List<Recommendation> items) {
            if (items.isEmpty) {
              return EmptyState(
                emoji: '💡',
                title: s.noRecommendations,
                compact: true,
              );
            }
            return Column(
              children: <Widget>[
                for (final Recommendation r in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _RecCard(rec: r, studentId: studentId),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _RecCard extends ConsumerWidget {
  const _RecCard({required this.rec, required this.studentId});

  final Recommendation rec;
  final String studentId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final AppStrings s = context.s;
    final AppColors c = context.colors;
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext d) => AlertDialog(
        backgroundColor: c.sheet,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          s.recDeleteConfirm,
          style: AppText.body14.copyWith(color: c.ink),
        ),
        actions: <Widget>[
          GhostButton(
            label: s.cancel,
            size: AppButtonSize.small,
            expand: false,
            onPressed: () => Navigator.of(d).pop(false),
          ),
          GhostButton(
            label: s.recDelete,
            size: AppButtonSize.small,
            expand: false,
            color: c.debt,
            onPressed: () => Navigator.of(d).pop(true),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      try {
        await ref.read(recommendationsRepoProvider).delete(rec.id);
        ref.invalidate(recommendationsProvider(studentId));
      } on AppException catch (e) {
        if (context.mounted) {
          AppToast.show(context, e.message);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final Color cc = catColor(c, rec.category);

    return GestureDetector(
      onLongPress: () => _delete(context, ref),
      child: Container(
        decoration: BoxDecoration(
          color: c.glassHi,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: cc.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    s.recCategoryName(rec.category),
                    style: AppText.badge11.copyWith(color: cc),
                  ),
                ),
                const Spacer(),
                if (rec.isBroadcast)
                  Icon(Icons.campaign_outlined, size: 16, color: c.soft),
                if (rec.createdAt != null) ...<Widget>[
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    s.dayMonth(rec.createdAt!),
                    style: AppText.caption12.copyWith(color: c.dim),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(rec.text, style: AppText.body14.copyWith(color: c.ink)),
            if (rec.product != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              _ProductMiniCard(product: rec.product!),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProductMiniCard extends StatelessWidget {
  const _ProductMiniCard({required this.product});

  final RecProduct product;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    return Container(
      decoration: BoxDecoration(
        color: c.glass,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.line),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.anor2.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.shopping_bag_outlined, size: 18, color: c.anor2),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  product.name,
                  style: AppText.body13Bold.copyWith(color: c.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  Money.withUnit(product.price),
                  style: AppText.caption12.copyWith(color: c.soft),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: c.ok.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              s.referralHint,
              style: AppText.badge11.copyWith(color: c.ok),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showAddRecommendationSheet(
  BuildContext context,
  String studentId,
  String studentName,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.sheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext _) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _AddRecSheet(studentId: studentId, studentName: studentName),
    ),
  );
}

class _AddRecSheet extends ConsumerStatefulWidget {
  const _AddRecSheet({required this.studentId, required this.studentName});

  final String studentId;
  final String studentName;

  @override
  ConsumerState<_AddRecSheet> createState() => _AddRecSheetState();
}

class _AddRecSheetState extends ConsumerState<_AddRecSheet> {
  static const int _maxLen = 1000;
  final TextEditingController _text = TextEditingController();
  String _category = kRecCategories.first;
  RecProduct? _product;
  bool _broadcast = false;
  bool _busy = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _pickProduct() async {
    final RecProduct? picked = await showModalBottomSheet<RecProduct>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.sheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext _) => const _ProductPicker(),
    );
    if (picked != null) {
      setState(() => _product = picked);
    }
  }

  Future<void> _submit() async {
    if (_busy) {
      return;
    }
    final String text = _text.text.trim();
    if (text.isEmpty) {
      return;
    }
    setState(() => _busy = true);
    final AppStrings s = context.s;
    try {
      final RecommendationsRepo repo = ref.read(recommendationsRepoProvider);
      if (_broadcast) {
        await repo.broadcast(_category, text, _product?.id);
      } else {
        await repo.create(widget.studentId, _category, text, _product?.id);
      }
      ref.invalidate(recommendationsProvider(widget.studentId));
      await HapticFeedback.lightImpact();
      if (mounted) {
        Navigator.of(context).pop();
        AppToast.show(
          context,
          _broadcast ? s.recBroadcastSent : s.recSentTo(widget.studentName),
        );
      }
    } on AppException catch (e) {
      setState(() => _busy = false);
      if (mounted) {
        AppToast.show(context, e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.x4l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              s.addRecommendation,
              style: AppText.h18.copyWith(color: c.anor2),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              s.recCategory,
              style: AppText.body13Bold.copyWith(color: c.soft),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                for (final String cat in kRecCategories)
                  GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: _category == cat ? catColor(c, cat) : c.glassHi,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        s.recCategoryName(cat),
                        style: AppText.body13Bold.copyWith(
                          color: _category == cat ? Colors.white : c.soft,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              decoration: BoxDecoration(
                color: c.glassHi,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: TextField(
                controller: _text,
                maxLines: 4,
                maxLength: _maxLen,
                style: AppText.body14.copyWith(color: c.ink),
                cursorColor: c.anor2,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: s.recTextHint,
                  hintStyle: AppText.body14.copyWith(color: c.dim),
                  counterText: '${_text.text.characters.length}/$_maxLen',
                  counterStyle: AppText.caption12.copyWith(color: c.dim),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_product == null)
              GhostButton(
                label: s.linkProduct,
                icon: const Icon(Icons.link),
                onPressed: _pickProduct,
              )
            else
              GestureDetector(
                onTap: _pickProduct,
                child: _ProductMiniCard(product: _product!),
              ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    s.toAllStudents,
                    style: AppText.body15Bold.copyWith(color: c.ink),
                  ),
                ),
                Switch(
                  value: _broadcast,
                  activeTrackColor: c.anor2,
                  onChanged: (bool v) => setState(() => _broadcast = v),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            GradientButton(
              label: s.send,
              loading: _busy,
              onPressed: _text.text.trim().isEmpty ? null : _submit,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

class _ProductPicker extends ConsumerStatefulWidget {
  const _ProductPicker();

  @override
  ConsumerState<_ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends ConsumerState<_ProductPicker> {
  final TextEditingController _q = TextEditingController();
  List<RecProduct> _items = const <RecProduct>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final List<RecProduct> items = await ref
        .read(recommendationsRepoProvider)
        .products(q: _q.text);
    if (mounted) {
      setState(() {
        _items = items;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x4l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: c.glassHi,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.search, size: 18, color: c.dim),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: _q,
                      style: AppText.body14.copyWith(color: c.ink),
                      cursorColor: c.anor2,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _load(),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: s.searchProduct,
                        hintStyle: AppText.body14.copyWith(color: c.dim),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_loading)
              const Skeleton(height: 120, radius: 12)
            else if (_items.isEmpty)
              EmptyState(emoji: '🛒', title: s.noRecommendations, compact: true)
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _items.length,
                  separatorBuilder: (BuildContext _, int _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (BuildContext _, int i) => GestureDetector(
                    onTap: () => Navigator.of(context).pop(_items[i]),
                    child: _ProductMiniCard(product: _items[i]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
