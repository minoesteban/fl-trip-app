import 'package:geolocator/geolocator.dart';

import '../geo/coordinates-model.dart';

class Place {
  String _id;
  String _name;
  String _description;
  int _order = 0;
  double _rating = 0;
  String _placeId;
  double _price = 0;
  double _distanceFromUser;
  String _imageUrl;
  Coordinates _coordinates;

  Place(this._id,
      [this._name,
      this._description,
      this._order,
      this._placeId,
      this._price,
      this._imageUrl,
      this._rating,
      this._coordinates]);

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      json['id'] == null ? null : json['id'],
      json['name'] == null ? null : json['name'],
      json['description'] == null ? null : json['description'],
      json['order'] == null ? null : json['order'],
      json['place_id'] == null ? null : json['place_id'],
      json['price'] == null ? null : json['price'],
      json['imageUrl'] == null ? null : json['imageUrl'],
      json['rating'] == null ? null : json['rating'],
      json['coordinates'] == null
          ? null
          : Coordinates.fromJson(json['coordinates']),
    );
  }

  void getDistanceFromUser(Position currentPosition) async {
    await Geolocator()
        .distanceBetween(
            this._coordinates.latitude,
            this._coordinates.longitude,
            currentPosition.latitude,
            currentPosition.longitude)
        .then((value) => this._distanceFromUser = value)
        .catchError((err) {
      print(err);
    });
  }

  String get id {
    return _id;
  }

  String get name {
    return _name;
  }

  set name(String name) {
    _name = name;
  }

  String get description {
    return _description;
  }

  set description(String description) {
    _description = description;
  }

  int get order {
    return _order;
  }

  set order(int order) {
    _order = order;
  }

  String get placeId {
    return _placeId;
  }

  set placeId(String placeId) {
    _placeId = placeId;
  }

  double get price {
    return _price;
  }

  set price(double price) {
    _price = price;
  }

  String get imageUrl {
    return _imageUrl;
  }

  set imageUrl(String imageUrl) {
    _imageUrl = imageUrl;
  }

  Coordinates get coordinates {
    return _coordinates;
  }

  set coordinates(Coordinates coordinates) {
    _coordinates = coordinates;
  }

  double get rating {
    print(_rating);
    return _rating == null ? 0.0 : _rating;
  }

  double get distanceFromUser {
    return _distanceFromUser;
  }
}
