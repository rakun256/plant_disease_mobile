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
      if (detail is String && detail.isNotEmpty) {
        return ApiException(message: detail, statusCode: statusCode);
      }
      final message = responseData['message'];
      if (message is String && message.isNotEmpty) {
        return ApiException(message: message, statusCode: statusCode);
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
    if (statusCode == 403) {
      return ApiException(
        message: 'You do not have permission to perform this action.',
        statusCode: statusCode,
      );
    }
    if (statusCode == 404) {
      return ApiException(
        message: 'The requested item was not found.',
        statusCode: statusCode,
      );
    }
    if (statusCode == 409) {
      return ApiException(
        message: 'Feedback has already been submitted for this prediction.',
        statusCode: statusCode,
      );
    }
    if (statusCode == 422) {
      return ApiException(
        message: 'Please check the submitted information.',
        statusCode: statusCode,
      );
    }
    if (statusCode != null && statusCode >= 500) {
      return ApiException(
        message: 'Server error. Please try again later.',
        statusCode: statusCode,
      );
    }

    return ApiException(
      message: 'Unexpected error occurred.',
      statusCode: statusCode,
    );
  }
}
