import '../../core/services/rating.service.dart';
import '../../core/models/rating.model.dart';

class RatingController {
  RatingService _service = RatingService();

  Future<List<Rating>> getAllRatings() async {
    return await _service.getAllRatings().catchError((err) => throw err);
  }

  Future<List<Rating>> getRatingsBy(int tripId, int placeId) async {
    return await _service
        .getRatingsBy(tripId, placeId)
        .catchError((err) => throw err);
  }
}
