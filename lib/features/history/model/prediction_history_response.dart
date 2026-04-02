class PredictionHistoryResponse {
  PredictionHistoryResponse({
    required this.id,
    required this.imageName,
    required this.predictedClass,
    required this.confidence,
    required this.modelVersion,
    required this.createdAt,
    required this.scores,
  });

  final int id;
  final String imageName;
  final String predictedClass;
  final double confidence;
  final String modelVersion;
  final DateTime? createdAt;
  final Map<String, double> scores;

  factory PredictionHistoryResponse.fromJson(Map<String, dynamic> json) {
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

    return PredictionHistoryResponse(
      id: json['id'] as int? ?? 0,
      imageName: json['image_name'] as String? ?? '',
      predictedClass: json['predicted_class'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      modelVersion: json['model_version'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      scores: parsedScores,
    );
  }
}
