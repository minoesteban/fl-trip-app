import '../../core/services/rating.service.dart';
import '../../core/models/rating.model.dart';

class RatingController {
  Future<List<Rating>> getAllRatings() async {
    return await RatingService().getAllRatings().catchError((err) => throw err);
  }

  Future<List<Rating>> getRatingsBy(int tripId, int placeId) async {
    return await RatingService()
        .getRatingsBy(tripId, placeId)
        .catchError((err) => throw err);
  }
}
