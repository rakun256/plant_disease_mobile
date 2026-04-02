import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error_parser.dart';
import '../../../core/network/dio_provider.dart';
import '../model/prediction_history_response.dart';

final historyServiceProvider = Provider<HistoryService>((ref) {
  final dio = ref.watch(dioProvider);
  return HistoryService(dio);
});

class HistoryService {
  HistoryService(this._dio);

  final Dio _dio;

  Future<List<PredictionHistoryResponse>> getHistory({
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/api/v1/history/',
        queryParameters: {'skip': skip, 'limit': limit},
      );

      final list = response.data ?? const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(PredictionHistoryResponse.fromJson)
          .toList();
    } on DioException catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }
}
