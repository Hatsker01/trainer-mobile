import 'package:dio/dio.dart';
import 'package:ustoz_trainer/core/api/dto/auth_dto.dart';
import 'package:ustoz_trainer/core/api/dto/dashboard_dto.dart';
import 'package:ustoz_trainer/core/api/dto/enums.dart';
import 'package:ustoz_trainer/core/api/dto/payment_dto.dart';
import 'package:ustoz_trainer/core/api/dto/student_dto.dart';

/// Repozitoriy interfeyslari — providerlar SHULARGA bog'lanadi, impl'ga emas
/// (testda soxta impl qo'yiladi).

abstract interface class AuthRepository {
  Future<OtpRequestResponse> requestOtp(String phone);
  Future<TokenPair> verifyOtp({required String phone, required String code});
}

abstract interface class MeRepository {
  Future<Me> getMe();
  Future<Me> updateMe(MeUpdate update);
  Future<TgLink> getTrainerTgLink();
}

abstract interface class StudentRepository {
  Future<PagedStudents> list({
    StudentFilter filter = StudentFilter.all,
    String? query,
    int page = 1,
    int limit = 20,
  });
  Future<Student> get(String id);
  Future<Student> create(StudentCreate body);
  Future<Student> update(String id, StudentUpdate body);
  Future<Student> archive(String id);
  Future<TgLink> inviteLink(String id);
  Future<RemindResponse> remind(String id, {RemindRequest? body});
  Future<PagedPayments> payments(String id, {int page = 1, int limit = 20});
  Future<AttendanceList> attendance(String id, {DateTime? from, DateTime? to});
}

abstract interface class PaymentRepository {
  /// [idempotencyKey] — bir xil kalit bilan takroriy so'rov ASL to'lovni
  /// qaytaradi (server 201 bilan). Double-tap/retry himoyasi.
  Future<PaymentCreated> create(PaymentCreate body, {String? idempotencyKey});
}

abstract interface class AttendanceRepository {
  Future<AttendanceBulkResponse> markBulk(AttendanceBulkRequest body);
}

abstract interface class DashboardRepository {
  Future<DashboardResponse> get();
}

abstract interface class StatsRepository {
  Future<StatsResponse> get();
}

abstract interface class TariffRepository {
  Future<List<TariffTemplate>> list({bool includeInactive = false});
  Future<TariffTemplate> create(TariffCreate body);
  Future<TariffTemplate> update(String id, TariffUpdate body);
}

// ---------------------------------------------------------------- impl

/// Umumiy yordamchi — javob tanasini `Map` ga keltirish.
///
/// Dio `dynamic` qaytaradi; DTO factory'lari `Map<String, dynamic>` kutadi.
Map<String, dynamic> _obj(Response<dynamic> r) =>
    (r.data as Map).cast<String, dynamic>();

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<OtpRequestResponse> requestOtp(String phone) async {
    final Response<dynamic> r = await _dio.post<dynamic>(
      '/auth/otp/request',
      data: OtpRequest(phone: phone).toJson(),
    );
    return OtpRequestResponse.fromJson(_obj(r));
  }

  @override
  Future<TokenPair> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final Response<dynamic> r = await _dio.post<dynamic>(
      '/auth/otp/verify',
      data: OtpVerifyRequest(phone: phone, code: code).toJson(),
    );
    return TokenPair.fromJson(_obj(r));
  }
}

class MeRepositoryImpl implements MeRepository {
  const MeRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Me> getMe() async => Me.fromJson(_obj(await _dio.get<dynamic>('/me')));

  @override
  Future<Me> updateMe(MeUpdate update) async => Me.fromJson(
    _obj(await _dio.patch<dynamic>('/me', data: update.toJson())),
  );

  @override
  Future<TgLink> getTrainerTgLink() async =>
      TgLink.fromJson(_obj(await _dio.get<dynamic>('/me/tg-link')));
}

class StudentRepositoryImpl implements StudentRepository {
  const StudentRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<PagedStudents> list({
    StudentFilter filter = StudentFilter.all,
    String? query,
    int page = 1,
    int limit = 20,
  }) async {
    final Response<dynamic> r = await _dio.get<dynamic>(
      '/students',
      queryParameters: <String, dynamic>{
        'filter': filter.query,
        if (query != null && query.isNotEmpty) 'q': query,
        'page': page,
        'limit': limit,
      },
    );
    return PagedStudents.fromJson(_obj(r));
  }

  @override
  Future<Student> get(String id) async =>
      Student.fromJson(_obj(await _dio.get<dynamic>('/students/$id')));

  @override
  Future<Student> create(StudentCreate body) async => Student.fromJson(
    _obj(await _dio.post<dynamic>('/students', data: body.toJson())),
  );

  @override
  Future<Student> update(String id, StudentUpdate body) async =>
      Student.fromJson(
        _obj(await _dio.patch<dynamic>('/students/$id', data: body.toJson())),
      );

  @override
  Future<Student> archive(String id) async =>
      Student.fromJson(_obj(await _dio.post<dynamic>('/students/$id/archive')));

  @override
  Future<TgLink> inviteLink(String id) async => TgLink.fromJson(
    _obj(await _dio.get<dynamic>('/students/$id/invite-link')),
  );

  @override
  Future<RemindResponse> remind(String id, {RemindRequest? body}) async =>
      RemindResponse.fromJson(
        _obj(
          await _dio.post<dynamic>(
            '/students/$id/remind',
            data: body?.toJson(),
          ),
        ),
      );

  @override
  Future<PagedPayments> payments(
    String id, {
    int page = 1,
    int limit = 20,
  }) async {
    final Response<dynamic> r = await _dio.get<dynamic>(
      '/students/$id/payments',
      queryParameters: <String, dynamic>{'page': page, 'limit': limit},
    );
    return PagedPayments.fromJson(_obj(r));
  }

  @override
  Future<AttendanceList> attendance(
    String id, {
    DateTime? from,
    DateTime? to,
  }) async {
    final Response<dynamic> r = await _dio.get<dynamic>(
      '/students/$id/attendance',
      queryParameters: <String, dynamic>{
        if (from != null) 'from': _date(from),
        if (to != null) 'to': _date(to),
      },
    );
    return AttendanceList.fromJson(_obj(r));
  }

  static String _date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

class PaymentRepositoryImpl implements PaymentRepository {
  const PaymentRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<PaymentCreated> create(
    PaymentCreate body, {
    String? idempotencyKey,
  }) async {
    final Response<dynamic> r = await _dio.post<dynamic>(
      '/payments',
      data: body.toJson(),
      options: Options(
        headers: <String, dynamic>{'Idempotency-Key': ?idempotencyKey},
      ),
    );
    return PaymentCreated.fromJson(_obj(r));
  }
}

class AttendanceRepositoryImpl implements AttendanceRepository {
  const AttendanceRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<AttendanceBulkResponse> markBulk(AttendanceBulkRequest body) async =>
      AttendanceBulkResponse.fromJson(
        _obj(await _dio.post<dynamic>('/attendance/bulk', data: body.toJson())),
      );
}

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<DashboardResponse> get() async =>
      DashboardResponse.fromJson(_obj(await _dio.get<dynamic>('/dashboard')));
}

class StatsRepositoryImpl implements StatsRepository {
  const StatsRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<StatsResponse> get() async =>
      StatsResponse.fromJson(_obj(await _dio.get<dynamic>('/stats')));
}

class TariffRepositoryImpl implements TariffRepository {
  const TariffRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<TariffTemplate>> list({bool includeInactive = false}) async {
    final Response<dynamic> r = await _dio.get<dynamic>(
      '/tariffs',
      queryParameters: <String, dynamic>{'include_inactive': includeInactive},
    );
    return TariffList.fromJson(_obj(r)).items;
  }

  @override
  Future<TariffTemplate> create(TariffCreate body) async =>
      TariffTemplate.fromJson(
        _obj(await _dio.post<dynamic>('/tariffs', data: body.toJson())),
      );

  @override
  Future<TariffTemplate> update(String id, TariffUpdate body) async =>
      TariffTemplate.fromJson(
        _obj(await _dio.patch<dynamic>('/tariffs/$id', data: body.toJson())),
      );
}
