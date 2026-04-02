import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/debug/debug_api_alert.dart';
import '../core/theme/app_theme.dart';
import 'router/app_router.dart';

class PlantDiseaseApp extends ConsumerWidget {
  const PlantDiseaseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Plant Disease Mobile',
      scaffoldMessengerKey: DebugApiAlert.scaffoldMessengerKey,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
