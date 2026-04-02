import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error_parser.dart';
import '../../../core/network/dio_provider.dart';
import '../model/prediction_response.dart';

final predictionServiceProvider = Provider<PredictionService>((ref) {
  final dio = ref.watch(dioProvider);
  return PredictionService(dio);
});

class PredictionService {
  PredictionService(this._dio);

  final Dio _dio;

  Future<PredictionResponse> predictImage({
    required String filePath,
    bool saveResult = true,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'save_result': saveResult,
      });

      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/predictions/',
        data: formData,
      );

      final data = response.data ?? <String, dynamic>{};
      return PredictionResponse.fromJson(data);
    } on DioException catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }
}
