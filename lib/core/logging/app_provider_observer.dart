import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_log.dart';

class AppProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    final providerName = provider.name ?? provider.runtimeType.toString();

    if (newValue is AsyncValue) {
      AppLog.i('PROVIDER', '$providerName -> async state changed: $newValue');
      return;
    }

    if (providerName.contains('authControllerProvider') ||
        providerName.contains('appRouterProvider')) {
      AppLog.i('PROVIDER', '$providerName -> value changed: $newValue');
    }
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    final providerName = provider.name ?? provider.runtimeType.toString();
    AppLog.e('PROVIDER', '$providerName failed', error, stackTrace);
  }
}
