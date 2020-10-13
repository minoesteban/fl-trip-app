import 'package:flutter/material.dart';
import '../core/models/purchase.model.dart';
import '../core/controllers/purchase.controller.dart';

class PurchaseProvider with ChangeNotifier {
  PurchaseController _controller = PurchaseController();
  List<PurchaseCount> _counts;

  // PurchaseProvider() {
  //   getCounts().then((v) => print('purchaseprovider init'));
  // }

  Future<void> getCounts() async {
    _counts = await _controller.getCounts().catchError((err) => throw err);
  }

  int getCountBy(int tripId, int placeId) {
    if (placeId == 0) {
      return _counts
          .firstWhere((c) => c.tripId == tripId,
              orElse: () => PurchaseCount(count: 0))
          .count;
    }
    return _counts
        .where((c) => c.placeId == placeId || c.tripId == tripId)
        .fold<int>(0, (a, b) => a + b.count);
  }

  List<PurchaseCount> get counts {
    return [..._counts];
  }
}
