import 'dart:async' show Future;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tripit/core/trip/trip-model.dart';

class Trips with ChangeNotifier {
  List<Trip> _trips;

  Trips() {
    _loadTrips();
  }

  List<Trip> get trips {
    return [..._trips];
  }

  void addTrip(Trip trip) {
    _trips.add(trip);
    notifyListeners();
  }

  Trip findById(String id) {
    return _trips.firstWhere((element) => element.id == id);
  }

  List<Trip> findByGuide(String guideId) {
    return _trips.where((trip) => trip.guideId == guideId).toList();
  }

  List<Trip> findByLanguage(String lang) {
    return _trips.where((trip) => trip.language == lang);
  }

  List<Trip> findByCity(String placeId) {
    return _trips.where((trip) => trip.placeId == placeId);
  }

  Future _loadTrips() async {
    _trips = [];
    String jsonString = await rootBundle.loadString('assets/trips-file.json');
    final jsonResponse = jsonDecode(jsonString);
    for (var i = 0; i < jsonResponse.length; i++) {
      _trips.add(Trip.fromJson(jsonResponse[i]));
    }
    notifyListeners();
  }
}
