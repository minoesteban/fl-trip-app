import 'poi_model.dart';
import 'region_model.dart';

class Trip {
  String key;
  String name;
  String city;
  String country;
  String placeId;
  String creator;
  String language;
  double price;
  bool purchased;
  bool saved;
  Region region;
  double tripRating;
  List<Poi> pois;

  Trip(
      {this.price,
      this.name,
      this.key,
      this.city,
      this.country,
      this.creator,
      this.language,
      this.placeId,
      this.pois,
      this.purchased,
      this.region,
      this.saved,
      this.tripRating});

  factory Trip.fromJson(Map<String, dynamic> json) {
    List<Poi> poisList = [];
    var list = json['pois'] == null ? null : json['pois'] as List;
    if (list != null) {
      poisList = list.map((poi) => Poi.fromJson(poi)).toList();
    }

    double getTripRating(List<Poi> poisList) {
      double acum = 0.0;
      for (int i = 0; i < poisList.length; i++) {
        acum += poisList[i].rating;
      }
      double avg = acum / poisList.length;
      return avg;
    }

    return Trip(
      key: json['key'] == null ? null : json['key'],
      price: json['price'] == null ? null : json['price'],
      name: json['name'] == null ? null : json['name'],
      city: json['city'] == null ? null : json['city'],
      country: json['country'] == null ? null : json['country'],
      creator: json['creator'] == null ? null : json['creator'],
      language: json['language'] == null ? null : json['language'],
      placeId: json['placeId'] == null ? null : json['placeId'],
      pois: poisList == null ? null : poisList,
      purchased: json['purchased'] == null ? null : json['purchased'],
      region: json['region'] == null ? null : Region.fromJson(json['region']),
      saved: json['saved'] == null ? null : json['saved'],
      tripRating: getTripRating(poisList),
    );
  }
}

//class TripList {
//  List<Trip> trips;
//
//  TripList({this.trips});
//
//  factory TripList.fromJson(List<dynamic> json) {
//    List<Trip> tripList = [];
//    var list = json == null ? null : json;
//    if (list != null) {
//      tripList = list.map((trip) => Trip.fromJson(trip)).toList();
//    }
//
//    return TripList(
//      trips: tripList,
//    );
//  }
//}
