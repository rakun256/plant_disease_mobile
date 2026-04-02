import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/widgets/loading_overlay.dart';
import '../state/prediction_controller.dart';

class PredictScreen extends ConsumerStatefulWidget {
  const PredictScreen({super.key});

  @override
  ConsumerState<PredictScreen> createState() => _PredictScreenState();
}

class _PredictScreenState extends ConsumerState<PredictScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _picked;
  bool _saveResult = true;

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 92);

    if (!mounted) {
      return;
    }

    setState(() {
      _picked = file;
    });
  }

  Future<void> _predict() async {
    final picked = _picked;
    if (picked == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }

    try {
      final result = await ref
          .read(predictionControllerProvider.notifier)
          .predict(filePath: picked.path, saveResult: _saveResult);

      if (!mounted) {
        return;
      }

      context.push('/result', extra: result);
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final predictionAsync = ref.watch(predictionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Predict')),
      body: LoadingOverlay(
        isLoading: predictionAsync.isLoading,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_picked != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_picked!.path),
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: const Center(child: Text('No image selected')),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: predictionAsync.isLoading
                          ? null
                          : () => _pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: predictionAsync.isLoading
                          ? null
                          : () => _pick(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Camera'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _saveResult,
                onChanged: predictionAsync.isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _saveResult = value;
                        });
                      },
                title: const Text('Save result to history'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: predictionAsync.isLoading ? null : _predict,
                child: const Text('Run Prediction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
