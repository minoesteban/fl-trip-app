import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripit/core/models/place.model.dart';
import 'package:tripit/core/models/trip.model.dart';
import '../screens/trip-main.dart';

class PlaceList extends StatelessWidget {
  final List<Trip> trips;
  final Trip selectedTrip;
  final String selectedPlaceId;
  final String selectedPlaceName;
  final Position userPosition;
  final Future<GoogleMapController> mapController;

  PlaceList({
    this.trips,
    this.selectedTrip,
    this.selectedPlaceId,
    this.selectedPlaceName,
    this.userPosition,
    this.mapController,
  });

  @override
  Widget build(BuildContext context) {
    List<Trip> _trips = [];

    //If user selected a Trip (and not a Marker), I show all trip's places
    if (selectedTrip != null) {
      _trips.add(selectedTrip);
    }

    if (selectedTrip == null && selectedPlaceId != null) {
      _trips.addAll(trips.where((trip) =>
          trip.places
              .where((place) => place.googlePlaceId == selectedPlaceId)
              .length >
          0));
    }

    return Container(
      padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
      child: Column(
        children: <Widget>[
          selectedPlaceId == null
              ? Expanded(
                  child: Center(child: Text('tap a place to check its trips!')))
              : Expanded(
                  child: PageView.builder(
                    itemCount: _trips.length,
                    itemBuilder: (context, index) {
                      return PlaceCard(
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

class PlaceCard extends StatefulWidget {
  final Trip trip;
  final String selectedPlaceId;
  final Position userPosition;
  final Future<GoogleMapController> mapController;

  PlaceCard(
      {this.trip, this.selectedPlaceId, this.userPosition, this.mapController});

  @override
  _PlaceCardState createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> with TickerProviderStateMixin {
  AnimationController _playPauseController;

  @override
  void initState() {
    super.initState();
    _playPauseController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    Place _place = widget.trip.places
        .firstWhere((place) => place.googlePlaceId == widget.selectedPlaceId);

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: InkWell(
          onTap: () =>
              Navigator.pushNamed(context, TripMain.routeName, arguments: {
            'trip': this.widget.trip,
            'userPosition': this.widget.userPosition,
          }),
          child: GridTile(
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: Stack(fit: StackFit.expand,
                  // alignment: Alignment.topRight,
                  children: [
                    CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: '${_place.pictureUrl1}',
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 0.5,
                          valueColor: AlwaysStoppedAnimation(Colors.grey[100]),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    //TODO: get purchased state for a trip / place (purchase table? or collection in user?)
                    //widget.trip.purchased
                    false
                        ? Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10)),
                                  color: Colors.green),
                              height: 25,
                              width: 50,
                              child: Text(
                                'saved',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        : _place.price == 0
                            ? Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10)),
                                      color: Colors.grey[500]),
                                  height: 25,
                                  width: 50,
                                  child: Text(
                                    'free!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            : null,
                  ]),
            ),
            footer: Container(
              color: Colors.black38,
              child: GridTileBar(
                title: Text(
                  '${_place.name}',
                  textAlign: TextAlign.start,
                  softWrap: true,
                  maxLines: 2,
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: Text(
                  '${widget.trip.name}',
                  textAlign: TextAlign.start,
                  softWrap: true,
                  maxLines: 2,
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          //TODO: obtener rating del trip
                          // '${widget.trip.tripRating.toStringAsPrecision(2)}',
                          '7.6',
                          style: TextStyle(
                              color: Colors.amber[500],
                              fontWeight: FontWeight.bold,
                              fontSize: 24),
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.amber[500],
                          size: 15,
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      child: Flag(
                        widget.trip.languageFlagId.toUpperCase(),
                        height: 25,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      onPressed: () {
                        _playPauseController.isDismissed
                            ? _playPauseController.forward()
                            : _playPauseController.reverse();
                      },
                      iconSize: 40,
                      icon: AnimatedIcon(
                        icon: AnimatedIcons.play_pause,
                        progress: _playPauseController,
                      ),
                      color: Colors.green[500],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
