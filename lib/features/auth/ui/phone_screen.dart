import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/router/app_router.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/widgets/app_button.dart';
import 'package:ustoz_trainer/core/widgets/app_toast.dart';
import 'package:ustoz_trainer/features/auth/providers/auth_provider.dart';
import 'package:ustoz_trainer/features/auth/ui/phone_field.dart';

/// S1 — telefon kiritish.
class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!PhoneField.isComplete(_controller.text)) {
      return;
    }
    final bool ok = await ref
        .read(authFlowProvider.notifier)
        .requestOtp(PhoneField.toE164(_controller.text));

    if (!mounted) {
      return;
    }
    if (ok) {
      unawaited(context.push(Routes.otp));
    } else {
      final String? error = ref.read(authFlowProvider).error;
      if (error != null) {
        AppToast.show(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final AuthFlowState auth = ref.watch(authFlowProvider);
    final bool complete = PhoneField.isComplete(_controller.text);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          // Klaviatura ochilganda ham hamma narsa ko'rinsin (T9).
          child: ListView(
            children: <Widget>[
              const SizedBox(height: AppSpacing.x7l),
              Text(
                s.phoneTitle,
                style: AppText.display24.copyWith(color: c.ink),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                s.phoneSubtitle,
                style: AppText.body14.copyWith(color: c.soft),
              ),
              const SizedBox(height: AppSpacing.x7l),
              PhoneField(
                controller: _controller,
                enabled: !auth.busy,
                errorText: auth.fieldError,
                onSubmitted: _submit,
              ),
              const SizedBox(height: AppSpacing.x6l),
              GradientButton(
                label: s.next,
                loading: auth.busy,
                onPressed: complete ? _submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
