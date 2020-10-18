import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tripper/core/utils/utils.dart';

part 'user.model.g.dart';

@HiveType(typeId: 1)
class User {
  @HiveField(0)
  int id;
  @HiveField(1)
  String username;
  String password;
  @HiveField(2)
  String firstName;
  @HiveField(3)
  String lastName;
  @HiveField(4)
  String imageUrl;
  @HiveField(5)
  FileOrigin imageOrigin;
  @HiveField(6)
  List<String> selectedLanguages;
  @HiveField(7)
  String about;
  @HiveField(8)
  List<int> favouriteTrips;
  @HiveField(9)
  List<int> favouritePlaces;
  @HiveField(10)
  List<int> purchasedTrips;
  @HiveField(11)
  List<int> purchasedPlaces;
  @HiveField(12)
  List<int> downloadedTrips;
  @HiveField(13)
  List<int> downloadedPlaces;
  Position position; // not in DB model
  @HiveField(14)
  bool onlyNearest;
  @HiveField(15)
  bool onlyFavourites;
  @HiveField(16)
  bool onlyPurchased;
  bool active;
  @HiveField(17)
  DateTime createdAt;
  @HiveField(18)
  DateTime updatedAt;
  DateTime deletedAt;
  @HiveField(19)
  bool needSync;
  // @HiveField(20)
  // Map<String, double> lastPosition;
  User({
    this.id,
    this.username,
    this.password,
    this.firstName,
    this.lastName,
    this.imageUrl,
    this.about,
    this.selectedLanguages,
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
    String imageUrl,
    String about,
    List<String> selectedLanguages,
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
      imageUrl: imageUrl ?? this.imageUrl,
      about: about ?? this.about,
      selectedLanguages: selectedLanguages ?? this.selectedLanguages,
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
      'imageUrl': imageUrl,
      'about': about,
      'selectedLanguages': selectedLanguages,
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

  Map<String, dynamic> toMapForDB() {
    return {
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'imageUrl': imageUrl,
      'about': about,
      'favouriteTrips': favouriteTrips,
      'favouritePlaces': favouritePlaces,
      'purchasedTrips': purchasedTrips,
      'purchasedPlaces': purchasedPlaces,
    };
  }

  Map<String, dynamic> toMapPrefs() {
    return {
      'id': id,
      'selectedLanguages': selectedLanguages,
      'favouriteTrips': favouriteTrips,
      'favouritePlaces': favouritePlaces,
      'downloadedTrips': downloadedTrips,
      'downloadedPlaces': downloadedPlaces,
      'onlyNearest': onlyNearest,
      'onlyFavourites': onlyFavourites,
      'onlyPurchased': onlyPurchased,
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
      imageUrl: map['imageUrl'],
      about: map['about'],
      selectedLanguages: map['selectedLanguages'] != null
          ? List<String>.from(map['selectedLanguages'])
          : [],
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
      position:
          map['position'] != null ? Position.fromMap(map['position']) : null,
      onlyNearest: map['onlyNearest'],
      onlyFavourites: map['onlyFavourites'],
      onlyPurchased: map['onlyPurchased'],
      active: map['active'],
      createdAt: DateTime.tryParse(map['created_at']),
      updatedAt: DateTime.tryParse(map['updated_at']),
    );
  }

  String toJson() => json.encode(toMap());

  static User fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'User(id: $id, username: $username, password: $password, firstName: $firstName, lastName: $lastName, imageUrl: $imageUrl, selectedLanguages: $selectedLanguages,  favouriteTrips: $favouriteTrips, favouritePlaces: $favouritePlaces, purchasedTrips: $purchasedTrips, purchasedPlaces: $purchasedPlaces, downloadedTrips: $downloadedTrips, downloadedPlaces: $downloadedPlaces, position: $position, onlyNearest: $onlyNearest, onlyFavourites: $onlyFavourites, onlyPurchased: $onlyPurchased, active: $active, about: $about,  createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
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
        o.imageUrl == imageUrl &&
        o.about == about &&
        listEquals(o.selectedLanguages, selectedLanguages) &&
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
        imageUrl.hashCode ^
        about.hashCode ^
        selectedLanguages.hashCode ^
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
