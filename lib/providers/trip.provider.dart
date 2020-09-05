import 'dart:async' show Future;
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
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
      for (Trip trip in _controller.trips.where((t) => t.id > 0)) {
        if (_trips.map((e) => e.id).toList().indexOf(trip.id) < 0) {
          print(trip);
          _controller.deleteLocal(trip);
        }
      }
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
    trip = _controller.orderPlaces(trip);
    await _controller.createLocal(trip);
    notifyListeners();
  }

  Future<Trip> create(Trip trip) async {
    try {
      trip = _controller.orderPlaces(trip);
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

  Future<void> submit(Trip trip, ProgressDialog pr) async {
    double progressPoint = 100 / (trip.places.length + 2);

    pr.update(
      message: 'Creating trip ${trip.name}',
      progress: 0,
    );

    try {
      Trip createdTrip = await create(trip);
      if (createdTrip.id > 0) {
        List<Place> updatedPlaces = [];
        for (Place place in createdTrip.places) {
          pr.update(
            message: 'Uploading place ${place.name}',
            progress: progressPoint * (createdTrip.places.indexOf(place) + 1),
          );
          updatedPlaces.add(await updatePlace(place));
        }
        createdTrip.places = updatedPlaces;
        pr.update(
          message: 'Submitting trip',
          progress: progressPoint * (trip.places.length + 2),
        );
        Trip submittedTrip = await _controller.submit(createdTrip.id);
        if (submittedTrip.submitted) {
          createdTrip.submitted = true;
          await updateLocal(createdTrip);
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
}
