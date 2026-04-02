import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../debug/debug_api_alert.dart';
import '../storage/token_storage.dart';
import 'interceptors/auth_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: const {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(AuthInterceptor(tokenStorage));
  dio.interceptors.add(
    InterceptorsWrapper(
      onResponse: (response, handler) {
        final request = response.requestOptions;
        DebugApiAlert.show(
          statusCode: response.statusCode,
          method: request.method,
          url: request.uri.toString(),
          payload: response.data,
        );
        handler.next(response);
      },
      onError: (error, handler) {
        final request = error.requestOptions;
        DebugApiAlert.show(
          statusCode: error.response?.statusCode,
          method: request.method,
          url: request.uri.toString(),
          payload: error.response?.data ?? error.message,
          isError: true,
        );
        handler.next(error);
      },
    ),
  );
  dio.interceptors.add(
    LogInterceptor(
      requestBody: false,
      responseBody: false,
      requestHeader: false,
      responseHeader: false,
    ),
  );

  return dio;
});
