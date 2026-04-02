class PredictionResponse {
  PredictionResponse({
    required this.modelVersion,
    required this.predictedClass,
    required this.confidence,
    required this.scores,
    required this.supportedClasses,
    required this.warning,
  });

  final String modelVersion;
  final String predictedClass;
  final double confidence;
  final Map<String, double> scores;
  final List<String> supportedClasses;
  final String warning;

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    final scoresRaw = json['scores'];
    final parsedScores = <String, double>{};
    if (scoresRaw is Map) {
      for (final entry in scoresRaw.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (value is num) {
          parsedScores[key] = value.toDouble();
        }
      }
    }

    final supportedRaw =
        json['supported_classes'] as List<dynamic>? ?? const [];

    return PredictionResponse(
      modelVersion: json['model_version'] as String? ?? '',
      predictedClass: json['predicted_class'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      scores: parsedScores,
      supportedClasses: supportedRaw.map((item) => item.toString()).toList(),
      warning: json['warning'] as String? ?? '',
    );
  }
}
