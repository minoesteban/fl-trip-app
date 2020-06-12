import 'package:geolocator/geolocator.dart';
import 'package:tripit/models/trip_model.dart';

import 'coordinates_model.dart';

class Poi {
  String key;
  String name;
  int order;
  double rating;
  String placeId;
  double price;
  double distanceFromUser;
  Coordinates coordinates;

  Poi(
      {this.coordinates,
      this.key,
      this.name,
      this.order,
      this.placeId,
      this.price,
      this.rating});

  factory Poi.fromJson(Map<String, dynamic> json) {
    return Poi(
      key: json['key'] == null ? null : json['key'],
      name: json['name'] == null ? null : json['name'],
      order: json['order'] == null ? null : json['order'],
      placeId: json['place_id'] == null ? null : json['place_id'],
      price: json['price'] == null ? null : json['price'],
      rating: json['rating'] == null ? null : json['rating'],
      coordinates: json['coordinates'] == null
          ? null
          : Coordinates.fromJson(json['coordinates']),
    );
  }

  void getDistanceFromUser(Position currentPosition) async {
    await Geolocator()
        .distanceBetween(this.coordinates.latitude, this.coordinates.longitude,
            currentPosition.latitude, currentPosition.longitude)
        .then((value) => this.distanceFromUser = value)
        .catchError((err) {
      print(err);
    });
  }
}

class PoiAndTrip {
  Poi poi;
  Trip trip;

  PoiAndTrip({this.trip, this.poi});
}
