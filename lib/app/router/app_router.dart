import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/logging/app_log.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../features/disease/presentation/disease_detail_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/prediction/model/prediction_response.dart';
import '../../features/prediction/presentation/predict_screen.dart';
import '../../features/prediction/presentation/result_screen.dart';

final _routerRefreshProvider = Provider<RouterRefreshNotifier>((ref) {
  final notifier = RouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(_routerRefreshProvider);
  AppLog.i('ROUTER', 'GoRouter initialized');

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authAsync = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      AppLog.i(
        'ROUTER',
        'redirect() check | location=$location | auth=$authAsync',
      );

      final isBootstrapLoading = authAsync.isLoading && !authAsync.hasValue;

      if (isBootstrapLoading) {
        AppLog.i('ROUTER', 'bootstrap loading -> forcing splash');
        return location == '/splash' ? null : '/splash';
      }

      final status = authAsync.valueOrNull ?? AuthStatus.unauthenticated;
      final isAuthed = status == AuthStatus.authenticated;
      final isAuthRoute =
          location == '/login' ||
          location == '/register' ||
          location == '/splash';
      final isProtected =
          location == '/home' ||
          location == '/predict' ||
          location == '/result' ||
          location == '/history';

      if (location == '/splash') {
        final target = isAuthed ? '/home' : '/login';
        AppLog.i('ROUTER', 'resolved on splash -> $target');
        return target;
      }

      if (!isAuthed && isProtected) {
        AppLog.i('ROUTER', 'unauthenticated on protected route -> /login');
        return '/login';
      }

      if (isAuthed && isAuthRoute) {
        AppLog.i('ROUTER', 'authenticated on auth route -> /home');
        return '/home';
      }

      AppLog.i('ROUTER', 'redirect() no-op');
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/predict',
        builder: (context, state) => const PredictScreen(),
      ),
      GoRoute(
        path: '/result',
        builder: (context, state) {
          final result = state.extra;
          if (result is! PredictionResponse) {
            return const HomeScreen();
          }
          return ResultScreen(prediction: result);
        },
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/disease/:slug',
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          return DiseaseDetailScreen(slug: slug);
        },
      ),
    ],
  );
});

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(this.ref) {
    AppLog.i('ROUTER', 'RouterRefreshNotifier attached');
    ref.listen<AsyncValue<AuthStatus>>(authControllerProvider, (
      previous,
      next,
    ) {
      AppLog.i(
        'ROUTER',
        'authController changed | prev=$previous | next=$next',
      );
      notifyListeners();
    });
  }

  final Ref ref;
}
