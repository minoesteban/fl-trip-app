import 'package:tripit/core/utils/utils.dart';

import 'place.model.dart';
import 'trip.model.dart';

class CartItem {
  String id;
  bool isTrip;
  Trip trip;
  Place place;
  double price;
  DateTime createdAt;

  CartItem(this.trip, this.place, this.price) {
    id = getRandString(20);
    isTrip = trip != null ? true : false;
    createdAt = DateTime.now();
  }
}
