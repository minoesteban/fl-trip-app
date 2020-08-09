// import 'package:geolocator/geolocator.dart';

// import 'coordinates-model.dart';

// class Place {
//   // String _id;
//   String _name;
//   String _about;
//   int _order = 0;
//   double _rating = 0;
//   String _googlePlaceId;
//   double _price = 0;
//   double _distanceFromUser;
//   String _imageUrl;
//   Coordinates _coordinates;

//   Place(
//       //this._id,
//       [this._name,
//       this._about,
//       this._order,
//       this._googlePlaceId,
//       this._price,
//       this._imageUrl,
//       this._rating,
//       this._coordinates]);

//   factory Place.fromJson(Map<String, dynamic> json) {
//     return Place(
//       // json['id'] == null ? null : json['id'],
//       json['name'] == null ? null : json['name'],
//       json['about'] == null ? null : json['about'],
//       json['order'] == null ? null : json['order'],
//       json['googlePlaceId'] == null ? null : json['googlePlaceId'],
//       json['price'] == null ? null : json['price'],
//       json['imageUrl'] == null ? null : json['imageUrl'],
//       json['rating'] == null ? null : json['rating'],
//       json['coordinates'] == null
//           ? null
//           : Coordinates.fromJson(json['coordinates']),
//     );
//   }

//   void getDistanceFromUser(Position currentPosition) async {
//     await Geolocator()
//         .distanceBetween(
//             this._coordinates.latitude,
//             this._coordinates.longitude,
//             currentPosition.latitude,
//             currentPosition.longitude)
//         .then((value) => this._distanceFromUser = value)
//         .catchError((err) {
//       print(err);
//     });
//   }

//   // String get id {
//   //   return _id;
//   // }

//   String get name {
//     return _name;
//   }

//   // set name(String name) {
//   //   _name = name;
//   // }

//   String get about {
//     return _about;
//   }

//   // set about(String about) {
//   //   _about = about;
//   // }

//   int get order {
//     return _order;
//   }

//   // set order(int order) {
//   //   _order = order;
//   // }

//   String get googlePlaceId {
//     return _googlePlaceId;
//   }

//   // set googlePlaceId(String placeId) {
//   //   _googlePlaceId = placeId;
//   // }

//   double get price {
//     return _price;
//   }

//   // set price(double price) {
//   //   _price = price;
//   // }

//   String get imageUrl {
//     return _imageUrl;
//   }

//   // set imageUrl(String imageUrl) {
//   //   _imageUrl = imageUrl;
//   // }

//   Coordinates get coordinates {
//     return _coordinates;
//   }

//   // set coordinates(Coordinates coordinates) {
//   //   _coordinates = coordinates;
//   // }

//   double get rating {
//     return _rating == null ? 0.0 : _rating;
//   }

//   double get distanceFromUser {
//     return _distanceFromUser;
//   }
// }
