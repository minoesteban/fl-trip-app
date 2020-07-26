import 'dart:async' show Future;

import 'package:flutter/material.dart';
import 'package:tripit/core/controllers/trip.controller.dart';
import 'package:tripit/core/models/trip.model.dart';

class TripProvider with ChangeNotifier {
  TripController _controller = TripController();
  List<Trip> _trips;

  List<Trip> get trips {
    return [..._trips];
  }

  Future loadTrips() async {
    await _controller.getAllTrips().then((value) => _trips = value);
  }

  void addTrip(Trip trip) {
    _trips.add(trip);
    notifyListeners();
  }

  Trip findById(int id) {
    return _trips.firstWhere((element) => element.id == id);
  }

  List<Trip> findByGuide(int ownerId) {
    return _trips.where((trip) => trip.ownerId == ownerId).toList();
  }

  List<Trip> findByLanguage(String lang) {
    return _trips.where((trip) => trip.languageFlagId == lang);
  }

  List<Trip> findByCity(String placeId) {
    return _trips.where((trip) => trip.googlePlaceId == placeId);
  }
}
