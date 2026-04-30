import 'package:flutter_test/flutter_test.dart';
import 'package:plant_disease_mobile/features/disease/model/disease_info_response.dart';
import 'package:plant_disease_mobile/features/history/model/prediction_history_response.dart';
import 'package:plant_disease_mobile/features/prediction/model/prediction_response.dart';

void main() {
  test('PredictionResult parses image quality and input assessment', () {
    final result = PredictionResult.fromJson({
      'model_version': 'resnet50_v1',
      'predicted_class': 'scab',
      'confidence': 0.5155,
      'inference_time_ms': 12301.54,
      'is_low_confidence': true,
      'scores': {'healthy': 0.3895, 'rust': 0.0948, 'scab': 0.5155},
      'supported_classes': ['healthy', 'rust', 'scab'],
      'warning': 'Low confidence',
      'image_quality': {
        'width': 800,
        'height': 800,
        'brightness_score': 197.5,
        'contrast_score': 52.2,
        'blur_score': 21.58,
        'quality_score': 1.0,
        'is_quality_acceptable': true,
        'quality_warnings': [],
      },
      'input_assessment': {
        'is_supported_input_likely': false,
        'should_show_prediction': false,
        'reason_codes': ['LOW_CONFIDENCE'],
        'message': 'Unsupported',
      },
      'explanation': null,
    });

    expect(result.predictedClass, 'scab');
    expect(result.imageQuality?.width, 800);
    expect(result.inputAssessment?.shouldShowPrediction, isFalse);
    expect(result.shouldShowPrediction, isFalse);
    expect(result.inferenceTimeSeconds, closeTo(12.30154, 0.00001));
  });

  test('PredictionResult accepts null metadata', () {
    final result = PredictionResult.fromJson({
      'predicted_class': 'healthy',
      'confidence': 0.8,
      'image_quality': null,
      'input_assessment': null,
    });

    expect(result.imageQuality, isNull);
    expect(result.inputAssessment, isNull);
    expect(result.shouldShowPrediction, isTrue);
  });

  test('History item parses old records with null metadata', () {
    final item = PredictionHistoryItem.fromJson({
      'id': 5,
      'image_name': 'apple.jpg',
      'predicted_class': 'healthy',
      'confidence': 0.8194,
      'inference_time_ms': null,
      'created_at': '2026-04-30T10:00:00Z',
      'image_quality': null,
      'input_assessment': null,
    });

    expect(item.id, 5);
    expect(item.inferenceTimeSeconds, isNull);
    expect(item.shouldShowPrediction, isTrue);
  });

  test('Feedback request omits corrected class when correct', () {
    final body = PredictionFeedbackRequest(
      isCorrect: true,
      correctedClass: 'scab',
      note: 'Correct',
    ).toJson();

    expect(body['is_correct'], isTrue);
    expect(body.containsKey('corrected_class'), isFalse);
  });

  test('Feedback request includes corrected class when incorrect', () {
    final body = PredictionFeedbackRequest(
      isCorrect: false,
      correctedClass: 'scab',
      note: 'Wrong',
    ).toJson();

    expect(body['is_correct'], isFalse);
    expect(body['corrected_class'], 'scab');
  });

  test('AnalyticsSummary parses summary response', () {
    final summary = AnalyticsSummary.fromJson({
      'total_predictions': 5,
      'class_distribution': {'healthy': 1, 'rust': 1, 'scab': 3},
      'average_confidence': 0.8065,
      'low_confidence_count': 1,
      'low_confidence_rate': 0.2,
      'average_inference_time_ms': 10336.69,
      'average_image_quality_score': 0.85,
      'low_quality_count': 1,
      'low_quality_rate': 0.2,
      'latest_prediction': {
        'id': 5,
        'predicted_class': 'healthy',
        'confidence': 0.8194,
        'created_at': '2026-04-30T10:00:00Z',
      },
      'model_version_distribution': {'resnet50_v1': 5},
    });

    expect(summary.totalPredictions, 5);
    expect(summary.classDistribution['scab'], 3);
    expect(summary.averageImageQualityPercent, 85);
    expect(summary.latestPrediction?.predictedClass, 'healthy');
  });

  test('DiseaseInfo parses new detail fields', () {
    final disease = DiseaseInfo.fromJson({
      'name': 'Apple Scab',
      'slug': 'scab',
      'description': 'Description',
      'symptoms': 'Spots',
      'causes': 'Fungus',
      'prevention': 'Prune',
      'severity_level': 'moderate',
      'recommendations': ['Remove leaves'],
      'disclaimer': 'Consult an expert.',
    });

    expect(disease.symptoms, 'Spots');
    expect(disease.causes, 'Fungus');
    expect(disease.prevention, 'Prune');
    expect(disease.severityLevel, 'moderate');
  });
}
