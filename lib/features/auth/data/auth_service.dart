import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_log.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/dio_provider.dart';
import '../model/token_response.dart';
import '../model/user_create_request.dart';
import '../model/user_response.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthService(dio);
});

class AuthService {
  AuthService(this._dio);

  final Dio _dio;

  Future<UserResponse> register(UserCreateRequest request) async {
    final stopwatch = Stopwatch()..start();
    AppLog.i('AUTH_API', 'register request started');

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/register',
        data: request.toJson(),
      );

      AppLog.i(
        'AUTH_API',
        'register response received in ${stopwatch.elapsedMilliseconds}ms | status=${response.statusCode}',
      );

      final data = response.data ?? <String, dynamic>{};
      return UserResponse.fromJson(data);
    } on DioException catch (error) {
      AppLog.e('AUTH_API', 'register request failed', error, error.stackTrace);
      throw ApiErrorParser.parse(error);
    }
  }

  Future<TokenResponse> login({
    required String username,
    required String password,
  }) async {
    final stopwatch = Stopwatch()..start();
    AppLog.i('AUTH_API', 'login request started for username=$username');

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/login',
        data: {'username': username, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      AppLog.i(
        'AUTH_API',
        'login response received in ${stopwatch.elapsedMilliseconds}ms | status=${response.statusCode}',
      );

      final data = response.data ?? <String, dynamic>{};
      return TokenResponse.fromJson(data);
    } on DioException catch (error) {
      AppLog.e('AUTH_API', 'login request failed', error, error.stackTrace);
      throw ApiErrorParser.parse(error);
    }
  }
}
