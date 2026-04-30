import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/widgets/app_error_view.dart';
import '../state/disease_controller.dart';

class DiseaseDetailScreen extends ConsumerWidget {
  const DiseaseDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diseaseAsync = ref.watch(diseaseControllerProvider(slug));

    return Scaffold(
      appBar: AppBar(title: const Text('Disease Detail')),
      body: diseaseAsync.when(
        data: (disease) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                disease.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (disease.severityLevel?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    label: Text('Severity: ${disease.severityLevel}'),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                disease.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              _InfoSection(title: 'Symptoms', body: disease.symptoms),
              _InfoSection(title: 'Causes', body: disease.causes),
              _InfoSection(title: 'Prevention', body: disease.prevention),
              const SizedBox(height: 16),
              if (disease.recommendations.isNotEmpty) ...[
                const Text(
                  'Recommendations',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...disease.recommendations.map(
                  (item) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(item),
                    ),
                  ),
                ),
              ],
              if (disease.disclaimer.isNotEmpty) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(disease.disclaimer),
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorView(message: error.toString()),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.body});

  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    if (body == null || body!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(body!),
        ],
      ),
    );
  }
}
