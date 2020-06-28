import 'dart:async';

import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripit/models/trip_model.dart';

import 'trip_item_actions_menu.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final Position userPosition;
  final Future<GoogleMapController> mapController;

  TripCard({this.trip, this.userPosition, this.mapController});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: _navigateToCity,
              child: Container(
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 10, bottom: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                //trip name, menu button
                Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${trip.name}',
                        style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      TripOptions(trip: trip),
                    ],
                  ),
                ),

                //trip city, country and cost
                Padding(
                  padding: const EdgeInsets.only(right: 15, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${trip.city}, ${trip.country}',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black38,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        trip.price > 0 ? '\$ ${trip.price}' : 'Free',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
                //rating and language flag
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          RatingBarIndicator(
                            itemPadding: EdgeInsets.all(0),
                            rating: trip.tripRating,
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 22.0,
                          ),
                          Text(
                            '(1.460)',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10),
                          ),
                        ],
                      ),
                      Flag(
                        trip.language.toUpperCase(),
                        height: 20,
                        width: 35,
                        fit: BoxFit.fill,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToCity() async {
    GoogleMapController _mc;
    this.mapController.then((value) {
      _mc = value;
      _mc.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(trip.region.latitude, trip.region.longitude), 13));
    });
  }
}
