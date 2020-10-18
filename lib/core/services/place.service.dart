import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:tripper/providers/credentials.provider.dart';
import '../../config.dart';
import '../../core/utils/utils.dart';
import '../../core/models/place.model.dart';

class PlaceService {
  Map<String, String> _headers = {'content-type': 'application/json'};
  String _endpoint = Platform.isAndroid ? API_ENDPOINT_ANDROID : API_ENDPOINT;

  Future<Place> create(Place place) async {
    String url = '$_endpoint/trips/${place.tripId}/places';
    var _headersWithKey = _headers..addAll({'x-api-key': getKey('gk')});
    final res = await http.post(url,
        headers: _headersWithKey, body: json.encode(place.toMapForDB()));
    if (res.statusCode == HttpStatus.ok)
      return await parsePlace(res.body);
    else
      throw HttpException(res.body);
  }

  Future<Place> update(Place place) async {
    String url = '$_endpoint/trips/${place.tripId}/places/${place.id}';
    var _headersWithKey = _headers..addAll({'x-api-key': getKey('gk')});
    final res = await http.patch(url,
        headers: _headersWithKey, body: json.encode(place.toMapForDB()));
    if (res.statusCode == HttpStatus.ok)
      return await parsePlace(res.body);
    else
      throw HttpException(res.body);
  }

  Future<void> delete(int tripId, int placeId) async {
    String url = '$_endpoint/trips/$tripId/places/$placeId';
    final res = await http.delete(url);
    if (res.statusCode != HttpStatus.ok) throw HttpException(res.body);
  }

  Future<void> order(Place place) async {
    String url = '$_endpoint/trips/${place.tripId}/places/${place.id}';
    var _headersWithKey = _headers..addAll({'x-api-key': getKey('gk')});
    final res = await http.patch(url,
        headers: _headersWithKey, body: json.encode({'order': place.order}));
    if (res.statusCode != HttpStatus.ok) throw HttpException(res.body);
  }

  Future<Place> parsePlace(String data) async {
    final decoded = json.decode(json.encode(json.decode(data)));
    return Place.fromMap(decoded['place']);
  }

  Future<String> uploadImage(int tripId, int id, File image) async {
    String fileExtension = path.extension(image.path).substring(1);
    String url =
        '$_endpoint/trips/$tripId/places/$id/files?type=$fileExtension';
    var _headersJustKey = {'x-api-key': getKey('gk')};
    var res = await http.put(url, headers: _headersJustKey);
    if (res.statusCode == HttpStatus.ok) {
      String downloadUrl = json.decode(res.body)['downloadUrl'];
      File file = File(image.path);

      file = await compress(file);

      res = await http.put(json.decode(res.body)['uploadUrl'],
          body: file.readAsBytesSync());
      if (res.statusCode == HttpStatus.ok) {
        String url = '$_endpoint/trips/$tripId/places/$id';
        var _headersWithKey = _headers..addAll({'x-api-key': getKey('gk')});
        final res = await http.patch(url,
            headers: _headersWithKey,
            body: json.encode({'imageUrl': downloadUrl}));
        if (res.statusCode == HttpStatus.ok) {
          return json.decode(res.body)['place']['imageUrl'];
        } else {
          throw HttpException(res.body);
        }
      } else
        throw HttpException(res.body);
    } else
      throw HttpException(res.body);
  }

  Future<String> uploadAudio(
      int tripId, int id, File audio, bool isFullAudio) async {
    String fileExtension = path.extension(audio.path).substring(1);
    String url =
        '$_endpoint/trips/$tripId/places/$id/files?type=$fileExtension;isFull=$isFullAudio';
    var _headersJustKey = {'x-api-key': getKey('gk')};
    var res = await http.put(url, headers: _headersJustKey);
    if (res.statusCode == HttpStatus.ok) {
      String downloadUrl = json.decode(res.body)['downloadUrl'];
      res = await http.put(json.decode(res.body)['uploadUrl'],
          body: audio.readAsBytesSync());
      if (res.statusCode == HttpStatus.ok) {
        String url = '$_endpoint/trips/$tripId/places/$id';
        var _headersWithKey = _headers..addAll({'x-api-key': getKey('gk')});
        res = await http.patch(
          url,
          headers: _headersWithKey,
          body: isFullAudio
              ? json.encode({'fullAudioUrl': downloadUrl})
              : json.encode({'previewAudioUrl': downloadUrl}),
        );
        if (res.statusCode == HttpStatus.ok) {
          return isFullAudio
              ? json.decode(res.body)['place']['fullAudioUrl']
              : json.decode(res.body)['place']['previewAudioUrl'];
        } else {
          throw HttpException(res.toString());
        }
      } else
        throw HttpException(res.body);
    } else
      throw HttpException(res.body);
  }

  Future<StreamedResponse> downloadFullAudio(Place place) async {
    try {
      return await downloadFile(await getDownloadUrl(place.fullAudioUrl, true));
    } catch (err) {
      throw err;
    }
  }

  Future<String> getDownloadUrl(String fileUrl, bool isFullAudio) async {
    List<String> pathSegments = Uri.parse(fileUrl).pathSegments;
    int tripId =
        int.tryParse(pathSegments.elementAt(pathSegments.indexOf('trips') + 1));
    int id = int.tryParse(
        pathSegments.elementAt(pathSegments.indexOf('places') + 1));
    String fileExtension = path.extension(Uri.parse(fileUrl).path).substring(1);
    String fileName = path.basenameWithoutExtension(Uri.parse(fileUrl).path);

    if (tripId == null ||
        id == null ||
        fileExtension == null ||
        fileName == null) throw 'there is something wrong with the file URL';

    String url =
        '$_endpoint/trips/$tripId/places/$id/files?type=$fileExtension;isFull=$isFullAudio;filename=$fileName';
    var _headersJustKey = {'x-api-key': getKey('gk')};
    var res = await http.get(url, headers: _headersJustKey);
    if (res.statusCode == HttpStatus.ok) {
      return json.decode(res.body)['downloadUrl'];
    } else {
      throw HttpException(res.body.toString());
    }
  }

  Future<StreamedResponse> downloadFile(String url) async {
    var httpClient = http.Client();
    var request = new http.Request('GET', Uri.parse(url));
    return await httpClient.send(request);
  }
}
