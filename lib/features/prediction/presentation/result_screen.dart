import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../model/prediction_response.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.prediction});

  final PredictionResponse prediction;

  @override
  Widget build(BuildContext context) {
    final sortedScores = prediction.scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text('Prediction Result')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('Predicted Class'),
              subtitle: Text(prediction.predictedClass),
              trailing: Text(_asPercent(prediction.confidence)),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Model Version'),
              subtitle: Text(prediction.modelVersion),
            ),
          ),
          if (prediction.warning.isNotEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.warning_amber),
                title: const Text('Warning'),
                subtitle: Text(prediction.warning),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'Scores',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...sortedScores.map(
            (entry) => Card(
              child: ListTile(
                title: Text(entry.key),
                subtitle: LinearProgressIndicator(
                  value: entry.value.clamp(0, 1),
                ),
                trailing: Text(_asPercent(entry.value)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () =>
                context.push('/disease/${prediction.predictedClass}'),
            child: const Text('Open Disease Detail'),
          ),
        ],
      ),
    );
  }

  String _asPercent(double value) {
    final clamped = value.clamp(0, 1);
    final percentage = (clamped * 100).toStringAsFixed(2);
    return '$percentage%';
  }
}
