import 'dart:io';

import 'package:hive/hive.dart';
import 'package:tripper/core/models/download.model.dart';

class DownloadController {
  Box<Download> downloadBox; //Box<Download>

  List<Download> get downloads {
    return downloadBox.values.toList();
  }

  List<String> get ids {
    return downloadBox.values.map((e) => e.id).toList()..sort();
  }

  Future<void> init() async {
    downloadBox = await Hive.openBox('downloads');
  }

  Future<void> createLocal(Download download) async {
    return await updateLocal(download);
  }

  Future<void> updateLocal(Download download) async {
    await downloadBox.put(download.id, download);
  }

  Future<void> deleteLocal(Download download) async {
    await downloadBox.delete(download.id);
  }

  bool existsByTrip(int id, int placesQty) {
    bool exists = true;
    var downloads = downloadBox.values.where((d) => d.tripId == id).toList();
    if (downloads.length > 0 && downloads.length >= placesQty)
      downloads.forEach((d) {
        if (!File(d.filePath).existsSync()) {
          exists = false;
          deleteLocal(d);
        }
      });
    else
      exists = false;
    return exists;
  }

  bool existsByPlace(int id) {
    bool exists = true;
    var downloads = downloadBox.values.where((d) => d.placeId == id).toList();
    if (downloads.length > 0)
      downloads.forEach((d) {
        if (!File(d.filePath).existsSync()) {
          exists = false;
          deleteLocal(d);
        }
      });
    else
      exists = false;
    return exists;
  }
}
