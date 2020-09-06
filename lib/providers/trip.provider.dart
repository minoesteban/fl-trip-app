import 'dart:async' show Future;
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import '../core/controllers/place.controller.dart';
import '../core/controllers/trip.controller.dart';
import '../core/models/rating.model.dart';
import '../core/models/place.model.dart';
import '../core/models/trip.model.dart';

import 'rating.provider.dart';

class TripProvider with ChangeNotifier {
  PlaceController placeController = PlaceController();
  TripController controller = TripController();
  double totalContentLength = 0;
  double downloadPercentage = 0;
  bool isDownloading = false;
  List<int> tripIds = [];

  List<Trip> get trips {
    return controller.trips;
  }

  Future<void> loadTrips() async {
    tripIds = await controller.init();

    //TODO: check connectivity before getting trips from api. work with local trips
    bool connected = true;
    if (connected) {
      List<Trip> _trips = await controller
          .getAllTrips()
          .then((value) => value)
          .catchError((err) {
        throw err;
      });
      controller.setTripIds(_trips.map((e) => e.id).toList());
      controller.updateLocalTrips(_trips);
      for (Trip trip in controller.trips.where((t) => t.id > 0)) {
        if (_trips.map((e) => e.id).toList().indexOf(trip.id) < 0) {
          controller.deleteLocal(trip);
        }
      }
    }

    notifyListeners();
    return [...trips];
  }

  Future<void> deleteLocal(Trip trip) async {
    print('deletelocal');
    await controller.deleteLocal(trip);
    notifyListeners();
  }

  Future<void> createLocal(Trip trip) async {
    print('createlocal');
    trip = controller.orderPlaces(trip);
    await controller.createLocal(trip);
    notifyListeners();
  }

  Future<Trip> create(Trip trip) async {
    try {
      trip = controller.orderPlaces(trip);
      Trip createdTrip = await controller.create(trip);
      notifyListeners();

      if (createdTrip.id > 0) {
        controller.createLocal(createdTrip);
        controller.deleteLocal(trip);
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
        Trip submittedTrip = await controller.submit(createdTrip.id);
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
    await controller.updateLocal(trip);
    notifyListeners();
  }

  Future<Place> updatePlace(Place place) async {
    print('updateplace');
    try {
      Place updatedPlace = await placeController.update(place);
      return updatedPlace;
    } catch (err) {
      throw err;
    }
  }

  Trip findById(int id) {
    return controller.trips.firstWhere((element) => element.id == id);
  }

  List<Trip> findByOwner(int ownerId) {
    return controller.trips.where((trip) => trip.ownerId == ownerId).toList();
  }

  List<Trip> findByLanguage(String lang) {
    return controller.trips.where((trip) => trip.languageNameId == lang);
  }

  List<Trip> findByCity(String placeId) {
    return controller.trips.where((trip) => trip.googlePlaceId == placeId);
  }

  Future<double> getAndSetTripRatings(int tripId) async {
    List<double> ratings = [];

    ratings = controller.trips
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
      Trip trip = controller.trips.firstWhere((t) => t.id == tripId);
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

  // TripDownloadStatus isDownloaded(int tripId) {
  //   Trip trip = controller.trips.firstWhere((t) => t.id == tripId);
  //   var status = TripDownloadStatus.Downloaded;
  //   for (Place place in trip.places) {
  //     if (!placeController.isDownloaded(place)) {
  //       print('falta el archivo de ${place.name}. ${place.fullAudioUrl}');
  //       status = TripDownloadStatus.NotDownloaded;
  //       break;
  //     }
  //   }
  //   if (isDownloading) status = TripDownloadStatus.Downloading;
  //   return status;
  // }

  // Future<void> downloadTripFiles(
  //     Trip trip, BuildContext context, UserProvider user) async {
  //   trip = await controller.getByID(trip.id);
  //   await updateLocal(trip);
  //   String dir = (await getApplicationDocumentsDirectory()).path;
  //   isDownloading = true;
  //   int downloaded = 0;
  //   totalContentLength = 0;
  //   downloadPercentage = 0;
  //   notifyListeners();
  //   for (int i = 0; i < trip.places.length; i++) {
  //     List<List<int>> chunks = new List();
  //     String filename =
  //         path.basename(Uri.parse(trip.places[i].fullAudioUrl).path);
  //     String filePath = '$dir/$filename';

  //     var response = placeController.downloadFullAudio(trip.places[i]);

  //     response.asStream().listen(
  //       (r) async {
  //         if (r.statusCode == HttpStatus.ok) {
  //           totalContentLength += r.contentLength;
  //           r.stream.listen(
  //             (List<int> chunk) {
  //               downloadPercentage = downloaded / totalContentLength;
  //               downloaded += chunk.length;
  //               chunks.add(chunk);
  //               notifyListeners();
  //             },
  //             onDone: () async {
  //               downloadPercentage = downloaded / totalContentLength;
  //               notifyListeners();

  //               File file = new File(filePath);
  //               final Uint8List bytes = Uint8List(r.contentLength);
  //               int offset = 0;
  //               for (List<int> chunk in chunks) {
  //                 bytes.setRange(offset, offset + chunk.length, chunk);
  //                 offset += chunk.length;
  //               }
  //               file = await file.writeAsBytes(bytes);
  //               isDownloading = false;
  //               notifyListeners();
  //               trip.places[i].fullAudioUrl = filePath;
  //               await updateLocal(trip);
  //             },
  //             onError: (error) async {
  //               isDownloading = false;
  //               notifyListeners();
  //               user.removeFromDownloadedTrips(trip.id);
  //               showMessage(context, 'something went wrong!', false);
  //             },
  //           );
  //         } else {
  //           isDownloading = false;
  //           notifyListeners();
  //           user.removeFromDownloadedTrips(trip.id);
  //           showMessage(context, 'something went wrong!!', false);
  //         }
  //       },
  //     );
  //   }
  // }
  // void deleteTripFiles(Trip trip) {
  //   if (trip.previewAudioUrl != null &&
  //       !trip.previewAudioUrl.startsWith('http'))
  //     File(trip.previewAudioUrl).deleteSync();

  //   for (int i = 0; i < trip.places.length; i++) {
  //     placeController.deletePlaceFiles(trip.places[i]);
  //   }
  //   notifyListeners();
  // }
}

enum TripDownloadStatus {
  NotDownloaded,
  Downloaded,
  Downloading,
}
