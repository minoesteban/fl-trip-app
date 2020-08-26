import 'dart:async' show Future;
import 'package:flutter/material.dart';
import '../core/controllers/place.controller.dart';
import '../core/models/place.model.dart';
import '../core/controllers/trip.controller.dart';
import '../core/models/rating.model.dart';
import '../core/models/trip.model.dart';
import '../providers/rating.provider.dart';

class TripProvider with ChangeNotifier {
  PlaceController _placeController = PlaceController();
  TripController _controller = TripController();
  List<int> tripIds = [];
  // List<Trip> _trips;

  List<Trip> get trips {
    return _controller.trips;
  }

  Future<List<int>> init() async {
    return await _controller.init();
  }

  Future<void> loadTrips() async {
    tripIds = await init();

    //TODO: check connectivity before getting trips from api. work with local trips
    bool connected = true;
    if (connected) {
      List<Trip> _trips = await _controller
          .getAllTrips()
          .then((value) => value)
          .catchError((err) {
        throw err;
      });
      _controller.setTripIds(_trips.map((e) => e.id).toList());
      _controller.updateLocalTrips(_trips);
    }

    notifyListeners();
    return [...trips];
  }

  Future<void> deleteLocal(Trip trip) async {
    print('deletelocal');
    await _controller.deleteLocal(trip);
    notifyListeners();
  }

  Future<void> createLocal(Trip trip) async {
    print('createlocal');
    await _controller.orderPlaces(trip);
    await _controller.createLocal(trip);
    notifyListeners();
  }

  Future<Trip> create(Trip trip) async {
    try {
      await _controller.orderPlaces(trip);
      Trip createdTrip = await _controller.create(trip);
      notifyListeners();

      if (createdTrip.id > 0) {
        _controller.createLocal(createdTrip);
        _controller.deleteLocal(trip);
      }

      notifyListeners();
      return createdTrip;
    } catch (err) {
      throw err;
    }
  }

  Future<void> submit(Trip trip) async {
    print('creating trip ${trip.name}');
    try {
      Trip createdTrip = await create(trip);
      print(
          'created trip ${createdTrip.id} ${createdTrip.name} image ${createdTrip.imageUrl} audio ${createdTrip.previewAudioUrl}');
      if (createdTrip.id > 0) {
        List<Place> updatedPlaces = [];
        for (Place place in createdTrip.places) {
          updatedPlaces.add(await updatePlace(place));
          print(
              'updated place ${place.name} image ${place.imageUrl} audio ${place.previewAudioUrl} audio ${place.fullAudioUrl}');
        }
        createdTrip.places = updatedPlaces;

        Trip submittedTrip = await _controller.submit(createdTrip.id);
        if (submittedTrip.submitted) {
          createdTrip.submitted = true;
          await updateLocal(createdTrip);
          print(
              'submitted trip ${_controller.tripBox.get(createdTrip.id).name} ${_controller.tripBox.get(createdTrip.id).submitted}');
          notifyListeners();
        }
      }
    } catch (err) {
      throw err;
    }
  }

  Future<void> updateLocal(Trip trip) async {
    print('updatelocal');
    await _controller.updateLocal(trip);
    notifyListeners();
  }

  Future<Place> updatePlace(Place place) async {
    print('updateplace');
    try {
      Place updatedPlace = await _placeController.update(place);
      return updatedPlace;
    } catch (err) {
      throw err;
    }
  }

  Trip findById(int id) {
    return _controller.trips.firstWhere((element) => element.id == id);
  }

  List<Trip> findByGuide(int ownerId) {
    return _controller.trips.where((trip) => trip.ownerId == ownerId).toList();
  }

  List<Trip> findByLanguage(String lang) {
    return _controller.trips.where((trip) => trip.languageNameId == lang);
  }

  List<Trip> findByCity(String placeId) {
    return _controller.trips.where((trip) => trip.googlePlaceId == placeId);
  }

  Future<double> getAndSetTripRatings(int tripId) async {
    List<double> ratings = [];

    ratings = _controller.trips
        .firstWhere((trip) => trip.id == tripId)
        .places
        .where((place) => place.ratingAvg != null)
        .map((place) => place.ratingAvg)
        .toList();

    if (ratings.length > 0)
      return ratings.reduce((a, b) => a + b) / ratings.length;

    List<Rating> ratingsOnline = [];
    ratingsOnline = await RatingProvider().getRatingsBy(tripId, 0);

    if (ratingsOnline != null) {
      Trip trip = _controller.trips.firstWhere((t) => t.id == tripId);
      trip.places.forEach((place) {
        place.ratingAvg = ratingsOnline
            .firstWhere(
              (rt) => rt.tripId == trip.id && rt.placeId == place.id,
              orElse: () => Rating(rating: 0.0, count: 0),
            )
            .rating;

        place.ratingCount = ratingsOnline
            .firstWhere(
              (rt) => rt.tripId == trip.id && rt.placeId == place.id,
              orElse: () => Rating(rating: 0.0, count: 0),
            )
            .count;
      });
      updateLocal(trip);
    }
    // notifyListeners();

    return ratingsOnline.length > 0
        ? ratingsOnline.map((e) => e.rating).reduce((a, b) => a + b) /
            ratingsOnline.length
        : 0;
  }

  // Future<void> delete(int id) async {
  //   await _controller.delete(id).catchError((err) => throw err);
  //   notifyListeners();
  // }

  // Future<void> deletePlaceLocal(Place place) async {
  //   Trip trip = _controller.trips.firstWhere((t) => t.id == place.tripId);
  //   trip.places.removeWhere((p) => p.id == place.id);
  //   return await _controller.updateLocal(trip);
  // }

  // Future<void> update(Trip trip) async {
  //   try {
  //     List<Place> places = trip.places;
  //     Trip updatedTrip = await _controller.update(trip);
  //     updatedTrip.places = places;
  //     await _controller.updateLocal(trip);
  //     notifyListeners();
  //   } catch (err) {
  //     throw err;
  //   }
  // }

  // Future<void> deletePlace(Place place) async {
  //   int tripIndex = _controller.trips.indexWhere((e) => e.id == place.tripId);
  //   await _placeController.delete(place.tripId, place.id).then((_) async {
  //     await orderPlacesinDB(_controller.trips[tripIndex]);
  //     notifyListeners();
  //   }).catchError((err) => throw err);
  // }

  // Future<void> createPlace(Place place) async {
  //   int tripIndex =
  //       _controller.trips.indexWhere((trip) => trip.id == place.tripId);
  //   Trip trip = _controller.trips[tripIndex];
  //   await _placeController.create(place).then((createdPlace) async {
  //     trip.places.add(createdPlace);
  //     _controller.updateLocal(trip);
  //     notifyListeners();
  //   }).catchError((err) => throw err);
  // }

  // Future<void> orderPlacesinDB(Trip trip) async {
  //   await _controller.orderPlaces(trip);
  //   notifyListeners();
  // }
}
