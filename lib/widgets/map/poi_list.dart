import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripit/models/trip_model.dart';

import 'poi_card.dart';

class PoiList extends StatelessWidget {
  final List<Trip> trips;
  final Trip selectedTrip;
  final String selectedPlaceId;
  final String selectedPlaceName;
  final Position userPosition;
  final Future<GoogleMapController> mapController;
  final Function(String) handleChangeSlidePanelViewItemType;

  PoiList(
      {this.trips,
      this.selectedTrip,
      this.selectedPlaceId,
      this.selectedPlaceName,
      this.userPosition,
      this.mapController,
      this.handleChangeSlidePanelViewItemType});

  @override
  Widget build(BuildContext context) {
    List<Trip> _trips = [];

    print('PoiList - selectedTrip $selectedTrip ');
    print('PoiList - selectedPlaceId $selectedPlaceId');

    //If user selected a Trip (and not a Marker), I show all trip's pois
    if (selectedTrip != null) {
      _trips.add(selectedTrip);
    }

    if (selectedTrip == null && selectedPlaceId != null) {
      _trips.addAll(trips.where((trip) =>
          trip.pois.where((poi) => poi.placeId == selectedPlaceId).length > 0));
    }

    return Container(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
            child: InkWell(
              onTap: () => handleChangeSlidePanelViewItemType('trip'),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.arrow_back_ios,
                    size: 16,
                    color: Colors.grey[800],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'all trips',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.grey[800],
                        fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _trips.length,
              itemBuilder: (context, index) {
                return PoiCard(
                  selectedPlaceId: selectedPlaceId,
                  trip: _trips[index],
                  userPosition: userPosition,
                  mapController: mapController,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
