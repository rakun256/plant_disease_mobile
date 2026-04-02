import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/history_service.dart';
import '../model/prediction_history_response.dart';

final historyControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      HistoryController,
      List<PredictionHistoryResponse>
    >(HistoryController.new);

class HistoryController
    extends AutoDisposeAsyncNotifier<List<PredictionHistoryResponse>> {
  int _skip = 0;
  int _limit = 10;

  int get skip => _skip;
  int get limit => _limit;

  @override
  Future<List<PredictionHistoryResponse>> build() async {
    final service = ref.read(historyServiceProvider);
    return service.getHistory(skip: _skip, limit: _limit);
  }

  Future<void> load({int? skip, int? limit}) async {
    _skip = skip ?? _skip;
    _limit = limit ?? _limit;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      final service = ref.read(historyServiceProvider);
      return service.getHistory(skip: _skip, limit: _limit);
    });
  }
}
