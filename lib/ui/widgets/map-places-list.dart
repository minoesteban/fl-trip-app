import 'package:cached_network_image/cached_network_image.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/language.provider.dart';
import '../../providers/trip.provider.dart';
import '../../providers/user.provider.dart';
import '../../core/models/place.model.dart';
import '../../core/models/trip.model.dart';
import '../screens/trip-main.dart';
import 'audio-components.dart';

class PlaceList extends StatelessWidget {
  final String selectedPlaceId;

  PlaceList({
    this.selectedPlaceId,
  });

  @override
  Widget build(BuildContext context) {
    List<Trip> _trips = [];

    return Container(
      padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
      child: Column(
        children: <Widget>[
          selectedPlaceId == null
              ? Expanded(
                  child: Center(child: Text('tap a place to check its trips!')))
              : Expanded(
                  child: Consumer<TripProvider>(
                    builder: (context, _tripProvider, _) {
                      if (selectedPlaceId != null)
                        _trips.addAll(_tripProvider.trips.where((trip) =>
                            trip.places
                                    .where((place) =>
                                        place.googlePlaceId == selectedPlaceId)
                                    .length >
                                0 &&
                            trip.published));

                      return PageView.builder(
                        itemCount: _trips.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder(
                            future: _tripProvider
                                .getAndSetTripRatings(_trips[index].id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done)
                                return PlaceCard(
                                  selectedPlaceId: selectedPlaceId,
                                  trip: _trips[index],
                                );
                              else
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class PlaceCard extends StatelessWidget {
  final Trip trip;
  final String selectedPlaceId;

  PlaceCard({this.trip, this.selectedPlaceId});

  @override
  Widget build(BuildContext context) {
    Place _place = trip.places
        .firstWhere((place) => place.googlePlaceId == selectedPlaceId);

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
            'trip': trip,
          }),
          child: GridTile(
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: Stack(fit: StackFit.expand, children: [
                CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: '${_place.imageUrl}',
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 0.5,
                      valueColor: AlwaysStoppedAnimation(Colors.grey[100]),
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.only(bottomLeft: Radius.circular(10)),
                        color: Provider.of<UserProvider>(context, listen: false)
                                .tripIsPurchased(trip.id)
                            ? Colors.green
                            : Colors.grey[500]),
                    height: 25,
                    width: 50,
                    child: Text(
                      Provider.of<UserProvider>(context, listen: false)
                              .tripIsPurchased(trip.id)
                          ? 'got it!'
                          : _place.price == 0
                              ? 'free!'
                              : '\$ ${trip.price.toStringAsPrecision(3)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                  ),
                ),
                subtitle: Text(
                  '${trip.name}',
                  textAlign: TextAlign.start,
                  softWrap: true,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                  ),
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
                          '${_place.rating.rating.toStringAsPrecision(2)}',
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
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                          child: Flag(
                            trip.languageFlagId.toUpperCase(),
                            height: 25,
                            width: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          Provider.of<LanguageProvider>(context, listen: false)
                              .getNativeName(trip.languageNameId),
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    const SizedBox(width: 10),
                    Player(_place.previewAudioUrl, false),
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
