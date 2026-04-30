import 'package:flutter/material.dart';

import '../../prediction/presentation/prediction_detail_widgets.dart';
import '../model/prediction_history_response.dart';

class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({super.key, required this.item});

  final PredictionHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!item.shouldShowPrediction)
            InputAssessmentCard(
              assessment: item.inputAssessment,
              shouldShowPrediction: false,
            ),
          PredictionSummarySection(
            predictedClass: item.predictedClass,
            confidence: item.confidence,
            scores: item.scores,
            modelVersion: item.modelVersion,
            inferenceTimeSeconds: item.inferenceTimeSeconds,
            isLowConfidence: item.isLowConfidence,
            warning: item.isLowConfidence
                ? 'The model confidence is low. Please review this result carefully.'
                : null,
          ),
          const SizedBox(height: 8),
          ImageQualityCard(quality: item.imageQuality),
          const SizedBox(height: 8),
          FeedbackSection(predictionId: item.id),
        ],
      ),
    );
  }
}
