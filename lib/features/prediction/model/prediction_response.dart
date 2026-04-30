class PredictionResult {
  PredictionResult({
    this.id,
    required this.modelVersion,
    required this.predictedClass,
    required this.confidence,
    this.inferenceTimeMs,
    required this.isLowConfidence,
    required this.scores,
    required this.supportedClasses,
    required this.warning,
    this.imageQuality,
    this.inputAssessment,
    this.explanation,
  });

  final int? id;
  final String modelVersion;
  final String predictedClass;
  final double confidence;
  final double? inferenceTimeMs;
  final bool isLowConfidence;
  final Map<String, double> scores;
  final List<String> supportedClasses;
  final String warning;
  final ImageQuality? imageQuality;
  final InputAssessment? inputAssessment;
  final GradCamExplanation? explanation;

  double get confidencePercent => confidence * 100;
  double? get inferenceTimeSeconds =>
      inferenceTimeMs == null ? null : inferenceTimeMs! / 1000;
  bool get shouldShowPrediction =>
      inputAssessment?.shouldShowPrediction ?? true;
  bool get isReliable =>
      shouldShowPrediction &&
      !isLowConfidence &&
      (imageQuality?.isQualityAcceptable ?? true);

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final supportedRaw =
        json['supported_classes'] as List<dynamic>? ?? const [];

    return PredictionResult(
      id: (json['id'] as num?)?.toInt(),
      modelVersion: json['model_version'] as String? ?? '',
      predictedClass: json['predicted_class'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      inferenceTimeMs: (json['inference_time_ms'] as num?)?.toDouble(),
      isLowConfidence: json['is_low_confidence'] as bool? ?? false,
      scores: parseScores(json['scores']),
      supportedClasses: supportedRaw.map((item) => item.toString()).toList(),
      warning: json['warning'] as String? ?? '',
      imageQuality: json['image_quality'] is Map<String, dynamic>
          ? ImageQuality.fromJson(json['image_quality'] as Map<String, dynamic>)
          : null,
      inputAssessment: json['input_assessment'] is Map<String, dynamic>
          ? InputAssessment.fromJson(
              json['input_assessment'] as Map<String, dynamic>,
            )
          : null,
      explanation: json['explanation'] is Map<String, dynamic>
          ? GradCamExplanation.fromJson(
              json['explanation'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

typedef PredictionResponse = PredictionResult;

Map<String, double> parseScores(Object? scoresRaw) {
  final parsedScores = <String, double>{};
  if (scoresRaw is Map) {
    for (final entry in scoresRaw.entries) {
      final value = entry.value;
      if (value is num) {
        parsedScores[entry.key.toString()] = value.toDouble();
      }
    }
  }
  return parsedScores;
}

class ImageQuality {
  ImageQuality({
    this.width,
    this.height,
    this.brightnessScore,
    this.contrastScore,
    this.blurScore,
    this.qualityScore,
    required this.isQualityAcceptable,
    required this.qualityWarnings,
  });

  final int? width;
  final int? height;
  final double? brightnessScore;
  final double? contrastScore;
  final double? blurScore;
  final double? qualityScore;
  final bool isQualityAcceptable;
  final List<String> qualityWarnings;

  double? get qualityPercent =>
      qualityScore == null ? null : qualityScore!.clamp(0, 1).toDouble() * 100;

  factory ImageQuality.fromJson(Map<String, dynamic> json) {
    final warningsRaw = json['quality_warnings'] as List<dynamic>? ?? const [];
    return ImageQuality(
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      brightnessScore: (json['brightness_score'] as num?)?.toDouble(),
      contrastScore: (json['contrast_score'] as num?)?.toDouble(),
      blurScore: (json['blur_score'] as num?)?.toDouble(),
      qualityScore: (json['quality_score'] as num?)?.toDouble(),
      isQualityAcceptable: json['is_quality_acceptable'] as bool? ?? true,
      qualityWarnings: warningsRaw.map((item) => item.toString()).toList(),
    );
  }
}

class InputAssessment {
  InputAssessment({
    required this.isSupportedInputLikely,
    required this.shouldShowPrediction,
    required this.reasonCodes,
    required this.message,
  });

  final bool isSupportedInputLikely;
  final bool shouldShowPrediction;
  final List<String> reasonCodes;
  final String message;

  factory InputAssessment.fromJson(Map<String, dynamic> json) {
    final reasonsRaw = json['reason_codes'] as List<dynamic>? ?? const [];
    return InputAssessment(
      isSupportedInputLikely:
          json['is_supported_input_likely'] as bool? ?? true,
      shouldShowPrediction: json['should_show_prediction'] as bool? ?? true,
      reasonCodes: reasonsRaw.map((item) => item.toString()).toList(),
      message: json['message'] as String? ?? '',
    );
  }
}

class GradCamExplanation {
  GradCamExplanation({required this.raw});

  final Map<String, dynamic> raw;

  factory GradCamExplanation.fromJson(Map<String, dynamic> json) {
    return GradCamExplanation(raw: json);
  }
}

class PredictionFeedbackRequest {
  PredictionFeedbackRequest({
    required this.isCorrect,
    this.correctedClass,
    this.note,
  });

  final bool isCorrect;
  final String? correctedClass;
  final String? note;

  Map<String, dynamic> toJson() {
    return {
      'is_correct': isCorrect,
      if (!isCorrect && correctedClass != null)
        'corrected_class': correctedClass,
      if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
    };
  }
}

class PredictionFeedbackResponse {
  PredictionFeedbackResponse({
    this.id,
    required this.isCorrect,
    this.correctedClass,
    this.note,
    this.createdAt,
    required this.message,
  });

  final int? id;
  final bool isCorrect;
  final String? correctedClass;
  final String? note;
  final DateTime? createdAt;
  final String message;

  factory PredictionFeedbackResponse.fromJson(Map<String, dynamic> json) {
    return PredictionFeedbackResponse(
      id: (json['id'] as num?)?.toInt(),
      isCorrect: json['is_correct'] as bool? ?? false,
      correctedClass: json['corrected_class'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      message: json['message'] as String? ?? 'Thank you for your feedback.',
    );
  }
}

class LatestPredictionSummary {
  LatestPredictionSummary({
    required this.id,
    required this.predictedClass,
    required this.confidence,
    this.createdAt,
  });

  final int id;
  final String predictedClass;
  final double confidence;
  final DateTime? createdAt;

  double get confidencePercent => confidence * 100;

  factory LatestPredictionSummary.fromJson(Map<String, dynamic> json) {
    return LatestPredictionSummary(
      id: (json['id'] as num?)?.toInt() ?? 0,
      predictedClass: json['predicted_class'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}

class AnalyticsSummary {
  AnalyticsSummary({
    required this.totalPredictions,
    required this.classDistribution,
    required this.averageConfidence,
    required this.lowConfidenceCount,
    required this.lowConfidenceRate,
    this.averageInferenceTimeMs,
    this.averageImageQualityScore,
    required this.lowQualityCount,
    required this.lowQualityRate,
    this.latestPrediction,
    required this.modelVersionDistribution,
  });

  final int totalPredictions;
  final Map<String, int> classDistribution;
  final double averageConfidence;
  final int lowConfidenceCount;
  final double lowConfidenceRate;
  final double? averageInferenceTimeMs;
  final double? averageImageQualityScore;
  final int lowQualityCount;
  final double lowQualityRate;
  final LatestPredictionSummary? latestPrediction;
  final Map<String, int> modelVersionDistribution;

  double get averageConfidencePercent => averageConfidence * 100;
  double get lowConfidenceRatePercent => lowConfidenceRate * 100;
  double? get averageInferenceTimeSeconds =>
      averageInferenceTimeMs == null ? null : averageInferenceTimeMs! / 1000;
  double? get averageImageQualityPercent => averageImageQualityScore == null
      ? null
      : averageImageQualityScore!.clamp(0, 1).toDouble() * 100;
  double get lowQualityRatePercent => lowQualityRate * 100;

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      totalPredictions: (json['total_predictions'] as num?)?.toInt() ?? 0,
      classDistribution: _parseIntMap(json['class_distribution']),
      averageConfidence: (json['average_confidence'] as num?)?.toDouble() ?? 0,
      lowConfidenceCount: (json['low_confidence_count'] as num?)?.toInt() ?? 0,
      lowConfidenceRate: (json['low_confidence_rate'] as num?)?.toDouble() ?? 0,
      averageInferenceTimeMs: (json['average_inference_time_ms'] as num?)
          ?.toDouble(),
      averageImageQualityScore: (json['average_image_quality_score'] as num?)
          ?.toDouble(),
      lowQualityCount: (json['low_quality_count'] as num?)?.toInt() ?? 0,
      lowQualityRate: (json['low_quality_rate'] as num?)?.toDouble() ?? 0,
      latestPrediction: json['latest_prediction'] is Map<String, dynamic>
          ? LatestPredictionSummary.fromJson(
              json['latest_prediction'] as Map<String, dynamic>,
            )
          : null,
      modelVersionDistribution: _parseIntMap(
        json['model_version_distribution'],
      ),
    );
  }

  static Map<String, int> _parseIntMap(Object? raw) {
    final result = <String, int>{};
    if (raw is Map) {
      for (final entry in raw.entries) {
        final value = entry.value;
        if (value is num) {
          result[entry.key.toString()] = value.toInt();
        }
      }
    }
    return result;
  }
}
