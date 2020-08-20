import '../../core/services/purchase.service.dart';
import '../../core/models/purchase.model.dart';

class PurchaseController {
  PurchaseService _service = PurchaseService();

  Future<List<PurchaseCount>> getCounts() async {
    return await _service.getCounts().catchError((err) => throw err);
  }
}
