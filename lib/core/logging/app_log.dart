import 'package:flutter/foundation.dart';

class AppLog {
  const AppLog._();

  static final DateTime _sessionStart = DateTime.now();

  static void i(String tag, String message) {
    _print('INFO', tag, message);
  }

  static void w(String tag, String message) {
    _print('WARN', tag, message);
  }

  static void e(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    final details = StringBuffer(message);
    if (error != null) {
      details.write(' | error=$error');
    }
    if (stackTrace != null) {
      details.write(' | stack=$stackTrace');
    }
    _print('ERROR', tag, details.toString());
  }

  static void _print(String level, String tag, String message) {
    final now = DateTime.now();
    final elapsed = now.difference(_sessionStart).inMilliseconds;
    final ts = now.toIso8601String();
    debugPrint('[$level][$tag][$ts][+${elapsed}ms] $message');
  }
}
