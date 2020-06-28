import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripit/components/store/rating_overview.dart';
import 'package:tripit/models/poi_model.dart';
import 'package:tripit/models/trip_model.dart';

import 'trip_item_actions_menu.dart';

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

    return LayoutBuilder(
      builder: (ctx, cns) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 1),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: InkWell(
            onTap: () =>
                Navigator.pushNamed(context, '/store/trip-main', arguments: {
              'trip': this.trip,
              'userPosition': this.userPosition,
            }),
            child: Stack(alignment: Alignment.topCenter, children: [
              Container(
                height: cns.maxHeight,
                width: cns.maxHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  child: Image.asset(
                    'assets/images/${trip.country.toLowerCase()}/${_poi.image}',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: cns.maxHeight,
                width: cns.maxHeight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      //trip name, menu button
                      Text(
                        '${trip.name}',
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        style: TextStyle(
                            shadows: [
                              Shadow(
                                  offset: Offset.fromDirection(
                                15,
                              ))
                            ],
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      //rating and language flag
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            child: Flag(
                              trip.language.toUpperCase(),
                              height: 25,
                              width: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          RatingOverview(trip),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
