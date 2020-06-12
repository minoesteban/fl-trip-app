import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripit/components/trip/trip_card.dart';
import 'package:tripit/models/trip_model.dart';

class TripList extends StatelessWidget {
  final List<Trip> trips;
  final Position userPosition;
  final Future<GoogleMapController> mapController;
  final ScrollController sc;
  TripList({this.trips, this.userPosition, this.mapController, this.sc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 12,
                ),
                Text(
                  'all trips',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey[600],
                      fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: sc,
//              shrinkWrap: true,
              itemCount: trips.length,
              itemBuilder: (context, index) => TripCard(
                trip: trips[index],
                userPosition: userPosition,
                mapController: mapController,
              ),
              separatorBuilder: (context, index) => Divider(
                color: Colors.black54,
                indent: 20,
                endIndent: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
