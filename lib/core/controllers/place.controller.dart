import 'dart:convert';
import 'dart:io';

import 'package:tripit/core/models/place.model.dart';
import 'package:tripit/core/models/service-response.model.dart';
import 'package:tripit/core/services/place.service.dart';

class PlaceController {
  PlaceService _service = PlaceService();

  Future<Place> create(Place place) async {
    return await _service.create(place).catchError((err) => throw err);
  }

  Future<ServiceResponse> createMulti(List<Place> places) async {
    List<Place> createdPlaces = [];
    List<HttpException> errs = [];

    places.forEach((place) async {
      await _service
          .create(place)
          .then((createdPlace) => createdPlaces.add(createdPlace))
          //A single place fails, I return it as part of a collection of messages
          .catchError((err) => errs.add(
              HttpException(json.encode({'placeId': place.id, 'error': err}))));
    });
    return ServiceResponse(createdPlaces, errs);
  }

  Future<Place> update(Place place) async {
    return await _service.update(place).catchError((err) => throw err);
  }

  Future<ServiceResponse> updateMulti(List<Place> places) async {
    List<Place> updatedPlaces = [];
    List<HttpException> errs = [];

    places.forEach((place) async {
      await _service
          .update(place)
          .then((updatedPlace) => updatedPlaces.add(updatedPlace))
          //A single place fails, I return it as part of a collection of messages
          .catchError((err) => errs.add(
              HttpException(json.encode({'placeId': place.id, 'error': err}))));
    });

    return ServiceResponse(
        updatedPlaces.length == places.length ? [updatedPlaces.length] : [0],
        errs);
  }
}
