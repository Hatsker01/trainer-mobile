import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/api/dto/auth_dto.dart';
import 'package:ustoz_trainer/core/i18n/strings.dart';
import 'package:ustoz_trainer/core/theme/app_colors.dart';
import 'package:ustoz_trainer/core/theme/app_spacing.dart';
import 'package:ustoz_trainer/core/theme/app_text.dart';
import 'package:ustoz_trainer/core/widgets/app_button.dart';
import 'package:ustoz_trainer/core/widgets/app_toast.dart';
import 'package:ustoz_trainer/features/auth/providers/auth_provider.dart';
import 'package:ustoz_trainer/features/auth/ui/otp_field.dart';

/// S2 — 6 xonali kod.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<OtpFieldState> _fieldKey = GlobalKey<OtpFieldState>();

  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    // `requestOtp` javobidagi `retry_after` (yoki 60s) dan taymer.
    final Duration? after = ref.read(authFlowProvider).resendAfter;
    _startTimer(after ?? const Duration(seconds: 60));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer(Duration duration) {
    _timer?.cancel();
    setState(() => _secondsLeft = duration.inSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
      }
    });
  }

  Future<void> _verify(String code) async {
    final bool ok = await ref.read(authFlowProvider.notifier).verify(code);
    if (!mounted) {
      return;
    }

    if (ok) {
      // Router `sessionProvider` ni kuzatadi — redirect o'zi ishlaydi.
      return;
    }

    final AuthFlowState auth = ref.read(authFlowProvider);
    if (auth.codeRejected) {
      _fieldKey.currentState?.shake();
      _controller.clear();
    }
    if (auth.error != null) {
      AppToast.show(context, auth.error!);
    }
    // Rate limit javobida yangi taymer kelgan bo'lishi mumkin.
    if (auth.resendAfter != null &&
        auth.resendAfter!.inSeconds > _secondsLeft) {
      _startTimer(auth.resendAfter!);
    }
  }

  Future<void> _resend() async {
    final AuthFlowState auth = ref.read(authFlowProvider);
    final bool ok = await ref
        .read(authFlowProvider.notifier)
        .requestOtp(auth.phone);

    if (!mounted) {
      return;
    }
    final AuthFlowState next = ref.read(authFlowProvider);
    _startTimer(next.resendAfter ?? const Duration(seconds: 60));

    if (!ok && next.error != null) {
      AppToast.show(context, next.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AppStrings s = context.s;
    final AuthFlowState auth = ref.watch(authFlowProvider);
    final bool canResend = _secondsLeft <= 0 && !auth.busy;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: ListView(
            children: <Widget>[
              const SizedBox(height: AppSpacing.x7l),
              Text(s.otpTitle, style: AppText.display24.copyWith(color: c.ink)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                s.otpSubtitle(auth.phone),
                style: AppText.body14.copyWith(color: c.soft),
              ),
              if (auth.channel != null) ...<Widget>[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  auth.channel == OtpChannel.tg
                      ? s.otpChannelTg
                      : s.otpChannelSms,
                  style: AppText.caption12.copyWith(color: c.dim),
                ),
              ],
              const SizedBox(height: AppSpacing.x7l),
              OtpField(
                key: _fieldKey,
                controller: _controller,
                enabled: !auth.busy,
                hasError: auth.codeRejected,
                onCompleted: _verify,
              ),
              const SizedBox(height: AppSpacing.x4l),
              Center(
                child: canResend
                    ? GhostButton(
                        label: s.otpResend,
                        size: AppButtonSize.small,
                        expand: false,
                        onPressed: _resend,
                      )
                    : Text(
                        s.otpResendIn(_secondsLeft),
                        style: AppText.body13.copyWith(color: c.dim),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
