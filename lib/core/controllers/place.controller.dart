import 'dart:io';
import 'package:http/http.dart';

import '../../core/models/place.model.dart';
import '../../core/services/place.service.dart';

class PlaceController {
  PlaceService service = PlaceService();

  Future<Place> create(Place place) async {
    try {
      Place createdPlace = await service.create(place);
      createdPlace = await uploadAudio(createdPlace, place);
      createdPlace = await uploadImage(createdPlace, place);
      return createdPlace;
    } catch (err) {
      throw err;
    }
  }

  Future<Place> update(Place place) async {
    try {
      Place updatedPlace = await service.update(place);
      //these should not be called in trip submitting
      updatedPlace = await uploadAudio(updatedPlace, place);
      updatedPlace = await uploadImage(updatedPlace, place);
      return updatedPlace;
    } catch (err) {
      throw err;
    }
  }

  Future<void> order(Place place) async {
    await service.order(place).catchError((err) => throw err);
  }

  Future<void> delete(int tripId, int placeId) async {
    return await service.delete(tripId, placeId).catchError((err) => throw err);
  }

  Future<Place> uploadImage(Place newPlace, Place oldPlace) async {
    try {
      if (oldPlace.imageUrl.isNotEmpty) {
        File image = File(oldPlace.imageUrl);
        newPlace.imageUrl =
            await service.uploadImage(newPlace.tripId, newPlace.id, image);
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
        newPlace.previewAudioUrl = await service.uploadAudio(
            newPlace.tripId, newPlace.id, audio, false);
      }
      if (oldPlace.fullAudioUrl.isNotEmpty) {
        File audio = File(oldPlace.fullAudioUrl);
        newPlace.fullAudioUrl = await service.uploadAudio(
            newPlace.tripId, newPlace.id, audio, true);
      }
      return newPlace;
    } catch (err) {
      throw err;
    }
  }

  Future<StreamedResponse> downloadFullAudio(Place place) async {
    try {
      return await service.downloadFullAudio(place);
    } catch (err) {
      throw err;
    }
  }

  Future<String> getDownloadUrl(String url, bool isFullAudio) async {
    return await service.getDownloadUrl(url, isFullAudio);
  }

  bool isDownloaded(Place place) {
    if (!place.fullAudioUrl.startsWith('http')) {
      File file = File(place.fullAudioUrl);
      return file.existsSync();
    } else
      return false;
  }

  void deletePlaceFiles(Place place) {
    if (!place.fullAudioUrl.startsWith('http')) if (File(place.fullAudioUrl)
        .existsSync()) File(place.fullAudioUrl).deleteSync();

    if (!place.previewAudioUrl
        .startsWith('http')) if (File(place.previewAudioUrl).existsSync())
      File(place.previewAudioUrl).deleteSync();
  }
}
