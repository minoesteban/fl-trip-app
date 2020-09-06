import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tripit/core/controllers/download.controller.dart';
import 'package:tripit/core/controllers/place.controller.dart';
import 'package:tripit/core/models/download.model.dart';
import 'package:tripit/core/models/place.model.dart';
import 'package:tripit/core/models/trip.model.dart';
import 'package:tripit/ui/utils/show-message.dart';

class DownloadProvider extends ChangeNotifier {
  DownloadController controller = DownloadController();
  PlaceController placeController = PlaceController();
  bool isDownloading = false;
  double totalContentLength = 0;
  double downloadPercentage = 0;

  List<Download> get downloads {
    return controller.downloads;
  }

  Future<void> init() async {
    await controller.init();
    notifyListeners();
  }

  Future<void> createLocal(Download download) async {
    download.id = 1;
    var ids = controller.ids;
    if (ids.length > 0) download.id = ids.last + 1;

    await controller.createLocal(download);
    notifyListeners();
  }

  Future<void> createByTrip(Trip trip, BuildContext context) async {
    //TODO: check network connectivity and ask for confirmation if not wifi
    String dir = (await getApplicationDocumentsDirectory()).path;
    isDownloading = true;
    totalContentLength = 0;
    downloadPercentage = 0;
    int downloaded = 0;
    notifyListeners();
    for (Place place in trip.places) {
      List<List<int>> chunks = new List();
      String filename = path.basename(Uri.parse(place.fullAudioUrl).path);
      Directory fileDir = Directory('$dir/${trip.id}/${place.id}')
        ..create(recursive: true);
      String finalFilePath = '${fileDir.path}/$filename';

      var response = placeController.downloadFullAudio(place);

      response.asStream().listen(
        (r) async {
          if (r.statusCode == HttpStatus.ok) {
            totalContentLength += r.contentLength;
            r.stream.listen(
              (List<int> chunk) {
                downloadPercentage = downloaded / totalContentLength;
                downloaded += chunk.length;
                chunks.add(chunk);
                notifyListeners();
              },
              onDone: () async {
                downloadPercentage = downloaded / totalContentLength;
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
                notifyListeners();
                await createLocal(Download(
                    tripId: trip.id, placeId: place.id, filePath: file.path));
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
    return controller.downloads.where((d) => d.tripId == id);
  }

  List<Download> getByPlace(int id) {
    return controller.downloads.where((d) => d.placeId == id);
  }

  bool existsByTrip(int id) {
    return controller.existsByTrip(id);
  }

  bool existsByPlace(int id) {
    return controller.existsByPlace(id);
  }
}
