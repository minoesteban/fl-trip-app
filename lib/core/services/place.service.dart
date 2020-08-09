import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../../config.dart';
import '../../core/models/place.model.dart';

class PlaceService {
  Map<String, String> _headers = {'content-type': 'application/json'};
  String _endpoint = Platform.isAndroid ? API_ENDPOINT_ANDROID : API_ENDPOINT;

  Future<Place> create(Place place) async {
    String url = '$_endpoint/trips/${place.tripId}/places';
    final res = await http.post(url,
        headers: _headers, body: json.encode(place.toMapForDB()));
    if (res.statusCode == HttpStatus.ok)
      return await parsePlace(res.body);
    else
      throw HttpException(res.body);
  }

  Future<Place> update(Place place) async {
    String url = '$_endpoint/trips/${place.tripId}/places/${place.id}';
    final res = await http.patch(url,
        headers: _headers, body: json.encode(place.toMapForDB()));
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
    final res = await http.patch(url,
        headers: _headers, body: json.encode({'order': place.order}));
    if (res.statusCode != HttpStatus.ok) throw HttpException(res.body);
  }

  Future<Place> parsePlace(String data) async {
    final decoded = json.decode(json.encode(json.decode(data)));
    return Place.fromMap(decoded['place']);
  }
}
