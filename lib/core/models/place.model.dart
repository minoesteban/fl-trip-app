import 'dart:convert';
import 'dart:io';
import 'package:geojson/geojson.dart';
import 'package:hive/hive.dart';
import '../../core/utils/utils.dart';

part 'place.model.g.dart';

@HiveType(typeId: 3)
class Place {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String about;
  @HiveField(3)
  String googlePlaceId;
  @HiveField(4)
  String locationName;
  @HiveField(5)
  Coordinates coordinates;
  @HiveField(6)
  String fullAudioUrl;
  @HiveField(7)
  FileOrigin fullAudioOrigin;
  @HiveField(8)
  String previewAudioUrl;
  @HiveField(9)
  FileOrigin previewAudioOrigin;
  @HiveField(10)
  String imageUrl;
  @HiveField(11)
  FileOrigin imageOrigin;
  @HiveField(12)
  double price = 0;
  @HiveField(13)
  int order = 0;
  @HiveField(14)
  int tripId;
  @HiveField(15)
  double ratingAvg;
  @HiveField(16)
  int ratingCount;
  @HiveField(17)
  DateTime createdAt;
  @HiveField(18)
  DateTime updatedAt;
  @HiveField(19)
  DateTime deletedAt;
  @HiveField(20)
  bool needSync;
  @HiveField(21)
  double fullAudioLength;
  Place({
    this.id,
    this.name,
    this.about,
    this.googlePlaceId,
    this.locationName,
    this.coordinates,
    this.fullAudioUrl,
    this.fullAudioOrigin,
    this.fullAudioLength,
    this.previewAudioUrl,
    this.previewAudioOrigin,
    this.imageUrl,
    this.price,
    this.order,
    this.tripId,
    this.ratingAvg,
    this.ratingCount,
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
    double fullAudioLength,
    String previewAudioUrl,
    FileOrigin previewAudioOrigin,
    String imageUrl,
    double price,
    int order,
    int tripId,
    double ratingAvg,
    int ratingCount,
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
      fullAudioLength: fullAudioLength ?? this.fullAudioLength,
      previewAudioUrl: previewAudioUrl ?? this.previewAudioUrl,
      previewAudioOrigin: previewAudioOrigin ?? this.previewAudioOrigin,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      order: order ?? this.order,
      tripId: tripId ?? this.tripId,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> point;
    if (coordinates != null)
      point = {
        'type': 'Point',
        'coordinates': [coordinates.latitude, coordinates.longitude],
      };

    return {
      'id': id,
      'name': name,
      'about': about,
      'googlePlaceId': googlePlaceId,
      'locationName': locationName,
      'coordinates': point,
      'fullAudioUrl': fullAudioUrl,
      'fullAudioOrigin': fullAudioOrigin,
      'fullAudioLength': fullAudioLength,
      'previewAudioUrl': previewAudioUrl,
      'previewAudioOrigin': previewAudioOrigin,
      'imageUrl': imageUrl,
      'price': price,
      'order': order,
      'tripId': tripId,
      'ratingAvg': ratingAvg,
      'ratingCount': ratingCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
    };
  }

  Map<String, dynamic> toMapForDB() {
    Map<String, dynamic> point;
    if (coordinates != null)
      point = {
        'type': 'Point',
        'coordinates': [coordinates.latitude, coordinates.longitude],
      };

    return {
      'name': name,
      'about': about,
      'googlePlaceId': googlePlaceId,
      'locationName': locationName,
      // 'coordinates': point,
      'coordinates': point,
      'fullAudioUrl': fullAudioUrl,
      'fullAudioLength': fullAudioLength,
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

    int ratingCount = 0;
    double ratingAvg = 0;
    if (map['Ratings'] != null && map['Ratings'].length > 0) {
      ratingCount = map['Ratings'].length;
      var ratingsList =
          map['Ratings'].map((r) => r['rating'].toDouble()).toList();
      ratingAvg = ratingsList.length > 1
          ? ratingsList.reduce((a, b) => a + b).toDouble()
          : ratingsList[0];
      ratingAvg = ratingAvg / ratingCount;
    }

    return Place(
      id: map['id'],
      name: map['name'],
      about: map['about'],
      googlePlaceId: map['googlePlaceId'],
      locationName: map['locationName'],
      coordinates: Coordinates(map['coordinates']['coordinates'][0].toDouble(),
          map['coordinates']['coordinates'][1].toDouble()),
      fullAudioUrl: map['fullAudioUrl'],
      fullAudioOrigin: map['fullAudioOrigin'],
      fullAudioLength: map['fullAudioLength']?.toDouble(),
      previewAudioUrl: map['previewAudioUrl'],
      previewAudioOrigin: map['previewAudioOrigin'],
      imageUrl: map['imageUrl'],
      price: map['price'].toDouble(),
      order: map['order'],
      tripId: map['tripId'],
      ratingAvg: ratingAvg,
      ratingCount: ratingCount,
      createdAt: DateTime.tryParse(map['created_at']),
      updatedAt: DateTime.tryParse(map['updated_at']),
      // deletedAt: DateTime.tryParse(map['deleted_at']),
    );
  }

  String toJson() => json.encode(toMap());

  static Future<Place> fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'Place(id: $id, name: $name, googlePlaceId: $googlePlaceId, coordinates: $coordinates, fullAudioUrl: $fullAudioUrl, fullAudioOrigin: $fullAudioOrigin, previewAudioUrl: $previewAudioUrl, previewAudioOrigin: $previewAudioOrigin, imageUrl: $imageUrl, price: $price, order: $order, tripId: $tripId, ratingAvg: $ratingAvg, ratingCount: $ratingCount, about: $about, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
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
        fullAudioLength == fullAudioLength &&
        o.previewAudioUrl == previewAudioUrl &&
        o.previewAudioOrigin == previewAudioOrigin &&
        o.imageUrl == imageUrl &&
        o.price == price &&
        o.order == order &&
        o.tripId == tripId &&
        o.ratingAvg == ratingAvg &&
        o.ratingCount == ratingCount &&
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
        fullAudioLength.hashCode ^
        previewAudioUrl.hashCode ^
        previewAudioOrigin.hashCode ^
        imageUrl.hashCode ^
        price.hashCode ^
        order.hashCode ^
        tripId.hashCode ^
        ratingAvg.hashCode ^
        ratingCount.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }
}
