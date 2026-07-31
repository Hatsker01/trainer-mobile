import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/env.dart';
import 'package:ustoz_trainer/core/providers.dart';
import 'package:ustoz_trainer/core/storage/token_storage.dart';
import 'package:ustoz_trainer/features/dashboard/providers/dashboard_provider.dart';
import 'package:ustoz_trainer/features/schedule_requests/providers/link_requests_provider.dart';
import 'package:ustoz_trainer/features/schedule_requests/providers/schedule_requests_provider.dart';
import 'package:ustoz_trainer/features/students/providers/students_provider.dart';

/// SSE real-time klient (C4 sync) — `GET /api/v1/events`.
///
/// Shogird amal qilganда (kod bilan so'rov, kelolmayman, o'lchov) trener
/// kanaliga hodisa keladi; front tegishli providerni invalidate qiladi.
/// Ulanish uzilsa reconnect backoff + 30s polling zaxira.
class TrainerSseService {
  TrainerSseService(this._ref);

  final Ref _ref;

  HttpClient? _http;
  StreamSubscription<String>? _sub;
  Timer? _pollTimer;
  Timer? _retryTimer;
  bool _running = false;
  bool _connected = false;
  int _backoffMs = 3000;

  static const int _maxBackoffMs = 30000;

  void start() {
    if (_running) return;
    _running = true;
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_connected) _invalidateLive();
    });
    _connect();
  }

  void stop() {
    _running = false;
    _connected = false;
    _retryTimer?.cancel();
    _pollTimer?.cancel();
    _sub?.cancel();
    _http?.close(force: true);
    _http = null;
  }

  Future<void> _connect() async {
    if (!_running) return;
    final Tokens? tokens = await _ref.read(tokenStorageProvider).read();
    final String? token = tokens?.access;
    if (token == null || token.isEmpty) {
      _scheduleRetry();
      return;
    }
    final Uri uri = Uri.parse('${Env.apiUrl}/events?access=$token');
    try {
      final HttpClient http = HttpClient()
        ..connectionTimeout = const Duration(seconds: 10);
      _http = http;
      final HttpClientRequest req = await http.getUrl(uri);
      req.headers.set('Accept', 'text/event-stream');
      final HttpClientResponse resp = await req.close();
      if (resp.statusCode != 200) {
        _connected = false;
        _scheduleRetry();
        return;
      }
      _connected = true;
      _backoffMs = 3000;
      String eventType = 'message';
      _sub = resp
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (String line) {
              if (line.startsWith('event:')) {
                eventType = line.substring(6).trim();
              } else if (line.startsWith('data:')) {
                _handle(eventType);
                eventType = 'message';
              }
            },
            onError: (_) {
              _connected = false;
              _scheduleRetry();
            },
            onDone: () {
              _connected = false;
              _scheduleRetry();
            },
            cancelOnError: true,
          );
    } on Exception {
      _connected = false;
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    _sub?.cancel();
    _http?.close(force: true);
    _http = null;
    if (!_running) return;
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(milliseconds: _backoffMs), _connect);
    _backoffMs = (_backoffMs * 2).clamp(3000, _maxBackoffMs);
  }

  void _handle(String type) {
    switch (type) {
      case 'link_request':
        _ref.invalidate(pendingLinkRequestsProvider);
        _ref.invalidate(studentsProvider);
      case 'rsvp':
        _ref.invalidate(pendingScheduleRequestsProvider);
      case 'link':
      case 'unlink':
        _ref.invalidate(studentsProvider);
        _ref.invalidate(dashboardProvider);
      case 'measurement':
      case 'payment':
      case 'attendance':
        _ref.invalidate(dashboardProvider);
      default:
        if (kDebugMode) debugPrint('SSE(trainer): noma\'lum "$type"');
    }
  }

  void _invalidateLive() {
    _ref.invalidate(pendingLinkRequestsProvider);
    _ref.invalidate(pendingScheduleRequestsProvider);
  }
}

/// Sessiya davomida tirik. AppShell watch qilganда start bo'ladi.
final Provider<TrainerSseService> trainerSseProvider =
    Provider<TrainerSseService>((Ref ref) {
  final TrainerSseService svc = TrainerSseService(ref);
  svc.start();
  ref.onDispose(svc.stop);
  return svc;
});
