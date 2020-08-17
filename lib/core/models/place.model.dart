import 'dart:convert';
import 'dart:io';
import 'package:geojson/geojson.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/utils/utils.dart';
import '../../core/models/rating.model.dart';

class Place {
  int id;
  String name;
  String about;
  String googlePlaceId;
  String locationName;
  LatLng coordinates;
  String fullAudioUrl;
  FileOrigin fullAudioOrigin;
  String previewAudioUrl;
  FileOrigin previewAudioOrigin;
  String imageUrl;
  FileOrigin imageOrigin;
  double price = 0;
  int order = 0;
  int tripId;
  Rating rating;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime deletedAt;
  Place({
    this.id,
    this.name,
    this.about,
    this.googlePlaceId,
    this.locationName,
    this.coordinates,
    this.fullAudioUrl,
    this.fullAudioOrigin,
    this.previewAudioUrl,
    this.previewAudioOrigin,
    this.imageUrl,
    this.price,
    this.order,
    this.tripId,
    this.rating,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  Place copyWith({
    int id,
    String name,
    String about,
    String googlePlaceId,
    String locationName,
    GeoJsonPoint coordinates,
    String fullAudioUrl,
    FileOrigin fullAudioOrigin,
    String previewAudioUrl,
    FileOrigin previewAudioOrigin,
    String imageUrl,
    double price,
    int order,
    int tripId,
    Rating rating,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime deletedAt,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      about: about ?? this.about,
      googlePlaceId: googlePlaceId ?? this.googlePlaceId,
      locationName: locationName ?? this.locationName,
      coordinates: coordinates ?? this.coordinates,
      fullAudioUrl: fullAudioUrl ?? this.fullAudioUrl,
      fullAudioOrigin: fullAudioOrigin ?? this.fullAudioOrigin,
      previewAudioUrl: previewAudioUrl ?? this.previewAudioUrl,
      previewAudioOrigin: previewAudioOrigin ?? this.previewAudioOrigin,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      order: order ?? this.order,
      tripId: tripId ?? this.tripId,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'about': about,
      'googlePlaceId': googlePlaceId,
      'locationName': locationName,
      'coordinates': coordinates?.toJson(),
      'fullAudioUrl': fullAudioUrl,
      'fullAudioOrigin': fullAudioOrigin,
      'previewAudioUrl': previewAudioUrl,
      'previewAudioOrigin': previewAudioOrigin,
      'imageUrl': imageUrl,
      'price': price,
      'order': order,
      'tripId': tripId,
      'rating': rating,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
    };
  }

  Map<String, dynamic> toMapForDB() {
    String point;
    if (coordinates != null)
      point = json.encode({
        'type': 'Point',
        'coordinates': coordinates?.toJson(),
      });

    return {
      'name': name,
      'about': about,
      'googlePlaceId': googlePlaceId,
      'locationName': locationName,
      'coordinates': point,
      'fullAudioUrl': fullAudioUrl,
      'previewAudioUrl': previewAudioUrl,
      'imageUrl': imageUrl,
      'price': price,
      'order': order,
      'tripId': tripId ?? 0,
    };
  }

  static Future<Place> fromMap(Map<String, dynamic> map) async {
    if (map == null) throw HttpException('can\'t parse place from null map');

    if (map['id'] == null) throw HttpException('no place id found on map');

    return Place(
      id: map['id'],
      name: map['name'],
      about: map['about'],
      googlePlaceId: map['googlePlaceId'],
      locationName: map['locationName'],
      coordinates: LatLng(map['coordinates']['coordinates'][0].toDouble(),
          map['coordinates']['coordinates'][1].toDouble()),
      fullAudioUrl: map['fullAudioUrl'],
      fullAudioOrigin: map['fullAudioOrigin'],
      previewAudioUrl: map['previewAudioUrl'],
      previewAudioOrigin: map['previewAudioOrigin'],
      imageUrl: map['imageUrl'],
      price: map['price'].toDouble(),
      order: map['order'],
      tripId: map['tripId'],
      rating: map['rating'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      deletedAt: map['deletedAt'],
    );
  }

  String toJson() => json.encode(toMap());

  static Future<Place> fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'Place(id: $id, name: $name, about: $about, googlePlaceId: $googlePlaceId, coordinates: $coordinates, fullAudioUrl: $fullAudioUrl, fullAudioOrigin: $fullAudioOrigin, previewAudioUrl: $previewAudioUrl, previewAudioOrigin: $previewAudioOrigin, imageUrl: $imageUrl, price: $price, order: $order, tripId: $tripId, rating: $rating, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Place &&
        o.id == id &&
        o.name == name &&
        o.about == about &&
        o.googlePlaceId == googlePlaceId &&
        o.coordinates == coordinates &&
        o.fullAudioUrl == fullAudioUrl &&
        o.fullAudioOrigin == fullAudioOrigin &&
        o.previewAudioUrl == previewAudioUrl &&
        o.previewAudioOrigin == previewAudioOrigin &&
        o.imageUrl == imageUrl &&
        o.price == price &&
        o.order == order &&
        o.tripId == tripId &&
        o.rating == rating &&
        o.createdAt == createdAt &&
        o.updatedAt == updatedAt &&
        o.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        about.hashCode ^
        googlePlaceId.hashCode ^
        coordinates.hashCode ^
        fullAudioUrl.hashCode ^
        fullAudioOrigin.hashCode ^
        previewAudioUrl.hashCode ^
        previewAudioOrigin.hashCode ^
        imageUrl.hashCode ^
        price.hashCode ^
        order.hashCode ^
        tripId.hashCode ^
        rating.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }
}
