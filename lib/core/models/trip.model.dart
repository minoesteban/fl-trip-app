import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:tripit/core/models/place.model.dart';

class Trip {
  int id;
  String name;
  int ownerId;
  String googlePlaceId;
  String countryId;
  String previewAudioUrl;
  String languageNameId;
  String languageFlagId;
  double price = 0;
  String about;
  bool submitted = false;
  bool published = false;
  String pictureUrl;
  List<Place> places;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime deletedAt;
  Trip({
    this.id,
    this.name,
    this.ownerId,
    this.googlePlaceId,
    this.countryId,
    this.previewAudioUrl,
    this.languageNameId,
    this.languageFlagId,
    this.price,
    this.about,
    this.submitted,
    this.published,
    this.pictureUrl,
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
    String countryId,
    String previewAudioUrl,
    String languageNameId,
    String languageFlagId,
    double price,
    String about,
    bool submitted,
    bool published,
    String pictureUrl,
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
      countryId: countryId ?? this.countryId,
      previewAudioUrl: previewAudioUrl ?? this.previewAudioUrl,
      languageNameId: languageNameId ?? this.languageNameId,
      languageFlagId: languageFlagId ?? this.languageFlagId,
      price: price ?? this.price,
      about: about ?? this.about,
      submitted: submitted ?? this.submitted,
      published: published ?? this.published,
      pictureUrl: pictureUrl ?? this.pictureUrl,
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
      'countryId': countryId,
      'previewAudioUrl': previewAudioUrl,
      'languageNameId': languageNameId,
      'languageFlagId': languageFlagId,
      'price': price,
      'about': about,
      'submitted': submitted,
      'published': published,
      'pictureUrl': pictureUrl,
      'places': places?.map((x) => x?.toMap())?.toList(),
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'deletedAt': deletedAt?.millisecondsSinceEpoch,
    };
  }

  static Future<Trip> fromMap(Map<String, dynamic> map) async {
    if (map == null) return null;

    List<Place> _places = [];

    await map['Places']
        ?.forEach((x) => Place.fromMap(x).then((place) => _places.add(place)));

    return Trip(
      id: map['id'],
      name: map['name'],
      ownerId: map['ownerId'],
      googlePlaceId: map['googlePlaceId'],
      countryId: map['countryId'],
      previewAudioUrl: map['previewAudioUrl'],
      languageNameId: map['languageNameId'],
      languageFlagId: map['languageFlagId'],
      price: map['price'].toDouble(),
      about: map['about'],
      submitted: map['submitted'],
      published: map['published'],
      pictureUrl: map['pictureUrl'],
      places: _places,
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      deletedAt: map['deletedAt'],
    );
  }

  String toJson() => json.encode(toMap());

  static Future<Trip> fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'Trip(id: $id, name: $name, ownerId: $ownerId, googlePlaceId: $googlePlaceId, countryId: $countryId, previewAudioUrl: $previewAudioUrl, languageNameId: $languageNameId, languageFlagId: $languageFlagId, price: $price, about: $about, submitted: $submitted, published: $published, pictureUrl: $pictureUrl, places: $places, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
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
        o.pictureUrl == pictureUrl &&
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
        pictureUrl.hashCode ^
        places.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }
}
