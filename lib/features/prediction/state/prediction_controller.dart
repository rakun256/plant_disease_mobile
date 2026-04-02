import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/prediction_service.dart';
import '../model/prediction_response.dart';

final predictionControllerProvider =
    AutoDisposeAsyncNotifierProvider<PredictionController, PredictionResponse?>(
      PredictionController.new,
    );

class PredictionController
    extends AutoDisposeAsyncNotifier<PredictionResponse?> {
  @override
  Future<PredictionResponse?> build() async {
    return null;
  }

  Future<PredictionResponse> predict({
    required String filePath,
    bool saveResult = true,
  }) async {
    state = const AsyncLoading();
    final service = ref.read(predictionServiceProvider);

    try {
      final result = await service.predictImage(
        filePath: filePath,
        saveResult: saveResult,
      );
      state = AsyncData(result);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
