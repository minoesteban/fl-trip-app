import 'dart:async' show Future;

import 'package:flutter/material.dart';
import '../core/models/service-response.model.dart';
import '../core/controllers/trip.controller.dart';
import '../core/models/rating.model.dart';
import '../core/models/trip.model.dart';
import '../providers/rating.provider.dart';

class TripProvider with ChangeNotifier {
  TripController _controller = TripController();
  List<Trip> _trips;

  List<Trip> get trips {
    return [..._trips];
  }

  Future<List<Trip>> loadTrips() async {
    _trips = await _controller
        .getAllTrips()
        .then((value) => value)
        .catchError((err) {
      print(err);
      throw err;
    });
    return [..._trips];
  }

  Future<Trip> create(Trip trip) async {
    return await _controller.create(trip).catchError((err) => throw err);
  }

  Future<ServiceResponse> createWithPlaces(Trip trip) async {
    return await _controller.createWithPlaces(trip);
  }

  Future<Trip> submit(int id) async {
    return await _controller.submit(id).catchError((err) => throw err);
  }

  Future<Trip> update(Trip trip) async {
    return await _controller.update(trip).catchError((err) => throw err);
  }

  Future<ServiceResponse> updateWithPlaces(Trip trip) async {
    return await _controller.updateWithPlaces(trip);
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
    return _trips.where((trip) => trip.languageNameId == lang);
  }

  List<Trip> findByCity(String placeId) {
    return _trips.where((trip) => trip.googlePlaceId == placeId);
  }

  Future<double> getAndSetTripRatings(int tripId) async {
    List<Rating> ratings = [];
    ratings = _trips
        .firstWhere((trip) => trip.id == tripId)
        .places
        .where((place) => place.rating != null)
        .map((place) => place.rating)
        .toList();

    if (ratings.length > 0)
      return ratings.map((e) => e.rating).reduce((a, b) => a + b) /
          ratings.length;

    ratings = [];
    ratings = await RatingProvider().getRatingsBy(tripId, 0);

    if (ratings != null)
      _trips.forEach((trip) {
        if (trip.id == tripId)
          trip.places.forEach((place) {
            place.rating = ratings.firstWhere(
              (rt) => rt.tripId == trip.id && rt.placeId == place.id,
              orElse: () => Rating(rating: 0.0, count: 0),
            );
          });
      });
    notifyListeners();

    return ratings.length > 0
        ? ratings.map((e) => e.rating).reduce((a, b) => a + b) / ratings.length
        : 0;
  }
}
