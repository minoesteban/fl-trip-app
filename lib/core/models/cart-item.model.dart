import 'package:hive/hive.dart';
import 'package:tripit/core/utils/utils.dart';
import 'place.model.dart';
import 'trip.model.dart';

part 'cart-item.model.g.dart';

@HiveType(typeId: 7)
class CartItem {
  @HiveField(0)
  String id;
  @HiveField(1)
  bool isTrip;
  @HiveField(2)
  Trip trip;
  @HiveField(3)
  Place place;
  @HiveField(4)
  double price;
  @HiveField(5)
  DateTime createdAt;

  CartItem(this.trip, this.place, this.price) {
    id = getRandString(20);
    isTrip = trip != null ? true : false;
    createdAt = DateTime.now();
  }
}
