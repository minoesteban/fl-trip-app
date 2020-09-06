import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../core/models/place.model.dart';
import '../../core/utils/utils.dart';

part 'trip.model.g.dart';

@HiveType(typeId: 2)
class Trip {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  int ownerId;
  @HiveField(3)
  String googlePlaceId;
  @HiveField(4)
  String locationName;
  @HiveField(5)
  String countryId;
  @HiveField(6)
  FileOrigin imageOrigin;
  @HiveField(7)
  String imageUrl;
  @HiveField(8)
  FileOrigin audioOrigin;
  @HiveField(9)
  String previewAudioUrl;
  @HiveField(10)
  String languageNameId;
  @HiveField(11)
  String languageFlagId;
  @HiveField(12)
  double price = 0;
  @HiveField(13)
  String about;
  @HiveField(14)
  bool submitted = false;
  @HiveField(15)
  bool published = false;
  @HiveField(16)
  List<Place> places = []; //not in DB model
  @HiveField(17)
  DateTime createdAt;
  @HiveField(18)
  DateTime updatedAt;
  @HiveField(19)
  DateTime deletedAt;
  @HiveField(20)
  bool needSync;
  Trip({
    this.id,
    this.name,
    this.ownerId,
    this.googlePlaceId,
    this.locationName,
    this.countryId,
    this.previewAudioUrl,
    this.languageNameId,
    this.languageFlagId,
    this.price,
    this.about,
    this.submitted,
    this.published,
    this.imageUrl,
    this.places,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  Trip copyWith({
    int id,
    String name,
    int ownerId,
    String googlePlaceId,
    String locationName,
    String countryId,
    String previewAudioUrl,
    String languageNameId,
    String languageFlagId,
    double price,
    String about,
    bool submitted,
    bool published,
    String imageUrl,
    List<Place> places,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime deletedAt,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      googlePlaceId: googlePlaceId ?? this.googlePlaceId,
      locationName: locationName ?? this.locationName,
      countryId: countryId ?? this.countryId,
      previewAudioUrl: previewAudioUrl ?? this.previewAudioUrl,
      languageNameId: languageNameId ?? this.languageNameId,
      languageFlagId: languageFlagId ?? this.languageFlagId,
      price: price ?? this.price,
      about: about ?? this.about,
      submitted: submitted ?? this.submitted,
      published: published ?? this.published,
      imageUrl: imageUrl ?? this.imageUrl,
      places: places ?? this.places,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'googlePlaceId': googlePlaceId,
      'locationName': locationName,
      'countryId': countryId,
      'previewAudioUrl': previewAudioUrl,
      'languageNameId': languageNameId,
      'languageFlagId': languageFlagId,
      'price': price,
      'about': about,
      'submitted': submitted,
      'published': published,
      'imageUrl': imageUrl,
      'places': places?.map((x) => x?.toMap())?.toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
    };
  }

  Map<String, dynamic> toMapForDB() {
    return {
      'name': name,
      'ownerId': ownerId,
      'googlePlaceId': googlePlaceId,
      'locationName': locationName,
      'countryId': countryId,
      'previewAudioUrl': previewAudioUrl,
      'languageNameId': languageNameId,
      'languageFlagId': languageFlagId,
      'price': price,
      'about': about,
      // 'submitted': submitted,
      // 'published': published,
      'imageUrl': imageUrl,
      'Places': places?.map((x) => x?.toMapForDB())?.toList(),
    };
  }

  static Future<Trip> fromMap(Map<String, dynamic> map) async {
    if (map == null) throw HttpException('can\'t parse trip from null map');

    if (map['id'] == null) throw HttpException('no trip id found on map');

    List<Place> _places = [];

    await map['Places']?.forEach((x) => Place.fromMap(x)
        .then((place) => _places.add(place))
        .catchError((err) => throw err));

    return Trip(
      id: map['id'],
      name: map['name'],
      ownerId: map['ownerId'],
      googlePlaceId: map['googlePlaceId'],
      locationName: map['locationName'],
      countryId: map['countryId'],
      previewAudioUrl: map['previewAudioUrl'],
      languageNameId: map['languageNameId'],
      languageFlagId: map['languageFlagId'],
      price: map['price'].toDouble(),
      about: map['about'],
      submitted: map['submitted'],
      published: map['published'],
      imageUrl: map['imageUrl'],
      places: _places,
      createdAt: DateTime.tryParse(map['created_at']),
      updatedAt: DateTime.tryParse(map['updated_at']),
      // deletedAt: DateTime.tryParse(map['deleted_at']),
    );
  }

  String toJson() => json.encode(toMap());

  static Future<Trip> fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'Trip(id: $id, name: $name, ownerId: $ownerId, googlePlaceId: $googlePlaceId, countryId: $countryId, previewAudioUrl: $previewAudioUrl, languageNameId: $languageNameId, languageFlagId: $languageFlagId, price: $price, about: $about, submitted: $submitted, published: $published, imageUrl: $imageUrl, places: $places, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Trip &&
        o.id == id &&
        o.name == name &&
        o.ownerId == ownerId &&
        o.googlePlaceId == googlePlaceId &&
        o.countryId == countryId &&
        o.previewAudioUrl == previewAudioUrl &&
        o.languageNameId == languageNameId &&
        o.languageFlagId == languageFlagId &&
        o.price == price &&
        o.about == about &&
        o.submitted == submitted &&
        o.published == published &&
        o.imageUrl == imageUrl &&
        listEquals(o.places, places) &&
        o.createdAt == createdAt &&
        o.updatedAt == updatedAt &&
        o.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        ownerId.hashCode ^
        googlePlaceId.hashCode ^
        countryId.hashCode ^
        previewAudioUrl.hashCode ^
        languageNameId.hashCode ^
        languageFlagId.hashCode ^
        price.hashCode ^
        about.hashCode ^
        submitted.hashCode ^
        published.hashCode ^
        imageUrl.hashCode ^
        places.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }
}
