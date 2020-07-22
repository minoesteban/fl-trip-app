import 'dart:async';

import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tripit/providers/trips-provider.dart';
import 'trip-item-actions-menu.dart';

class TripList extends StatelessWidget {
  final Future<GoogleMapController> mapController;
  final ScrollController srollController;
  TripList({this.mapController, this.srollController});

  @override
  Widget build(BuildContext context) {
    var trips = Provider.of<Trips>(context).trips;

    return Container(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView.builder(
              controller: srollController,
              itemCount: trips.length,
              itemBuilder: (context, index) => ChangeNotifierProvider.value(
                value: trips[index],
                child: TripCard(
                  trips[index].id,
                  mapController: mapController,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  final String tripId;
  final Future<GoogleMapController> mapController;

  TripCard(this.tripId, {this.mapController});

  @override
  Widget build(BuildContext context) {
    var trip = Provider.of<Trips>(context).findById(tripId);

    void _navigateToCity() async {
      GoogleMapController _mc;
      this.mapController.then((value) {
        _mc = value;
        _mc.animateCamera(CameraUpdate.newLatLngZoom(
            LatLng(trip.region.latitude, trip.region.longitude), 13));
      });
    }

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
                                fontWeight: FontWeight.bold, fontSize: 10),
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
}
