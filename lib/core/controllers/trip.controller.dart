import 'dart:io';

import '../../core/controllers/place.controller.dart';
import '../../core/models/service-response.model.dart';
import '../../core/services/trip.service.dart';
import '../models/trip.model.dart';

class TripController {
  TripService _service = TripService();
  PlaceController _placeController = PlaceController();

  Future<List<Trip>> getAllTrips() async {
    return await _service.getAll().catchError((err) => throw err);
  }

  Future<Trip> create(Trip trip) async {
    return await _service.create(trip).catchError((err) => throw err);
  }

  Future<Trip> submit(int id) async {
    return await _service.submit(id).catchError((err) => throw err);
  }

  Future<Trip> update(Trip trip) async {
    return await _service.update(trip).catchError((err) => throw err);
  }

  Future<ServiceResponse> updateWithPlaces(Trip trip) async {
    List<HttpException> errs = [];

    Trip updatedTrip =
        await _service.create(trip).catchError((e) => errs.add(e));

    if (trip.places.length > 0) {
      if (trip.places.length == 1) {
        updatedTrip.places.add(await _placeController
            .update(trip.places.first)
            .catchError((e) => errs.add(e)));
      } else {
        await _placeController.createMulti(trip.places).then((res) {
          updatedTrip.places = res.hasItems ? res.items : [];
          errs.addAll(res.errors);
        }).catchError((e) => errs.add(e));
      }
    }

    return ServiceResponse([updatedTrip], errs);
  }

  Future<ServiceResponse> createWithPlaces(Trip trip) async {
    List<HttpException> errs = [];

    Trip createdTrip =
        await _service.create(trip).catchError((e) => errs.add(e));

    if (trip.places.length > 0) {
      if (trip.places.length == 1) {
        createdTrip.places.add(await _placeController
            .create(trip.places.first)
            .catchError((e) => errs.add(e)));
      } else {
        await _placeController.createMulti(trip.places).then((res) {
          createdTrip.places = res.hasItems ? res.items : [];
          errs.addAll(res.errors);
        }).catchError((e) => errs.add(e));
      }
    }

    return ServiceResponse([createdTrip], errs);
  }
}
