import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/logging/app_log.dart';
import 'core/logging/app_provider_observer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    AppLog.e(
      'FLUTTER',
      'FlutterError.onError captured',
      details.exception,
      details.stack,
    );
    FlutterError.presentError(details);
  };

  AppLog.i('MAIN', 'Application bootstrap started');

  runApp(
    ProviderScope(
      observers: [AppProviderObserver()],
      child: const PlantDiseaseApp(),
    ),
  );

  AppLog.i('MAIN', 'runApp completed');
}
