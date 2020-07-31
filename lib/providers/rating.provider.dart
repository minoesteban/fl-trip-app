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

  Future<double> getTripRating(int tripId) async {
    final result = await _controller
        .getRatingsBy(tripId, 0)
        .catchError((err) => throw err);
    return result.map((e) => e.rating).reduce((a, b) => a + b) / result.length;
  }
}
