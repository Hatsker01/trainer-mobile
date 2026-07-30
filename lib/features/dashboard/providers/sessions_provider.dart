import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustoz_trainer/core/api/dto/session_dto.dart';
import 'package:ustoz_trainer/core/providers.dart';

/// Bugungi mashg'ulot slotlari (`GET /sessions`, default = bugun).
/// Dashboard "Bugungi lenta" bo'limi shu provider'ni kuzatadi.
final FutureProvider<List<SessionDto>> todaySessionsProvider =
    FutureProvider<List<SessionDto>>((Ref ref) async {
      final Dio dio = ref.watch(dioProvider);
      final Response<dynamic> r = await dio.get<dynamic>('/sessions');
      final List<dynamic> data = (r.data as List<dynamic>?) ?? <dynamic>[];
      return data
          .map((dynamic e) => SessionDto.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    });
