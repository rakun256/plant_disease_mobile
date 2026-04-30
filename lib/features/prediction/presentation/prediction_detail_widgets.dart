import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../data/prediction_service.dart';
import '../model/prediction_response.dart';

const supportedClassOrder = ['healthy', 'rust', 'scab'];

String asPercent(double value, {int decimals = 1}) {
  return '${(value.clamp(0, 1).toDouble() * 100).toStringAsFixed(decimals)}%';
}

String? secondsText(double? seconds) {
  if (seconds == null) {
    return null;
  }
  return '${seconds.toStringAsFixed(2)} s';
}

List<MapEntry<String, double>> stableScores(Map<String, double> scores) {
  final entries = <MapEntry<String, double>>[];
  for (final className in supportedClassOrder) {
    entries.add(MapEntry(className, scores[className] ?? 0));
  }
  for (final entry in scores.entries) {
    if (!supportedClassOrder.contains(entry.key)) {
      entries.add(entry);
    }
  }
  return entries;
}

class PredictionSummarySection extends StatelessWidget {
  const PredictionSummarySection({
    super.key,
    required this.predictedClass,
    required this.confidence,
    required this.scores,
    required this.modelVersion,
    this.inferenceTimeSeconds,
    this.warning,
    this.isLowConfidence = false,
    this.allowDiseaseDetail = true,
  });

  final String predictedClass;
  final double confidence;
  final Map<String, double> scores;
  final String modelVersion;
  final double? inferenceTimeSeconds;
  final String? warning;
  final bool isLowConfidence;
  final bool allowDiseaseDetail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: ListTile(
            title: const Text('Predicted Class'),
            subtitle: Text(predictedClass),
            trailing: Text(asPercent(confidence, decimals: 2)),
          ),
        ),
        if (isLowConfidence && (warning?.isNotEmpty ?? false))
          Card(
            child: ListTile(
              leading: const Icon(Icons.warning_amber_rounded),
              title: const Text('Low confidence'),
              subtitle: Text(warning!),
            ),
          ),
        Card(
          child: ListTile(
            title: const Text('Model Version'),
            subtitle: Text(modelVersion.isEmpty ? '-' : modelVersion),
          ),
        ),
        if (secondsText(inferenceTimeSeconds) case final text?)
          Card(
            child: ListTile(
              title: const Text('Inference time'),
              subtitle: Text(text),
            ),
          ),
        const SizedBox(height: 8),
        const Text(
          'Scores',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...stableScores(scores).map(
          (entry) => Card(
            child: ListTile(
              title: Text(entry.key),
              subtitle: LinearProgressIndicator(
                value: entry.value.clamp(0, 1).toDouble(),
              ),
              trailing: Text(asPercent(entry.value)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: allowDiseaseDetail
              ? () => context.push('/disease/$predictedClass')
              : null,
          child: const Text('Open Disease Detail'),
        ),
      ],
    );
  }
}

class InputAssessmentCard extends StatelessWidget {
  const InputAssessmentCard({
    super.key,
    this.assessment,
    required this.shouldShowPrediction,
  });

  final InputAssessment? assessment;
  final bool shouldShowPrediction;

  @override
  Widget build(BuildContext context) {
    if (shouldShowPrediction && assessment == null) {
      return const SizedBox.shrink();
    }
    final reasons = assessment?.reasonCodes ?? const <String>[];
    return Card(
      color: shouldShowPrediction ? null : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.report_problem_outlined,
                  color: Colors.orange.shade800,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'This image may not be a supported apple leaf image.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              assessment?.message.isNotEmpty == true
                  ? assessment!.message
                  : 'The model is not confident about this prediction. Please upload a clear apple leaf photo for a more reliable result.',
            ),
            if (reasons.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: reasons
                    .map((reason) => Chip(label: Text(reason)))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ImageQualityCard extends StatelessWidget {
  const ImageQualityCard({super.key, required this.quality});

  final ImageQuality? quality;

  @override
  Widget build(BuildContext context) {
    final quality = this.quality;
    if (quality == null) {
      return const Card(
        child: ListTile(
          title: Text('Image Quality'),
          subtitle: Text(
            'Image quality metadata is not available for this prediction.',
          ),
        ),
      );
    }
    final warning = !quality.isQualityAcceptable;
    return Card(
      color: warning ? Colors.orange.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Image Quality',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                Chip(
                  label: Text(
                    quality.isQualityAcceptable ? 'Acceptable' : 'Low quality',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _MetricRow(
              label: 'Quality score',
              value: quality.qualityPercent == null
                  ? '-'
                  : '${quality.qualityPercent!.toStringAsFixed(1)}%',
            ),
            _MetricRow(
              label: 'Resolution',
              value: quality.width == null || quality.height == null
                  ? '-'
                  : '${quality.width} x ${quality.height}',
            ),
            _MetricRow(
              label: 'Brightness',
              value: _numberText(quality.brightnessScore),
            ),
            _MetricRow(
              label: 'Contrast',
              value: _numberText(quality.contrastScore),
            ),
            _MetricRow(label: 'Blur', value: _numberText(quality.blurScore)),
            if (warning) ...[
              const SizedBox(height: 8),
              const Text(
                'The image quality may reduce prediction reliability. Try retaking the photo with better light and focus.',
              ),
            ],
            if (quality.qualityWarnings.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...quality.qualityWarnings.map(
                (item) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.warning_amber_rounded),
                  title: Text(item),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _numberText(double? value) {
    return value == null ? '-' : value.toStringAsFixed(2);
  }
}

class FeedbackSection extends ConsumerStatefulWidget {
  const FeedbackSection({super.key, required this.predictionId});

  final int predictionId;

  @override
  ConsumerState<FeedbackSection> createState() => _FeedbackSectionState();
}

class _FeedbackSectionState extends ConsumerState<FeedbackSection> {
  final _noteController = TextEditingController();
  bool? _isCorrect;
  String? _correctedClass = supportedClassOrder.first;
  bool _submitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit(bool isCorrect) async {
    if (!isCorrect && _correctedClass == null) {
      return;
    }
    setState(() {
      _submitting = true;
      _isCorrect = isCorrect;
    });
    try {
      await ref
          .read(predictionServiceProvider)
          .submitPredictionFeedback(
            predictionId: widget.predictionId,
            isCorrect: isCorrect,
            correctedClass: isCorrect ? null : _correctedClass,
            note: _noteController.text,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _submitted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = error is ApiException ? error.message : error.toString();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.check_circle_outline),
          title: Text('Thank you for your feedback.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Was this prediction correct?',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting ? null : () => _submit(true),
                    child: const Text('Correct'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting
                        ? null
                        : () {
                            setState(() {
                              _isCorrect = false;
                            });
                          },
                    child: const Text('Incorrect'),
                  ),
                ),
              ],
            ),
            if (_isCorrect == false) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _correctedClass,
                decoration: const InputDecoration(labelText: 'Correct class'),
                items: supportedClassOrder
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: _submitting
                    ? null
                    : (value) {
                        setState(() {
                          _correctedClass = value;
                        });
                      },
              ),
            ],
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              enabled: !_submitting,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Optional note',
                alignLabelWithHint: true,
              ),
            ),
            if (_isCorrect == false) ...[
              const SizedBox(height: 10),
              FilledButton(
                onPressed: _submitting ? null : () => _submit(false),
                child: _submitting
                    ? const Text('Submitting...')
                    : const Text('Submit Feedback'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
