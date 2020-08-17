import 'dart:async' show Future;
import 'dart:io';
import 'package:flutter/material.dart';
import '../core/utils/utils.dart';
import '../core/controllers/place.controller.dart';
import '../core/models/place.model.dart';
import '../core/controllers/trip.controller.dart';
import '../core/models/rating.model.dart';
import '../core/models/trip.model.dart';
import '../providers/rating.provider.dart';

class TripProvider with ChangeNotifier {
  TripController _controller = TripController();
  PlaceController _placeController = PlaceController();
  List<Trip> _trips;

  List<Trip> get trips {
    return [..._trips];
  }

  Future<List<Trip>> loadTrips() async {
    _trips = await _controller
        .getAllTrips()
        .then((value) => value)
        .catchError((err) {
      throw err;
    });
    return [..._trips];
  }

  Future<void> delete(int id) async {
    await _controller.delete(id).catchError((err) => throw err);
    _trips.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  Future<void> deletePlace(Place place) async {
    int tripIndex = _trips.indexWhere((e) => e.id == place.tripId);
    await _placeController.delete(place.tripId, place.id).then((_) async {
      _trips[tripIndex].places.removeWhere((p) => p.id == place.id);
      await orderPlacesinDB(_trips[tripIndex]);
      notifyListeners();
    }).catchError((err) => throw err);
  }

  Future<void> create(Trip trip) async {
    try {
      orderPlaces(trip);
      Trip createdTrip = await _controller.create(trip);
      _trips.add(createdTrip);
      notifyListeners();

      if (createdTrip.id > 0) {
        for (int i = 0; i <= createdTrip.places.length; i++) {
          createdTrip.places[i].previewAudioOrigin = FileOrigin.Local;
          createdTrip.places[i].fullAudioOrigin = FileOrigin.Local;
          createdTrip.places[i].imageOrigin = FileOrigin.Local;
          createdTrip.places[i] = await _placeController.uploadAudio(
              createdTrip.places[i], createdTrip.places[i]);
          createdTrip.places[i] = await _placeController.uploadImage(
              createdTrip.places[i], createdTrip.places[i]);
        }
      }

      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> submit(int id) async {
    await _controller.submit(id).then((resultTrip) {
      if (_trips.indexWhere((e) => e.id == resultTrip.id) > 0)
        _trips[_trips.indexWhere((e) => e.id == resultTrip.id)].submitted =
            true;
      notifyListeners();
    }).catchError((err) => throw err);
  }

  Future<void> update(Trip trip) async {
    await _controller.update(trip).then((updatedTrip) {
      _trips[_trips.indexWhere((e) => e.id == updatedTrip.id)] = updatedTrip;
      notifyListeners();
    }).catchError((err) => throw err);
  }

  void addTrip(Trip trip) {
    trip.id = _trips.last.id + 1;
    _trips.add(trip);
    notifyListeners();
  }

  Future<void> createPlace(Place place) async {
    int tripIndex = _trips.indexWhere((trip) => trip.id == place.tripId);
    await _placeController.create(place).then((createdPlace) async {
      _trips[tripIndex].places.add(createdPlace);
      await orderPlacesinDB(_trips[tripIndex]);
      notifyListeners();
    }).catchError((err) => throw err);
  }

  Future<void> updatePlace(Place place) async {
    int tripIndex = _trips.indexWhere((trip) => trip.id == place.tripId);
    int placeIndex =
        _trips[tripIndex].places.indexWhere((p) => place.id == p.id);
    await _placeController.update(place).then((updatedPlace) async {
      _trips[tripIndex].places[placeIndex] = updatedPlace;
      await orderPlacesinDB(_trips[tripIndex]);
      notifyListeners();
    }).catchError((err) => throw err);
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
    print('tripprovider-getratings');
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

  void orderPlaces(Trip trip) {
    for (int i = 0; i < trip.places.length; i++) {
      trip.places[i].order = i + 1;
    }
  }

  Future<void> orderPlacesinDB(Trip trip) async {
    orderPlaces(trip);
    trip.places.forEach((place) async {
      await _placeController.order(place);
    });
    notifyListeners();
  }

  Future<void> updateImage(int id, File image) async {
    _trips[_trips.indexWhere((e) => e.id == id)].imageUrl = image.path;

    _trips[_trips.indexWhere((e) => e.id == id)].imageOrigin = FileOrigin.Local;
    notifyListeners();

    String downloadUrl = await _controller.uploadImage(id, image);
    if (downloadUrl != null) {
      _trips[_trips.indexWhere((e) => e.id == id)].imageUrl = downloadUrl;
      _trips[_trips.indexWhere((e) => e.id == id)].imageOrigin =
          FileOrigin.Network;
    }
    notifyListeners();
  }
}
