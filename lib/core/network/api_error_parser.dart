import 'package:dio/dio.dart';

import '../../features/common/model/http_validation_error.dart';
import 'api_exception.dart';

class ApiErrorParser {
  const ApiErrorParser._();

  static ApiException parse(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final responseData = response?.data;

    if (responseData is Map<String, dynamic>) {
      final detail = responseData['detail'];
      if (detail is List) {
        final validation = HttpValidationError.fromJson(responseData);
        final message = validation.detail.isNotEmpty
            ? validation.detail.first.msg
            : 'Validation failed';
        return ApiException(
          message: message,
          statusCode: statusCode,
          validationError: validation,
        );
      }
    }

    final type = error.type;
    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.sendTimeout) {
      return ApiException(
        message: 'Request timed out. Please try again.',
        statusCode: statusCode,
      );
    }

    if (type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'Network error. Check your internet connection.',
        statusCode: statusCode,
      );
    }

    if (statusCode == 401) {
      return ApiException(
        message: 'Unauthorized. Please log in again.',
        statusCode: statusCode,
      );
    }

    return ApiException(
      message: 'Unexpected error occurred.',
      statusCode: statusCode,
    );
  }
}
