import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../common/widgets/app_error_view.dart';
import '../../prediction/model/prediction_response.dart';
import '../../prediction/presentation/prediction_detail_widgets.dart';
import '../state/analytics_controller.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: analyticsAsync.when(
        data: (summary) {
          if (summary.totalPredictions == 0) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No predictions yet.\nUpload a leaf image to see analytics.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(analyticsControllerProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _MetricCard(
                  title: 'Total predictions',
                  value: summary.totalPredictions.toString(),
                ),
                _MetricCard(
                  title: 'Average confidence',
                  value:
                      '${summary.averageConfidencePercent.toStringAsFixed(1)}%',
                ),
                _MetricCard(
                  title: 'Low confidence',
                  value:
                      '${summary.lowConfidenceCount} (${summary.lowConfidenceRatePercent.toStringAsFixed(1)}%)',
                ),
                if (summary.averageInferenceTimeSeconds != null)
                  _MetricCard(
                    title: 'Average inference time',
                    value:
                        '${summary.averageInferenceTimeSeconds!.toStringAsFixed(2)} s',
                  ),
                if (summary.averageImageQualityPercent != null)
                  _MetricCard(
                    title: 'Average image quality',
                    value:
                        '${summary.averageImageQualityPercent!.toStringAsFixed(1)}%',
                  ),
                _MetricCard(
                  title: 'Low quality',
                  value:
                      '${summary.lowQualityCount} (${summary.lowQualityRatePercent.toStringAsFixed(1)}%)',
                ),
                _DistributionCard(
                  title: 'Class distribution',
                  values: summary.classDistribution,
                ),
                if (summary.latestPrediction != null)
                  Card(
                    child: ListTile(
                      title: const Text('Latest prediction'),
                      subtitle: Text(_latestText(summary.latestPrediction!)),
                    ),
                  ),
                _DistributionCard(
                  title: 'Model versions',
                  values: summary.modelVersionDistribution,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(analyticsControllerProvider),
        ),
      ),
    );
  }

  String _latestText(LatestPredictionSummary latest) {
    final date = latest.createdAt == null
        ? '-'
        : DateFormat('yyyy-MM-dd HH:mm').format(latest.createdAt!);
    return '${latest.predictedClass} • ${asPercent(latest.confidence)} • $date';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(title: Text(title), trailing: Text(value)),
    );
  }
}

class _DistributionCard extends StatelessWidget {
  const _DistributionCard({required this.title, required this.values});

  final String title;
  final Map<String, int> values;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final entry in values.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(entry.key)),
                    Text(entry.value.toString()),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
