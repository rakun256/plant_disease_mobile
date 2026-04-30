import '../../prediction/model/prediction_response.dart';

class PredictionHistoryResponse {
  PredictionHistoryResponse({
    required this.id,
    required this.imageName,
    required this.predictedClass,
    required this.confidence,
    this.inferenceTimeMs,
    required this.isLowConfidence,
    required this.modelVersion,
    required this.createdAt,
    required this.scores,
    this.imageQuality,
    this.inputAssessment,
  });

  final int id;
  final String imageName;
  final String predictedClass;
  final double confidence;
  final double? inferenceTimeMs;
  final bool isLowConfidence;
  final String modelVersion;
  final DateTime? createdAt;
  final Map<String, double> scores;
  final ImageQuality? imageQuality;
  final InputAssessment? inputAssessment;

  double get confidencePercent => confidence * 100;
  double? get inferenceTimeSeconds =>
      inferenceTimeMs == null ? null : inferenceTimeMs! / 1000;
  bool get shouldShowPrediction =>
      inputAssessment?.shouldShowPrediction ?? true;
  bool get isReliable =>
      shouldShowPrediction &&
      !isLowConfidence &&
      (imageQuality?.isQualityAcceptable ?? true);

  factory PredictionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return PredictionHistoryResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      imageName: json['image_name'] as String? ?? '',
      predictedClass: json['predicted_class'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      inferenceTimeMs: (json['inference_time_ms'] as num?)?.toDouble(),
      isLowConfidence: json['is_low_confidence'] as bool? ?? false,
      modelVersion: json['model_version'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      scores: parseScores(json['scores']),
      imageQuality: json['image_quality'] is Map<String, dynamic>
          ? ImageQuality.fromJson(json['image_quality'] as Map<String, dynamic>)
          : null,
      inputAssessment: json['input_assessment'] is Map<String, dynamic>
          ? InputAssessment.fromJson(
              json['input_assessment'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

typedef PredictionHistoryItem = PredictionHistoryResponse;
