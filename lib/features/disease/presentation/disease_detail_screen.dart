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
              const SizedBox(height: 8),
              Text('slug: ${disease.slug}'),
              const SizedBox(height: 12),
              Text(
                disease.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              const Text(
                'Recommendations',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...disease.recommendations.map(
                (item) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(item),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(disease.disclaimer),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorView(message: error.toString()),
      ),
    );
  }
}
