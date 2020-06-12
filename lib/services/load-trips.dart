import 'dart:async' show Future;
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:tripit/models/trip_model.dart';

Future loadTrips(Position _userPosition) async {
  List<Trip> trips = [];

  String jsonString = await rootBundle.loadString('assets/trips-file.json');
  final jsonResponse = jsonDecode(jsonString);
  for (var i = 0; i < jsonResponse.length; i++) {
    trips.add(Trip.fromJson(jsonResponse[i]));
  }

  return trips;
}
