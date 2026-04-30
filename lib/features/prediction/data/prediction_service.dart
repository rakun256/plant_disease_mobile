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
        // Grad-CAM is supported by the backend but disabled in mobile
        // production flow due to Render free-tier memory limits.
        'include_explanation': false,
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

  Future<PredictionFeedbackResponse> submitPredictionFeedback({
    required int predictionId,
    required bool isCorrect,
    String? correctedClass,
    String? note,
  }) async {
    try {
      final request = PredictionFeedbackRequest(
        isCorrect: isCorrect,
        correctedClass: correctedClass,
        note: note,
      );
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/predictions/$predictionId/feedback',
        data: request.toJson(),
      );
      return PredictionFeedbackResponse.fromJson(
        response.data ?? <String, dynamic>{},
      );
    } on DioException catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }

  Future<AnalyticsSummary> fetchAnalyticsSummary() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/analytics/summary',
      );
      return AnalyticsSummary.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }
}
