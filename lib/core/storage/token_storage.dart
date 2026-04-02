import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logging/app_log.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return const TokenStorage();
});

class TokenStorage {
  const TokenStorage();

  static const _accessTokenKey = 'access_token';
  static const _tokenTypeKey = 'token_type';

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> saveToken({
    required String accessToken,
    required String tokenType,
  }) async {
    final stopwatch = Stopwatch()..start();
    AppLog.i('STORAGE', 'saveToken() started');
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _tokenTypeKey, value: tokenType);
    AppLog.i(
      'STORAGE',
      'saveToken() completed in ${stopwatch.elapsedMilliseconds}ms',
    );
  }

  Future<String?> readAccessToken() async {
    final stopwatch = Stopwatch()..start();
    AppLog.i('STORAGE', 'readAccessToken() started');
    final token = await _storage.read(key: _accessTokenKey);
    AppLog.i(
      'STORAGE',
      'readAccessToken() completed in ${stopwatch.elapsedMilliseconds}ms | hasToken=${token != null && token.isNotEmpty}',
    );
    return token;
  }

  Future<String?> readTokenType() async {
    final stopwatch = Stopwatch()..start();
    AppLog.i('STORAGE', 'readTokenType() started');
    final tokenType = await _storage.read(key: _tokenTypeKey);
    AppLog.i(
      'STORAGE',
      'readTokenType() completed in ${stopwatch.elapsedMilliseconds}ms',
    );
    return tokenType;
  }

  Future<void> clear() async {
    final stopwatch = Stopwatch()..start();
    AppLog.i('STORAGE', 'clear() started');
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _tokenTypeKey);
    AppLog.i(
      'STORAGE',
      'clear() completed in ${stopwatch.elapsedMilliseconds}ms',
    );
  }
}
