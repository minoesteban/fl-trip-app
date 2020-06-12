import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripit/components/poi/poi_card.dart';
import 'package:tripit/models/trip_model.dart';

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

    print('selectedTrip $selectedTrip ');
    print('selectedPlaceId $selectedPlaceId');

    //If user selected a Trip (and not a Marker), I show all trip's pois
    if (selectedTrip != null) {
      _trips.add(selectedTrip);
    }

    if (selectedTrip == null && selectedPlaceId != null) {
      _trips.addAll(trips.where((trip) =>
          trip.pois.where((poi) => poi.placeId == selectedPlaceId).length > 0));
    }

    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: InkWell(
              onTap: () => handleChangeSlidePanelViewItemType('trip'),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.arrow_back_ios,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    selectedPlaceName != null
                        ? "$selectedPlaceName's trips"
                        : "${selectedTrip.name}'s places",
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
          ),
          Expanded(
            child: ListView.separated(
//              shrinkWrap: true,
              itemCount: _trips.length,
              itemBuilder: (context, index) {
                return PoiCard(
                  selectedPlaceId: selectedPlaceId,
                  trip: _trips[index],
                  userPosition: userPosition,
                  mapController: mapController,
                );
              },
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
