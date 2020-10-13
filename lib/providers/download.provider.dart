import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tripper/core/controllers/download.controller.dart';
import 'package:tripper/core/controllers/place.controller.dart';
import 'package:tripper/core/models/download.model.dart';
import 'package:tripper/core/models/place.model.dart';
import 'package:tripper/core/models/trip.model.dart';
import 'package:tripper/ui/utils/show-message.dart';

class DownloadProvider extends ChangeNotifier {
  DownloadController controller = DownloadController();
  PlaceController placeController = PlaceController();
  bool isDownloading = false;
  int totalContentLength = 0;
  int downloadedContentLength = 0;
  double downloadPercentage = 0;

  DownloadProvider() {
    init().then((v) => print('downloadprovider init'));
  }

  List<Download> get downloads {
    return controller.downloads;
  }

  Future<void> init() async {
    await controller.init();
    notifyListeners();
  }

  Future<void> createLocal(Download download) async {
    download.id = '${download.tripId}-${download.placeId}';
    await controller.createLocal(download);
    notifyListeners();
  }

  Future<void> createByTrip(Trip trip, BuildContext context) async {
    //TODO: check network connectivity and ask for confirmation if not wifi
    totalContentLength = 0;
    downloadPercentage = 0;
    downloadedContentLength = 0;
    for (Place place in trip.places) {
      if (!existsByPlace(place.id)) {
        await downloadByPlace(place, context);
      }
    }
  }

  Future<void> createByPlace(Place place, BuildContext context) async {
    //TODO: check network connectivity and ask for confirmation if not wifi
    totalContentLength = 0;
    downloadPercentage = 0;
    downloadedContentLength = 0;
    await downloadByPlace(place, context);
  }

  Future downloadByPlace(Place place, BuildContext context) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    isDownloading = true;
    notifyListeners();
    List<List<int>> chunks = new List();
    String filename = path.basename(Uri.parse(place.fullAudioUrl).path);
    Directory fileDir = Directory('$dir/${place.tripId}/${place.id}')
      ..create(recursive: true);
    String finalFilePath = '${fileDir.path}/$filename';

    placeController.downloadFullAudio(place).asStream().listen(
      (r) async {
        if (r.statusCode == HttpStatus.ok) {
          totalContentLength += r.contentLength;
          r.stream.listen(
            (List<int> chunk) {
              downloadPercentage = downloadedContentLength / totalContentLength;
              downloadedContentLength += chunk.length;
              chunks.add(chunk);
              notifyListeners();
            },
            onDone: () async {
              downloadPercentage = downloadedContentLength / totalContentLength;
              notifyListeners();

              File file = new File(finalFilePath);
              final Uint8List bytes = Uint8List(r.contentLength);
              int offset = 0;
              for (List<int> chunk in chunks) {
                bytes.setRange(offset, offset + chunk.length, chunk);
                offset += chunk.length;
              }
              //TODO:save file encrypted, not flat
              file = await file.writeAsBytes(bytes);
              isDownloading = false;
              await createLocal(
                Download(
                    tripId: place.tripId,
                    placeId: place.id,
                    filePath: file.path),
              );
            },
            onError: (error) async {
              isDownloading = false;
              notifyListeners();
              showMessage(context, 'something went wrong!', false);
            },
          );
        } else {
          isDownloading = false;
          notifyListeners();
          showMessage(context, 'something went wrong!!', false);
        }
      },
    );
  }

  Future<void> updateLocal(Download download) async {
    await controller.updateLocal(download);
    notifyListeners();
  }

  Future<void> deleteLocal(Download download) async {
    await controller.deleteLocal(download);
    notifyListeners();
  }

  Future<void> deleteByTrip(int id) async {
    controller.downloads.where((d) => d.tripId == id).forEach((download) async {
      // try {
      File(download.filePath).deleteSync();
      // } catch (_) {}
      await controller.deleteLocal(download);
    });
    notifyListeners();
  }

  Future<void> deleteByPlace(int id) async {
    controller.downloads
        .where((d) => d.placeId == id)
        .forEach((download) async {
      await File(download.filePath).delete();
      await controller.deleteLocal(download);
    });
    notifyListeners();
  }

  List<Download> getByTrip(int id) {
    return controller.downloads.where((d) => d.tripId == id).toList();
  }

  List<Download> getByPlace(int id) {
    return controller.downloads.where((d) => d.placeId == id).toList();
  }

  bool existsByTrip(int id, int placesQty) {
    return controller.existsByTrip(id, placesQty);
  }

  bool existsByPlace(int id) {
    return controller.existsByPlace(id);
  }
}
