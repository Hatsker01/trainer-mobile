import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/api/app_exception.dart';
import 'package:ustoz_trainer/core/api/dto/auth_dto.dart';
import 'package:ustoz_trainer/core/api/repositories.dart';
import 'package:ustoz_trainer/core/providers.dart';
import 'package:ustoz_trainer/features/auth/providers/session_provider.dart';

/// Kirish oqimi holati (telefon → OTP).
class AuthFlowState {
  const AuthFlowState({
    this.phone = '',
    this.busy = false,
    this.error,
    this.fieldError,
    this.channel,
    this.resendAfter,
    this.codeRejected = false,
  });

  /// `+998901234567`.
  final String phone;

  /// So'rov ketmoqda — tugma bloklanadi (double-tap himoyasi).
  final bool busy;

  /// Umumiy xato (tarmoq, server).
  final String? error;

  /// Maydonga tegishli xato (422).
  final String? fieldError;

  final OtpChannel? channel;

  /// Qayta yuborishgacha qolgan vaqt.
  final Duration? resendAfter;

  /// Kod noto'g'ri — kataklar silkinadi.
  final bool codeRejected;

  AuthFlowState copyWith({
    String? phone,
    bool? busy,
    String? error,
    String? fieldError,
    OtpChannel? channel,
    Duration? resendAfter,
    bool? codeRejected,
    bool clearError = false,
  }) => AuthFlowState(
    phone: phone ?? this.phone,
    busy: busy ?? this.busy,
    error: clearError ? null : (error ?? this.error),
    fieldError: clearError ? null : (fieldError ?? this.fieldError),
    channel: channel ?? this.channel,
    resendAfter: resendAfter ?? this.resendAfter,
    codeRejected: codeRejected ?? this.codeRejected,
  );
}

final NotifierProvider<AuthFlowNotifier, AuthFlowState> authFlowProvider =
    NotifierProvider<AuthFlowNotifier, AuthFlowState>(AuthFlowNotifier.new);

class AuthFlowNotifier extends Notifier<AuthFlowState> {
  @override
  AuthFlowState build() => const AuthFlowState();

  AuthRepository get _auth => ref.read(authRepositoryProvider);

  /// Kod so'rash. `true` — OTP ekraniga o'tish mumkin.
  Future<bool> requestOtp(String phone) async {
    if (state.busy) {
      return false;
    }
    state = state.copyWith(busy: true, clearError: true, phone: phone);

    try {
      final OtpRequestResponse r = await _auth.requestOtp(phone);
      state = state.copyWith(
        busy: false,
        channel: r.channel,
        // Server `retry_after` bermasa — dizayndagi 60s.
        resendAfter: r.resendAfter ?? const Duration(seconds: 60),
      );
      return true;
    } on ValidationException catch (e) {
      state = state.copyWith(
        busy: false,
        fieldError: e.forField('phone') ?? e.message,
      );
      return false;
    } on RateLimitException catch (e) {
      state = state.copyWith(
        busy: false,
        error: e.message,
        resendAfter: e.retryAfter,
      );
      return false;
    } on AppException catch (e) {
      state = state.copyWith(busy: false, error: e.message);
      return false;
    }
  }

  /// Kodni tasdiqlash. `true` — sessiya ochildi.
  Future<bool> verify(String code) async {
    if (state.busy) {
      return false;
    }
    state = state.copyWith(busy: true, clearError: true, codeRejected: false);

    try {
      final TokenPair tokens = await _auth.verifyOtp(
        phone: state.phone,
        code: code,
      );
      await ref.read(sessionProvider.notifier).signIn(tokens);
      state = state.copyWith(busy: false);
      return true;
    } on UnauthorizedException catch (e) {
      // Kontrakt: 401 `otp_invalid` — kod noto'g'ri yoki muddati o'tgan.
      state = state.copyWith(busy: false, error: e.message, codeRejected: true);
      return false;
    } on RateLimitException catch (e) {
      state = state.copyWith(
        busy: false,
        error: e.message,
        resendAfter: e.retryAfter,
        codeRejected: true,
      );
      return false;
    } on AppException catch (e) {
      state = state.copyWith(busy: false, error: e.message);
      return false;
    }
  }

  void clearError() =>
      state = state.copyWith(clearError: true, codeRejected: false);
}
