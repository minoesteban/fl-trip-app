import 'package:tripit/core/services/trip.service.dart';

import '../models/trip.model.dart';

class TripController {
  TripService _service = TripService();

  Future<List<Trip>> getAllTrips() async {
    return await _service.getAllTrips();
  }
}
