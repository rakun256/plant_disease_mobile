import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DebugApiAlert {
  const DebugApiAlert._();

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void show({
    required int? statusCode,
    required String method,
    required String url,
    required Object? payload,
    bool isError = false,
  }) {
    if (!kDebugMode) {
      return;
    }

    final code = statusCode ?? 0;
    final fullPayload = _stringify(payload);
    final preview = fullPayload.length > 280
        ? '${fullPayload.substring(0, 280)}...'
        : fullPayload;

    debugPrint(
      '[API_DEBUG][$code][$method] $url\nFULL_RESPONSE:\n$fullPayload',
    );

    final messengerState = scaffoldMessengerKey.currentState;
    final context = scaffoldMessengerKey.currentContext;
    if (messengerState == null || context == null) {
      return;
    }

    messengerState
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 8),
          backgroundColor: _colorForStatus(code, isError),
          content: Text(
            '[${code == 0 ? 'NO_CODE' : code}] $method $url\n$preview',
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          action: SnackBarAction(
            label: 'FULL',
            textColor: Colors.white,
            onPressed: () {
              _showFullDialog(
                context: context,
                statusCode: code,
                method: method,
                url: url,
                payload: fullPayload,
                isError: isError,
              );
            },
          ),
        ),
      );
  }

  static void _showFullDialog({
    required BuildContext context,
    required int statusCode,
    required String method,
    required String url,
    required String payload,
    required bool isError,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111111),
          title: Text(
            '[${statusCode == 0 ? 'NO_CODE' : statusCode}] $method',
            style: TextStyle(color: _colorForStatus(statusCode, isError)),
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: SelectableText(
                'URL: $url\n\n$payload',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  static Color _colorForStatus(int statusCode, bool isError) {
    if (statusCode >= 200 && statusCode < 300) {
      return Colors.green.shade700;
    }
    if (statusCode >= 400 && statusCode < 500) {
      return Colors.orange.shade800;
    }
    if (statusCode >= 500 || isError) {
      return Colors.red.shade700;
    }
    return Colors.blueGrey.shade700;
  }

  static String _stringify(Object? payload) {
    if (payload == null) {
      return 'null';
    }

    if (payload is String) {
      return payload;
    }

    try {
      return const JsonEncoder.withIndent('  ').convert(payload);
    } catch (_) {
      return payload.toString();
    }
  }
}
