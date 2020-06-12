import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripit/components/trip/trip_item_actions_menu.dart';
import 'package:tripit/models/poi_model.dart';
import 'package:tripit/models/trip_model.dart';

class PoiCard extends StatelessWidget {
  final Trip trip;
  final String selectedPlaceId;
  final Position userPosition;
  final Future<GoogleMapController> mapController;

  PoiCard(
      {this.trip, this.selectedPlaceId, this.userPosition, this.mapController});

  @override
  Widget build(BuildContext context) {
    Poi _poi = trip.pois.firstWhere((poi) => poi.placeId == selectedPlaceId);

    return Card(
      elevation: 0,
      child: Container(
        height: MediaQuery.of(context).orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height / 5.8
            : MediaQuery.of(context).size.width / 5.8,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      '${_poi.name}',
                      style: TextStyle(
                          color: Colors.grey[800],
                          fontFamily: 'Nunito',
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _poi.price > 0 ? '\$ ${_poi.price}' : 'Free',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TripOptions(trip: trip),
                      ],
                    ),
                  ],
                ),
              ),

              //trip city, country and cost
              Padding(
                padding: const EdgeInsets.only(right: 20, bottom: 8, left: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '${trip.name}',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          color: Colors.black38,
                          fontWeight: FontWeight.bold),
                    ),
                    Flag(
                      trip.language.toUpperCase(),
                      height: 22,
                      width: 40,
                      fit: BoxFit.fill,
                    ),
                  ],
                ),
              ),
              //rating and language flag
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        RatingBarIndicator(
                          itemPadding: EdgeInsets.all(0),
                          rating: _poi.rating,
                          itemBuilder: (context, index) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 25.0,
//                          direction: Axis.vertical,
                        ),
                        Text(
                          '(1.460)',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.play_circle_outline,
                      color: Colors.green[600],
                      size: 30,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
