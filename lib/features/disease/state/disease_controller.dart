import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/disease_service.dart';
import '../model/disease_info_response.dart';

final diseaseControllerProvider =
    AutoDisposeAsyncNotifierProviderFamily<
      DiseaseController,
      DiseaseInfoResponse,
      String
    >(DiseaseController.new);

class DiseaseController
    extends AutoDisposeFamilyAsyncNotifier<DiseaseInfoResponse, String> {
  @override
  Future<DiseaseInfoResponse> build(String arg) async {
    final service = ref.read(diseaseServiceProvider);
    return service.getDiseaseInfo(arg);
  }
}
