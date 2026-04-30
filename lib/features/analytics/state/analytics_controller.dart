import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../prediction/data/prediction_service.dart';
import '../../prediction/model/prediction_response.dart';

final analyticsControllerProvider = AutoDisposeFutureProvider<AnalyticsSummary>(
  (ref) {
    final service = ref.watch(predictionServiceProvider);
    return service.fetchAnalyticsSummary();
  },
);
