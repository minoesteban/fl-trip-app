import 'package:flutter/material.dart';
import '../core/models/purchase.model.dart';
import '../core/controllers/purchase.controller.dart';

class PurchaseProvider with ChangeNotifier {
  PurchaseController _controller = PurchaseController();
  List<PurchaseCount> _counts;

  Future<List<PurchaseCount>> getCounts() async {
    _counts = await _controller.getCounts().catchError((err) => throw err);
    return [..._counts];
  }

  int getCountBy(int tripId, int placeId) {
    if (placeId == 0) {
      return _counts.where((c) => c.tripId == tripId).first.count;
    }
    return _counts
        .where((c) => c.placeId == placeId || c.tripId == tripId)
        .fold<int>(0, (a, b) => a + b.count);
  }

  List<PurchaseCount> get counts {
    return [..._counts];
  }
}
