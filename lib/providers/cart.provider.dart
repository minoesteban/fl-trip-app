import 'package:flutter/material.dart';
import 'package:tripit/core/models/cart-item.model.dart';
import '../core/models/place.model.dart';
import '../core/models/trip.model.dart';
import '../core/models/cart.model.dart';

class CartProvider with ChangeNotifier {
  Cart _cart;

  CartProvider() {
    _cart = Cart();
  }

  void addItem(Trip trip, Place place) {
    double price = trip == null ? place.price : trip.price;
    CartItem item = CartItem(trip, place, price);
    _cart.items.add(item);
    notifyListeners();
  }

  void removeItem(String id) {
    _cart.items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void removeItemByInternalId(int tripId, int placeId) {
    if (tripId != null)
      _cart.items.removeWhere((item) => item.isTrip && item.trip?.id == tripId);

    if (placeId != null)
      _cart.items
          .removeWhere((item) => !item.isTrip && item.place?.id == placeId);

    notifyListeners();
  }

  double get total {
    return _cart.items.length > 0
        ? _cart.items.map((e) => e.price).reduce((a, b) => a + b)
        : 0.0;
  }

  List<CartItem> get items {
    return [..._cart.items];
  }
}
