import 'package:flutter/material.dart';

import 'place-model.dart';
import 'region-model.dart';

class Trip with ChangeNotifier {
  String id;
  String name;
  String description;
  String imageUrl;
  String city;
  String country;
  String placeId;
  String guideId;
  String language = 'EN';
  double price = 0;
  bool purchased = false;
  bool saved = false;
  Region region;
  // double tripRating = 0.0;
  List<Place> places;

  Trip({
    this.price,
    this.name,
    this.description,
    this.imageUrl,
    this.id,
    this.city,
    this.country,
    this.guideId,
    this.language,
    this.placeId,
    this.places,
    this.purchased,
    this.region,
    this.saved,
    // this.tripRating
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    List<Place> placesList = [];
    var list = json['places'] == null ? null : json['places'] as List;
    if (list != null) {
      placesList = list.map((place) => Place.fromJson(place)).toList();
    }

    double getTripRating(List<Place> placesList) {
      return placesList.map((e) => e.rating).reduce((a, b) => a + b) /
          placesList.length;
    }

    return Trip(
      id: json['id'] == null ? null : json['id'],
      price: json['price'] == null ? null : json['price'],
      name: json['name'] == null ? null : json['name'],
      description: json['description'] == null ? null : json['description'],
      imageUrl: json['imageUrl'] == null ? null : json['imageUrl'],
      city: json['city'] == null ? null : json['city'],
      country: json['country'] == null ? null : json['country'],
      guideId: json['guideId'] == null ? null : json['guideId'],
      language: json['language'] == null ? null : json['language'],
      placeId: json['place_id'] == null ? null : json['place_id'],
      places: placesList == null ? null : placesList,
      purchased: json['purchased'] == null ? null : json['purchased'],
      region: json['region'] == null ? null : Region.fromJson(json['region']),
      saved: json['saved'] == null ? null : json['saved'],
      // tripRating: getTripRating(placesList),
    );
  }

  double get tripRating {
    double _res = this.places.map((e) => e.rating).reduce((a, b) => a + b) /
        this.places.length;
    return _res == null ? 0.0 : _res;
  }

  void toggleSaved() {
    saved = !saved;
    notifyListeners();
  }

  void togglePurchased() {
    purchased = !purchased;
    notifyListeners();
  }
}
