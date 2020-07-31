import 'package:tripit/core/models/cart-item.model.dart';

import '../../core/utils/utils.dart';

class Cart {
  String id;
  List<CartItem> items;
  DateTime createdAt;
  DateTime updatedAt;

  Cart() {
    id = getRandString(10);
    items = [];
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }
}
