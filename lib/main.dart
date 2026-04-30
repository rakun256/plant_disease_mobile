import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'core/logging/app_log.dart';
import 'core/logging/app_provider_observer.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.mist,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

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
