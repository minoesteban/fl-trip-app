import 'dart:io';
import '../../core/models/place.model.dart';
import '../../core/services/place.service.dart';

class PlaceController {
  PlaceService _service = PlaceService();

  Future<Place> create(Place place) async {
    try {
      Place createdPlace = await _service.create(place);
      createdPlace = await uploadAudio(createdPlace, place);
      createdPlace = await uploadImage(createdPlace, place);
      return createdPlace;
    } catch (err) {
      throw err;
    }
  }

  Future<Place> update(Place place) async {
    try {
      Place updatedPlace = await _service.update(place);
      //these should not be called in trip submitting
      updatedPlace = await uploadAudio(updatedPlace, place);
      updatedPlace = await uploadImage(updatedPlace, place);
      return updatedPlace;
    } catch (err) {
      throw err;
    }
  }

  Future<void> order(Place place) async {
    await _service.order(place).catchError((err) => throw err);
  }

  Future<void> delete(int tripId, int placeId) async {
    return await _service
        .delete(tripId, placeId)
        .catchError((err) => throw err);
  }

  Future<Place> uploadImage(Place newPlace, Place oldPlace) async {
    try {
      if (oldPlace.imageUrl.isNotEmpty) {
        File image = File(oldPlace.imageUrl);
        newPlace.imageUrl =
            await _service.uploadImage(newPlace.tripId, newPlace.id, image);
      }
      return newPlace;
    } catch (err) {
      throw err;
    }
  }

  Future<Place> uploadAudio(Place newPlace, Place oldPlace) async {
    try {
      if (oldPlace.previewAudioUrl.isNotEmpty) {
        File audio = File(oldPlace.previewAudioUrl);
        newPlace.previewAudioUrl = await _service.uploadAudio(
            newPlace.tripId, newPlace.id, audio, false);
      }
      if (oldPlace.fullAudioUrl.isNotEmpty) {
        File audio = File(oldPlace.fullAudioUrl);
        newPlace.fullAudioUrl = await _service.uploadAudio(
            newPlace.tripId, newPlace.id, audio, true);
      }
      return newPlace;
    } catch (err) {
      throw err;
    }
  }
}
