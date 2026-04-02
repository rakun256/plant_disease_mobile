import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_log.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_service.dart';
import '../model/user_create_request.dart';

enum AuthStatus { authenticated, unauthenticated }

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthStatus>(AuthController.new);

class AuthController extends AsyncNotifier<AuthStatus> {
  @override
  Future<AuthStatus> build() async {
    final stopwatch = Stopwatch()..start();
    AppLog.i('AUTH', 'build() started');

    final tokenStorage = ref.watch(tokenStorageProvider);

    try {
      AppLog.i('AUTH', 'Attempting access token read');
      final token = await tokenStorage.readAccessToken().timeout(
        const Duration(seconds: 5),
      );
      AppLog.i(
        'AUTH',
        'Token read completed. hasToken=${token != null && token.isNotEmpty}',
      );

      if (token != null && token.isNotEmpty) {
        AppLog.i(
          'AUTH',
          'Resolved authenticated in ${stopwatch.elapsedMilliseconds}ms',
        );
        return AuthStatus.authenticated;
      }
    } catch (error) {
      AppLog.w('AUTH', 'Bootstrap fallback to unauthenticated due to: $error');
    }

    AppLog.i(
      'AUTH',
      'Resolved unauthenticated in ${stopwatch.elapsedMilliseconds}ms',
    );
    return AuthStatus.unauthenticated;
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    AppLog.i('AUTH', 'login() started for username=$username');
    state = const AsyncLoading();

    final authService = ref.read(authServiceProvider);
    final tokenStorage = ref.read(tokenStorageProvider);

    try {
      final token = await authService.login(
        username: username,
        password: password,
      );

      AppLog.i('AUTH', 'login() token received. tokenType=${token.tokenType}');

      await tokenStorage.saveToken(
        accessToken: token.accessToken,
        tokenType: token.tokenType,
      );

      AppLog.i('AUTH', 'login() token saved, switching state to authenticated');

      state = const AsyncData(AuthStatus.authenticated);
    } catch (error, stackTrace) {
      AppLog.e('AUTH', 'login() failed', error, stackTrace);
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    AppLog.i('AUTH', 'register() started for email=$email');
    final authService = ref.read(authServiceProvider);
    try {
      await authService.register(
        UserCreateRequest(email: email, password: password, fullName: fullName),
      );
      AppLog.i('AUTH', 'register() succeeded');
    } catch (error, stackTrace) {
      AppLog.e('AUTH', 'register() failed', error, stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    AppLog.i('AUTH', 'logout() started');
    final tokenStorage = ref.read(tokenStorageProvider);
    await tokenStorage.clear();
    AppLog.i(
      'AUTH',
      'logout() token cleared, switching state to unauthenticated',
    );
    state = const AsyncData(AuthStatus.unauthenticated);
  }
}
