import 'package:hive/hive.dart';
import 'package:tripper/core/models/cart-item.model.dart';
import '../utils/utils.dart';

part 'cart.model.g.dart';

@HiveType(typeId: 6)
class Cart {
  @HiveField(0)
  String id;
  @HiveField(1)
  List<CartItem> items;
  @HiveField(2)
  DateTime createdAt;
  @HiveField(3)
  DateTime updatedAt;

  Cart() {
    id = getRandString(10);
    items = [];
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }
}
