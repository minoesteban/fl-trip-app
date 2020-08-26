import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../../core/utils/utils.dart';
import '../../core/models/trip.model.dart';
import '../../config.dart';

class TripService {
  Map<String, String> _headers = {
    'content-type': 'application/json',
    'charset': 'UTF-8'
  };
  String _endpoint = Platform.isAndroid ? API_ENDPOINT_ANDROID : API_ENDPOINT;

  Future<List<Trip>> getAll() async {
    final res = await http.get('$_endpoint/trips/all', headers: _headers);
    if (res.statusCode == HttpStatus.ok) {
      return await parseList(res.body);
    } else
      throw HttpException(res.body);
  }

  Future<Trip> create(Trip trip) async {
    String url = '$_endpoint/trips';
    final res = await http.post(url,
        headers: _headers, body: json.encode(trip.toMapForDB()));
    if (res.statusCode == HttpStatus.ok)
      return await parse(res.body);
    else
      throw HttpException(res.body);
  }

  Future<Trip> submit(int id) async {
    String url = '$_endpoint/trips/$id';
    final res = await http.patch(url,
        headers: _headers, body: json.encode({'submitted': true}));
    if (res.statusCode == HttpStatus.ok) {
      return await parse(res.body);
    } else {
      throw HttpException(res.body);
    }
  }

  Future<Trip> update(Trip trip) async {
    String url = '$_endpoint/trips/${trip.id}';
    final res = await http.patch(url,
        headers: _headers, body: json.encode(trip.toMapForDB()));
    if (res.statusCode == HttpStatus.ok) {
      return await parse(res.body);
    } else {
      throw HttpException(res.body);
    }
  }

  Future<void> delete(int id) async {
    String url = '$_endpoint/trips/$id';
    final res = await http.delete(url);
    if (res.statusCode != HttpStatus.ok) {
      throw HttpException(res.body);
    }
  }

  Future<Trip> parse(String data) async {
    final decoded = json.decode(json.encode(json.decode(data)));
    return Trip.fromMap(decoded['trip']);
  }

  Future<List<Trip>> parseList(String data) async {
    final decoded = json.decode(json.encode(json.decode(data)));
    List<Trip> _trips = [];

    await decoded['trips']?.forEach(
        (json) => Trip.fromMap(json).then((trip) => _trips.add(trip)));

    return _trips;
  }

  Future<String> uploadImage(int id, File pickedFile) async {
    String fileExtension = path.extension(pickedFile.path).substring(1);
    String url = '$_endpoint/trips/$id/files?type=$fileExtension';
    var res = await http.put(url);
    if (res.statusCode == HttpStatus.ok) {
      String downloadUrl = json.decode(res.body)['downloadUrl'];
      File file = File(pickedFile.path);

      file = await compress(file);

      res = await http.put(json.decode(res.body)['uploadUrl'],
          body: file.readAsBytesSync());
      if (res.statusCode == HttpStatus.ok) {
        String url = '$_endpoint/trips/$id';
        final res = await http.patch(url,
            headers: _headers, body: json.encode({'imageUrl': downloadUrl}));
        if (res.statusCode == HttpStatus.ok) {
          return json.decode(res.body)['trip']['imageUrl'];
        } else {
          throw HttpException(res.body);
        }
      } else
        throw HttpException(res.body);
    } else
      throw HttpException(res.body);
  }

  Future<String> uploadAudio(int id, File audio) async {
    String fileExtension = path.extension(audio.path).substring(1);
    String url = '$_endpoint/trips/$id/files?type=$fileExtension';
    var res = await http.put(url);
    if (res.statusCode == HttpStatus.ok) {
      String downloadUrl = json.decode(res.body)['downloadUrl'];
      res = await http.put(json.decode(res.body)['uploadUrl'],
          body: audio.readAsBytesSync());
      if (res.statusCode == HttpStatus.ok) {
        String url = '$_endpoint/trips/$id';
        res = await http.patch(url,
            headers: _headers,
            body: json.encode({'previewAudioUrl': downloadUrl}));
        if (res.statusCode == HttpStatus.ok) {
          return json.decode(res.body)['trip']['previewAudioUrl'];
        } else {
          throw HttpException(res.toString());
        }
      } else
        throw HttpException(res.body);
    } else
      throw HttpException(res.body);
  }
}
