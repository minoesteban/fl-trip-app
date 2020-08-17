import 'dart:io';
import '../../core/utils/utils.dart';
import '../../core/services/trip.service.dart';
import '../models/trip.model.dart';

class TripController {
  TripService _service = TripService();

  Future<List<Trip>> getAllTrips() async {
    return await _service.getAll().catchError((err) => throw err);
  }

  Future<Trip> create(Trip trip) async {
    try {
      Trip createdTrip = await _service.create(trip);
      if (trip.imageOrigin == FileOrigin.Local) {
        File image = File(trip.imageUrl);
        createdTrip.imageUrl = await uploadImage(createdTrip.id, image);
        createdTrip.imageOrigin = FileOrigin.Network;
      }
      if (trip.audioOrigin == FileOrigin.Local) {
        File audio = File(trip.previewAudioUrl);
        createdTrip.previewAudioUrl = await uploadAudio(createdTrip.id, audio);
        createdTrip.audioOrigin = FileOrigin.Network;
      }
      return createdTrip;
    } catch (err) {
      throw err;
    }
  }

  Future<Trip> submit(int id) async {
    return await _service.submit(id).catchError((err) => throw err);
  }

  Future<Trip> update(Trip trip) async {
    try {
      Trip updatedTrip = await _service.update(trip);
      if (trip.imageOrigin == FileOrigin.Local) {
        File image = File(trip.imageUrl);
        updatedTrip.imageUrl = await uploadImage(updatedTrip.id, image);
        updatedTrip.imageOrigin = FileOrigin.Network;
      }
      if (trip.audioOrigin == FileOrigin.Local) {
        File audio = File(trip.previewAudioUrl);
        updatedTrip.previewAudioUrl = await uploadAudio(updatedTrip.id, audio);
        updatedTrip.audioOrigin = FileOrigin.Network;
      }
      return updatedTrip;
    } catch (err) {
      throw err;
    }
  }

  Future<void> delete(int id) async {
    return await _service.delete(id).catchError((err) => throw err);
  }

  Future<String> uploadImage(int id, File image) async {
    return await _service.uploadImage(id, image);
  }

  Future<String> uploadAudio(int id, File audio) async {
    return await _service.uploadAudio(id, audio);
  }
}
