import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripit/models/trip_model.dart';

import 'trip_card.dart';

class TripList extends StatelessWidget {
  final List<Trip> trips;
  final Position userPosition;
  final Future<GoogleMapController> mapController;
  final ScrollController sc;
  TripList({this.trips, this.userPosition, this.mapController, this.sc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(15,10,15,0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView.builder(
              controller: sc,
              itemCount: trips.length,
              itemBuilder: (context, index) => TripCard(
                trip: trips[index],
                userPosition: userPosition,
                mapController: mapController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
