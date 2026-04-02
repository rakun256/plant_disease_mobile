import 'validation_error.dart';

class HttpValidationError {
  HttpValidationError({required this.detail});

  final List<ValidationError> detail;

  factory HttpValidationError.fromJson(Map<String, dynamic> json) {
    final details = (json['detail'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ValidationError.fromJson)
        .toList();

    return HttpValidationError(detail: details);
  }

  Map<String, dynamic> toJson() {
    return {'detail': detail.map((item) => item.toJson()).toList()};
  }
}
