import 'package:flutter/material.dart';

import '../../../core/logging/app_log.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final Stopwatch _watch;

  @override
  void initState() {
    super.initState();
    _watch = Stopwatch()..start();
    AppLog.i('SPLASH', 'SplashScreen initState');
    _heartbeat();
  }

  void _heartbeat() {
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }

      AppLog.w(
        'SPLASH',
        'Still on splash after ${_watch.elapsedMilliseconds}ms',
      );

      _heartbeat();
    });
  }

  @override
  void dispose() {
    AppLog.i(
      'SPLASH',
      'SplashScreen dispose after ${_watch.elapsedMilliseconds}ms',
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Initializing... check debug logs'),
          ],
        ),
      ),
    );
  }
}
