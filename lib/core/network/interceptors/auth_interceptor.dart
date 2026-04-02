import 'package:dio/dio.dart';

import '../../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _tokenStorage.readAccessToken();
    final tokenType = await _tokenStorage.readTokenType();

    if (accessToken != null && accessToken.isNotEmpty) {
      final type = (tokenType ?? 'bearer').trim();
      final hasAuthorization = options.headers.containsKey('Authorization');
      if (!hasAuthorization) {
        options.headers['Authorization'] = '${_capitalize(type)} $accessToken';
      }
    }

    handler.next(options);
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }
}
