// import 'package:flutter/material.dart';

// import 'place-model.dart';

// class Trip with ChangeNotifier {
//   String id;
//   String name;
//   String about;
//   String pictureUrl;
//   String city;
//   String country;
//   String googlePlaceId;
//   String ownerId;
//   String language = 'EN';
//   double price = 0;
//   bool purchased = false;
//   bool saved = false;
//   // double tripRating = 0.0;
//   List<Place> places;

//   Trip({
//     this.price,
//     this.name,
//     this.about,
//     this.pictureUrl,
//     this.id,
//     this.city,
//     this.country,
//     this.ownerId,
//     this.language,
//     this.googlePlaceId,
//     this.places,
//     this.purchased,
//     this.saved,
//     // this.tripRating
//   });

//   factory Trip.fromJson(Map<String, dynamic> json) {
//     List<Place> placesList = [];
//     var list = json['places'] == null ? null : json['places'] as List;
//     if (list != null) {
//       placesList = list.map((place) => Place.fromJson(place)).toList();
//     }

//     // double getTripRating(List<Place> placesList) {
//     //   return placesList.map((e) => e.rating).reduce((a, b) => a + b) /
//     //       placesList.length;
//     // }

//     return Trip(
//       id: json['id'] == null ? null : json['id'],
//       price: json['price'] == null ? null : json['price'],
//       name: json['name'] == null ? null : json['name'],
//       about: json['about'] == null ? null : json['about'],
//       pictureUrl: json['pictureUrl'] == null ? null : json['pictureUrl'],
//       city: json['city'] == null ? null : json['city'],
//       country: json['countryId'] == null ? null : json['countryId'],
//       ownerId: json['ownerId'] == null ? null : json['ownerId'],
//       language: json['languageFlagId'] == null ? null : json['languageFlagId'],
//       googlePlaceId:
//           json['googlePlaceId'] == null ? null : json['googlePlaceId'],
//       places: placesList == null ? null : placesList,
//       purchased: json['purchased'] == null ? null : json['purchased'],
//       saved: json['saved'] == null ? null : json['saved'],
//       // tripRating: getTripRating(placesList),
//     );
//   }

//   double get tripRating {
//     double _res = this.places.map((e) => e.rating).reduce((a, b) => a + b) /
//         this.places.length;
//     return _res == null ? 0.0 : _res;
//   }

//   void toggleSaved() {
//     saved = !saved;
//     notifyListeners();
//   }

//   void togglePurchased() {
//     purchased = !purchased;
//     notifyListeners();
//   }
// }
