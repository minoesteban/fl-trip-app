import 'dart:io';
import 'package:hive/hive.dart';
import '../../core/services/trip.service.dart';
import '../models/trip.model.dart';

class TripController {
  TripService _service = TripService();
  Box<Trip> tripBox;

  Future<List<int>> init() async {
    tripBox = await Hive.openBox('trips');

    return await Hive.openBox('lists')
        .then((value) => List.castFrom<dynamic, int>(value.get('tripIds')));
  }

  List<Trip> get trips {
    return tripBox.values.toList();
  }

  Future<void> setTripIds(List<int> tripIds) async {
    return await Hive.openBox('lists')
        .then((box) => box.put('tripIds', tripIds));
  }

  Future<void> orderPlaces(Trip trip) async {
    for (int i = 0; i < trip.places.length; i++) {
      trip.places[i].order = i + 1;
    }
    await updateLocal(trip);
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
      }
    });
  }

  Future<List<Trip>> getAllTrips() async {
    List<Trip> trips = await _service.getAll().catchError((err) => throw err);
    return trips;
  }

  Future<void> createLocal(Trip trip) async {
    trip.createdAt = DateTime.now();
    if (trip.id > 0)
      return await updateLocal(trip);
    else
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
      return await tripBox.put(trip.createdAt, trip);
  }

  Future<void> deleteLocal(Trip trip) async {
    if (trip.id > 0)
      return await tripBox.delete(trip.id);
    else
      return await tripBox.delete(trip.createdAt);
  }

  Future<String> uploadImage(int id, File image) async {
    return await _service.uploadImage(id, image);
  }

  Future<String> uploadAudio(int id, File audio) async {
    return await _service.uploadAudio(id, audio);
  }
}
