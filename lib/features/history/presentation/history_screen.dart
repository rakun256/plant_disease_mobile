import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../common/widgets/app_error_view.dart';
import '../state/history_controller.dart';
import '../../prediction/presentation/prediction_detail_widgets.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  int _skip = 0;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(historyControllerProvider.notifier)
          .load(skip: _skip, limit: _limit);
    });
  }

  Future<void> _reload() {
    return ref
        .read(historyControllerProvider.notifier)
        .load(skip: _skip, limit: _limit);
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: Text('skip=$_skip, limit=$_limit')),
                IconButton(
                  onPressed: _skip >= _limit
                      ? () {
                          setState(() {
                            _skip -= _limit;
                          });
                          _reload();
                        }
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Previous page',
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _skip += _limit;
                    });
                    _reload();
                  },
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Next page',
                ),
                IconButton(
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          Expanded(
            child: historyAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Center(child: Text('No history found.'));
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final dateText = item.createdAt == null
                        ? '-'
                        : DateFormat(
                            'yyyy-MM-dd HH:mm',
                          ).format(item.createdAt!);

                    final badges = <Widget>[
                      if (item.isLowConfidence)
                        const Chip(label: Text('Low confidence')),
                      if (item.imageQuality?.isQualityAcceptable == false)
                        const Chip(label: Text('Low quality')),
                      if (!item.shouldShowPrediction)
                        const Chip(label: Text('Unreliable')),
                    ];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(item.predictedClass),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${item.imageName}\n$dateText'),
                            if (badges.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(spacing: 6, runSpacing: 6, children: badges),
                            ],
                          ],
                        ),
                        isThreeLine: badges.isNotEmpty,
                        trailing: Text(asPercent(item.confidence)),
                        onTap: () =>
                            context.push('/history/detail', extra: item),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  AppErrorView(message: error.toString(), onRetry: _reload),
            ),
          ),
        ],
      ),
    );
  }
}
