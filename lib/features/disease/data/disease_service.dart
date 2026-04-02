import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error_parser.dart';
import '../../../core/network/dio_provider.dart';
import '../model/disease_info_response.dart';

final diseaseServiceProvider = Provider<DiseaseService>((ref) {
  final dio = ref.watch(dioProvider);
  return DiseaseService(dio);
});

class DiseaseService {
  DiseaseService(this._dio);

  final Dio _dio;

  Future<DiseaseInfoResponse> getDiseaseInfo(String slug) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/diseases/$slug',
      );
      final data = response.data ?? <String, dynamic>{};
      return DiseaseInfoResponse.fromJson(data);
    } on DioException catch (error) {
      throw ApiErrorParser.parse(error);
    }
  }
}
