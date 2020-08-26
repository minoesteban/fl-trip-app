import 'package:flutter/material.dart';
import '../core/models/rating.model.dart';
import '../core/controllers/rating.controller.dart';

class RatingProvider with ChangeNotifier {
  RatingController _controller = RatingController();

  Future<List<Rating>> getRatingsBy(int tripId, int placeId) async {
    return await _controller
        .getRatingsBy(tripId, placeId)
        .catchError((err) => throw err);
  }
}
