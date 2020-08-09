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
                            0));

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

class PlaceCard extends StatefulWidget {
  final Trip trip;
  final String selectedPlaceId;

  PlaceCard({this.trip, this.selectedPlaceId});

  @override
  _PlaceCardState createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard>
    with SingleTickerProviderStateMixin {
  AnimationController _playPauseController;
  UserProvider _userProvider;
  LanguageProvider _languageProvider;

  @override
  void initState() {
    super.initState();
    _playPauseController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _languageProvider = Provider.of<LanguageProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _playPauseController.dispose();
    super.dispose();
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
                _userProvider.tripIsPurchased(widget.trip.id)
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
                            'got it!',
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
                                    bottomLeft: Radius.circular(10),
                                  ),
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
                            widget.trip.languageFlagId.toUpperCase(),
                            height: 25,
                            width: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          '${_languageProvider.getNativeName(widget.trip.languageNameId)}',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
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
