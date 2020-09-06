import 'dart:io';
import 'package:hive/hive.dart';
import 'package:tripit/core/models/place.model.dart';
import '../../core/services/trip.service.dart';
import '../models/trip.model.dart';

class TripController {
  TripService _service = TripService();
  Box<Trip> tripBox;

  List<Trip> get trips {
    return tripBox.values.toList();
  }

  Future<List<int>> init() async {
    tripBox = await Hive.openBox('trips');
    return await Hive.openBox('lists')
        .then((value) => List.castFrom<dynamic, int>(value.get('tripIds')));
  }

  Future<void> setTripIds(List<int> tripIds) async {
    return await Hive.openBox('lists')
        .then((box) => box.put('tripIds', tripIds));
  }

  Trip orderPlaces(Trip trip) {
    for (int i = 0; i < trip.places.length; i++) {
      trip.places[i].order = i + 1;
    }
    return trip;
  }

  Future<void> updateLocalTrips(List<Trip> trips) async {
    trips.forEach((trip) {
      if (tripBox.get(trip.id, defaultValue: null) == null)
        updateLocal(trip);
      else {
        if (tripBox.get(trip.id).updatedAt == null)
          updateLocal(trip);
        else if (trip.updatedAt.isAfter(tripBox.get(trip.id).updatedAt))
          updateLocal(trip);
        else {
          tripsLoop:
          for (Trip tripCloud in trips) {
            Trip tripLocal = tripBox.get(tripCloud.id);
            for (Place placeCloud in tripCloud.places) {
              Place placeLocal =
                  tripLocal.places.firstWhere((p) => p.id == placeCloud.id);
              if (placeCloud.updatedAt.isAfter(placeLocal.updatedAt)) {
                updateLocal(tripCloud);
                continue tripsLoop;
              }
            }
          }
        }
      }
    });
  }

  Future<List<Trip>> getAllTrips() async {
    List<Trip> trips = await _service.getAll().catchError((err) => throw err);
    return trips;
  }

  Future<Trip> getByID(int id) async {
    return await _service.getByID(id).catchError((err) => throw err);
  }

  Future<void> createLocal(Trip trip) async {
    trip.createdAt = DateTime.now();
    trip.published = false;
    trip.submitted = false;
    return await updateLocal(trip);
  }

  Future<Trip> create(Trip trip) async {
    try {
      Trip createdTrip = await _service.create(trip);

      File image = File(trip.imageUrl);
      createdTrip.imageUrl = await uploadImage(createdTrip.id, image);

      File audio = File(trip.previewAudioUrl);
      createdTrip.previewAudioUrl = await uploadAudio(createdTrip.id, audio);

      return createdTrip;
    } catch (err) {
      throw err;
    }
  }

  Future<Trip> submit(int id) async {
    return await _service.submit(id).catchError((err) => throw err);
  }

  Future<void> updateLocal(Trip trip) async {
    trip.updatedAt = DateTime.now();
    if (trip.id > 0)
      return await tripBox.put(trip.id, trip);
    else
      return await tripBox.put(trip.createdAt.toIso8601String(), trip);
  }

  Future<void> deleteLocal(Trip trip) async {
    if (trip.id > 0)
      return await tripBox.delete(trip.id);
    else
      return await tripBox.delete(trip.createdAt.toIso8601String());
  }

  Future<String> uploadImage(int id, File image) async {
    return await _service.uploadImage(id, image);
  }

  Future<String> uploadAudio(int id, File audio) async {
    return await _service.uploadAudio(id, audio);
  }
}
