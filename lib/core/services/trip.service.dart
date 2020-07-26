import 'dart:convert';
import 'dart:io';
import 'package:tripit/core/models/trip.model.dart';
import 'package:tripit/config.dart';
import 'package:http/http.dart' as http;

class TripService {
  Future<List<Trip>> getAllTrips() async {
    print('llamo API get all trips');
    final res = await http.get('$API_ENDPOINT/trip/all');
    if (res.statusCode == HttpStatus.ok)
      return await parseTrips(res.body);
    else
      throw Exception('Error ${res.statusCode} : ${res.body}');
  }

  Future<List<Trip>> parseTrips(String data) async {
    final decoded = json.decode(data);
    List<Trip> _trips = [];

    await decoded['trips']?.forEach(
        (json) => Trip.fromMap(json).then((trip) => _trips.add(trip)));

    return _trips;
  }
}
