import 'package:flutter/material.dart';

import '../model/prediction_response.dart';
import 'prediction_detail_widgets.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.prediction});

  final PredictionResponse prediction;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _showRawPrediction = false;

  @override
  Widget build(BuildContext context) {
    final prediction = widget.prediction;
    final shouldShowPrediction = prediction.shouldShowPrediction;
    final showPrediction = shouldShowPrediction || _showRawPrediction;

    return Scaffold(
      appBar: AppBar(title: const Text('Prediction Result')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!shouldShowPrediction) ...[
            InputAssessmentCard(
              assessment: prediction.inputAssessment,
              shouldShowPrediction: false,
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Retake Photo'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        _showRawPrediction = true;
                      });
                    },
                    child: const Text('Show Raw Prediction'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (showPrediction)
            PredictionSummarySection(
              predictedClass: prediction.predictedClass,
              confidence: prediction.confidence,
              scores: prediction.scores,
              modelVersion: prediction.modelVersion,
              inferenceTimeSeconds: prediction.inferenceTimeSeconds,
              warning: prediction.warning,
              isLowConfidence: prediction.isLowConfidence,
              allowDiseaseDetail: shouldShowPrediction || _showRawPrediction,
            ),
          if (!showPrediction)
            const Card(
              child: ListTile(
                title: Text('Raw prediction hidden'),
                subtitle: Text(
                  'Review the warning above before opening the raw model output.',
                ),
              ),
            ),
          const SizedBox(height: 8),
          ImageQualityCard(quality: prediction.imageQuality),
          if (prediction.id != null) ...[
            const SizedBox(height: 8),
            FeedbackSection(predictionId: prediction.id!),
          ],
        ],
      ),
    );
  }
}
