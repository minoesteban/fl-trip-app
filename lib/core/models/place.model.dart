import 'dart:convert';

import 'package:geojson/geojson.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Place {
  int id;
  String name;
  String about;
  String googlePlaceId;
  LatLng coordinates;
  String audioUrl;
  String audioPreviewUrl;
  String pictureUrl1;
  String pictureUrl2;
  double price = 0;
  int order = 0;
  int tripId;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime deletedAt;
  Place({
    this.id,
    this.name,
    this.about,
    this.googlePlaceId,
    this.coordinates,
    this.audioUrl,
    this.audioPreviewUrl,
    this.pictureUrl1,
    this.pictureUrl2,
    this.price,
    this.order,
    this.tripId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  Place copyWith({
    int id,
    String name,
    String about,
    String googlePlaceId,
    GeoJsonPoint coordinates,
    String audioUrl,
    String audioPreviewUrl,
    String pictureUrl1,
    String pictureUrl2,
    double price,
    int order,
    int tripId,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime deletedAt,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      about: about ?? this.about,
      googlePlaceId: googlePlaceId ?? this.googlePlaceId,
      coordinates: coordinates ?? this.coordinates,
      audioUrl: audioUrl ?? this.audioUrl,
      audioPreviewUrl: audioPreviewUrl ?? this.audioPreviewUrl,
      pictureUrl1: pictureUrl1 ?? this.pictureUrl1,
      pictureUrl2: pictureUrl2 ?? this.pictureUrl2,
      price: price ?? this.price,
      order: order ?? this.order,
      tripId: tripId ?? this.tripId,
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
      'coordinates': coordinates?.toJson(),
      'audioUrl': audioUrl,
      'audioPreviewUrl': audioPreviewUrl,
      'pictureUrl1': pictureUrl1,
      'pictureUrl2': pictureUrl2,
      'price': price,
      'order': order,
      'tripId': tripId,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'deletedAt': deletedAt?.millisecondsSinceEpoch,
    };
  }

  static Future<Place> fromMap(Map<String, dynamic> map) async {
    if (map == null) return null;

    return Place(
      id: map['id'],
      name: map['name'],
      about: map['about'],
      googlePlaceId: map['googlePlaceId'],
      coordinates: LatLng(map['coordinates']['coordinates'][0],
          map['coordinates']['coordinates'][1]),
      audioUrl: map['audioUrl'],
      audioPreviewUrl: map['audioPreviewUrl'],
      pictureUrl1: map['pictureUrl1'],
      pictureUrl2: map['pictureUrl2'],
      price: map['price'].toDouble(),
      order: map['order'],
      tripId: map['tripId'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      deletedAt: map['deletedAt'],
    );
  }

  String toJson() => json.encode(toMap());

  static Future<Place> fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'Place(id: $id, name: $name, about: $about, googlePlaceId: $googlePlaceId, coordinates: $coordinates, audioUrl: $audioUrl, audioPreviewUrl: $audioPreviewUrl, pictureUrl1: $pictureUrl1, pictureUrl2: $pictureUrl2, price: $price, order: $order, tripId: $tripId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
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
        o.audioUrl == audioUrl &&
        o.audioPreviewUrl == audioPreviewUrl &&
        o.pictureUrl1 == pictureUrl1 &&
        o.pictureUrl2 == pictureUrl2 &&
        o.price == price &&
        o.order == order &&
        o.tripId == tripId &&
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
        audioUrl.hashCode ^
        audioPreviewUrl.hashCode ^
        pictureUrl1.hashCode ^
        pictureUrl2.hashCode ^
        price.hashCode ^
        order.hashCode ^
        tripId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }
}