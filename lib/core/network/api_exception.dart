import '../../features/common/model/http_validation_error.dart';

class ApiException implements Exception {
  ApiException({required this.message, this.statusCode, this.validationError});

  final String message;
  final int? statusCode;
  final HttpValidationError? validationError;

  @override
  String toString() {
    return 'ApiException(statusCode: $statusCode, message: $message)';
  }
}
