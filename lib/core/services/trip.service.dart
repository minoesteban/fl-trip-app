import 'dart:convert';
import 'dart:io';
import 'package:tripit/core/models/trip.model.dart';
import 'package:tripit/config.dart';
import 'package:http/http.dart' as http;

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
}

// Future<ServiceResponse> submitTrip(Trip newTrip) async {
//   String url = '$_endpoint/trip';
//   try {
//     final res = await http.post(url,
//         headers: _headers, body: json.encode(newTrip.toMap()));
//     Trip createdTrip = await parse(res.body);
//     if (newTrip.places.length > 0) {
//       ServiceResponse response =
//           await _placeService.createMulti(newTrip.places);
//       createdTrip.places = response.hasItems ? response.items : [];
//       return ServiceResponse(
//           [createdTrip], response.hasErrors ? response.errors : []);
//     } else
//       return ServiceResponse([createdTrip], []);
//   } catch (e) {
//     throw e;
//   }
// }
