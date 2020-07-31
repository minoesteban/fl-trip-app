import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../../config.dart';
import '../../core/models/place.model.dart';

class PlaceService {
  Map<String, String> _headers = {'content-type': 'application/json'};

  Future<Place> create(Place place) async {
    String url = '$API_ENDPOINT/trip/${place.tripId}/place';
    final res = await http.post(url,
        headers: _headers, body: json.encode(place.toMap()));
    if (res.statusCode == HttpStatus.ok) {
      return await parsePlace(res.body);
    } else {
      throw HttpException(res.body);
    }
  }

  Future<Place> update(Place place) async {
    String url = '$API_ENDPOINT/trip/${place.id}';
    final res = await http.patch(url,
        headers: _headers, body: json.encode(place.toMap()));
    if (res.statusCode == HttpStatus.ok) {
      return json.decode(res.body)['item'][1];
    } else {
      throw HttpException(res.body);
    }
  }

  Future<Place> parsePlace(String data) async {
    final decoded = json.decode(data);
    return Place.fromMap(decoded['place']);
  }
}
