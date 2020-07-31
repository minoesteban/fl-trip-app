import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class User {
  int id;
  String username;
  String password;
  String firstName;
  String lastName;
  String languageId1;
  String languageId2;
  String languageId3;
  String languageId4;
  String languageId5;
  String about;
  List<int> favouriteTrips;
  List<int> favouritePlaces;
  List<int> purchasedTrips;
  List<int> purchasedPlaces;
  List<int> downloadedTrips;
  List<int> downloadedPlaces;
  Position position;
  bool onlyNearest;
  bool onlyFavourites;
  bool onlyPurchased;
  bool active;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime deletedAt;
  User({
    this.id,
    this.username,
    this.password,
    this.firstName,
    this.lastName,
    this.languageId1,
    this.languageId2,
    this.languageId3,
    this.languageId4,
    this.languageId5,
    this.about,
    this.favouriteTrips,
    this.favouritePlaces,
    this.purchasedTrips,
    this.purchasedPlaces,
    this.downloadedTrips,
    this.downloadedPlaces,
    this.position,
    this.onlyNearest,
    this.onlyFavourites,
    this.onlyPurchased,
    this.active,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  User copyWith({
    int id,
    String username,
    String password,
    String firstName,
    String lastName,
    String languageId1,
    String languageId2,
    String languageId3,
    String languageId4,
    String languageId5,
    String about,
    List<int> favouriteTrips,
    List<int> favouritePlaces,
    List<int> purchasedTrips,
    List<int> purchasedPlaces,
    List<int> downloadedTrips,
    List<int> downloadedPlaces,
    Position position,
    bool onlyNearest,
    bool onlyFavourites,
    bool onlyPurchased,
    bool active,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime deletedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      languageId1: languageId1 ?? this.languageId1,
      languageId2: languageId2 ?? this.languageId2,
      languageId3: languageId3 ?? this.languageId3,
      languageId4: languageId4 ?? this.languageId4,
      languageId5: languageId5 ?? this.languageId5,
      about: about ?? this.about,
      favouriteTrips: favouriteTrips ?? this.favouriteTrips,
      favouritePlaces: favouritePlaces ?? this.favouritePlaces,
      purchasedTrips: purchasedTrips ?? this.purchasedTrips,
      purchasedPlaces: purchasedPlaces ?? this.purchasedPlaces,
      downloadedTrips: downloadedTrips ?? this.downloadedTrips,
      downloadedPlaces: downloadedPlaces ?? this.downloadedPlaces,
      onlyNearest: onlyNearest ?? this.onlyNearest,
      onlyFavourites: onlyFavourites ?? this.onlyFavourites,
      onlyPurchased: onlyPurchased ?? this.onlyPurchased,
      position: position ?? this.position,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'languageId1': languageId1,
      'languageId2': languageId2,
      'languageId3': languageId3,
      'languageId4': languageId4,
      'languageId5': languageId5,
      'about': about,
      'favouriteTrips': favouriteTrips,
      'favouritePlaces': favouritePlaces,
      'purchasedTrips': purchasedTrips,
      'purchasedPlaces': purchasedPlaces,
      'downloadedTrips': downloadedTrips,
      'downloadedPlaces': downloadedPlaces,
      'position': position,
      'onlyNearest': onlyNearest,
      'onlyFavourites': onlyFavourites,
      'onlyPurchased': onlyPurchased,
      'active': active,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      languageId1: map['languageId1'],
      languageId2: map['languageId2'],
      languageId3: map['languageId3'],
      languageId4: map['languageId4'],
      languageId5: map['languageId5'],
      about: map['about'],
      favouriteTrips: map['favouriteTrips'] != null
          ? List<int>.from(map['favouriteTrips'])
          : [],
      favouritePlaces: map['favouritePlaces'] != null
          ? List<int>.from(map['favouritePlaces'])
          : [],
      purchasedTrips: map['purchasedTrips'] != null
          ? List<int>.from(map['purchasedTrips'])
          : [],
      purchasedPlaces: map['purchasedPlaces'] != null
          ? List<int>.from(map['purchasedPlaces'])
          : [],
      downloadedTrips: map['downloadedTrips'] != null
          ? List<int>.from(map['downloadedTrips'])
          : [],
      downloadedPlaces: map['downloadedPlaces'] != null
          ? List<int>.from(map['downloadedPlaces'])
          : [],
      position:
          map['position'] != null ? Position.fromMap(map['position']) : null,
      onlyNearest: map['onlyNearest'],
      onlyFavourites: map['onlyFavourites'],
      onlyPurchased: map['onlyPurchased'],
      active: map['active'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      deletedAt: map['deletedAt'],
    );
  }

  String toJson() => json.encode(toMap());

  static User fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'User(id: $id, username: $username, password: $password, firstName: $firstName, lastName: $lastName, languageId1: $languageId1, languageId2: $languageId2, languageId3: $languageId3, languageId4: $languageId4, languageId5: $languageId5, about: $about, favouriteTrips: $favouriteTrips, favouritePlaces: $favouritePlaces, purchasedTrips: $purchasedTrips, purchasedPlaces: $purchasedPlaces, downloadedTrips: $downloadedTrips, downloadedPlaces: $downloadedPlaces, position: $position, onlyNearest: $onlyNearest, onlyFavourites: $onlyFavourites, onlyPurchased: $onlyPurchased, active: $active, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is User &&
        o.id == id &&
        o.username == username &&
        o.password == password &&
        o.firstName == firstName &&
        o.lastName == lastName &&
        o.languageId1 == languageId1 &&
        o.languageId2 == languageId2 &&
        o.languageId3 == languageId3 &&
        o.languageId4 == languageId4 &&
        o.languageId5 == languageId5 &&
        o.about == about &&
        listEquals(o.favouriteTrips, favouriteTrips) &&
        listEquals(o.favouritePlaces, favouritePlaces) &&
        listEquals(o.purchasedTrips, purchasedTrips) &&
        listEquals(o.purchasedPlaces, purchasedPlaces) &&
        listEquals(o.downloadedTrips, downloadedTrips) &&
        listEquals(o.downloadedPlaces, downloadedPlaces) &&
        o.position == position &&
        o.onlyNearest == onlyNearest &&
        o.onlyFavourites == onlyFavourites &&
        o.onlyPurchased == onlyPurchased &&
        o.active == active &&
        o.createdAt == createdAt &&
        o.updatedAt == updatedAt &&
        o.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        password.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        languageId1.hashCode ^
        languageId2.hashCode ^
        languageId3.hashCode ^
        languageId4.hashCode ^
        languageId5.hashCode ^
        about.hashCode ^
        favouriteTrips.hashCode ^
        favouritePlaces.hashCode ^
        purchasedTrips.hashCode ^
        purchasedPlaces.hashCode ^
        downloadedTrips.hashCode ^
        downloadedPlaces.hashCode ^
        position.hashCode ^
        onlyNearest.hashCode ^
        onlyFavourites.hashCode ^
        onlyPurchased.hashCode ^
        active.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }
}
