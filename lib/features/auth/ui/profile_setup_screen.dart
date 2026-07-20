import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/dto/auth_dto.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/providers.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/widgets/app_button.dart';
import 'package:ustoz_trainer/core/widgets/app_field.dart';
import 'package:ustoz_trainer/core/widgets/app_toast.dart';
import 'package:ustoz_trainer/features/auth/providers/session_provider.dart';

/// S3 — birinchi kirishda profil sozlash (ism majburiy, zal ixtiyoriy).
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _gym = TextEditingController();

  bool _busy = false;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    // Server allaqachon ism bergan bo'lsa (masalan Telegram'dan) —
    // maydonni to'ldirib qo'yamiz.
    final SessionState session = ref.read(sessionProvider);
    if (session is SessionActive) {
      _name.text = session.me.name;
      _gym.text = session.me.gymName ?? '';
    }
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _gym.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) {
      return;
    }
    final String name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = context.s.fieldRequired);
      return;
    }

    setState(() {
      _busy = true;
      _nameError = null;
    });

    try {
      final String gym = _gym.text.trim();
      final Me me = await ref
          .read(meRepositoryProvider)
          .updateMe(MeUpdate(name: name, gymName: gym.isEmpty ? null : gym));
      ref.read(sessionProvider.notifier).setMe(me);
      // Router `needsProfile: false` ni ko'rib dashboard'ga o'tkazadi.
    } on ValidationException catch (e) {
      setState(() {
        _busy = false;
        _nameError = e.forField('name');
      });
      if (mounted && e.forField('name') == null) {
        AppToast.show(context, e.message);
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

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: ListView(
            children: <Widget>[
              const SizedBox(height: AppSpacing.x7l),
              Text(
                s.profileTitle,
                style: AppText.display24.copyWith(color: c.ink),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                s.profileSubtitle,
                style: AppText.body14.copyWith(color: c.soft),
              ),
              const SizedBox(height: AppSpacing.x7l),
              AppField(
                controller: _name,
                label: s.fieldName,
                errorText: _nameError,
                enabled: !_busy,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppField(
                controller: _gym,
                label: '${s.fieldGym} · ${s.fieldOptional}',
                enabled: !_busy,
              ),
              const SizedBox(height: AppSpacing.x6l),
              GradientButton(
                label: s.done,
                loading: _busy,
                onPressed: _name.text.trim().isEmpty ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
