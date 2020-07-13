import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tripit/core/place/place-model.dart';
import 'package:tripit/core/trip/trip-model.dart';
import 'package:tripit/ui/widgets/image-list.dart';
import '../../widgets/store/store-trip-places-list.dart';
import '../../widgets/rating_overview.dart';
import '../../widgets/store/store-trip-map.dart';

class TripMain extends StatefulWidget {
  static const routeName = '/trip';
  @override
  _TripMainState createState() => _TripMainState();
}

class _TripMainState extends State<TripMain> with TickerProviderStateMixin {
  Map _args = {};
  bool _loaded = false;
  bool _ordered = false;
  String _selectedPlaceKey;
  TextOverflow _overflow = TextOverflow.ellipsis;
  int _maxLines = 5;
  AnimationController _audioController;
  AnimationController _playPauseController;

  Future getPlaceDistance(Trip _trip, Position _userPosition) async {
    for (int i = 0; i < _trip.places.length; i++) {
      _trip.places[i].getDistanceFromUser(_userPosition);
    }
  }

  void orderPlaces(List<Place> _places, Position _userPosition) {
    _places.sort((a, b) {
      return a.order.compareTo(b.order);
    });
    setState(() {
      _places = _places;
      _ordered = true;
    });
  }

  void _handleSelectMarker(String _selectedPlaceKey) {
    setState(() {
      _selectedPlaceKey = _selectedPlaceKey;
    });
  }

  void _toggleShowDescription() {
    setState(() {
      _maxLines = _maxLines == null ? 5 : null;
      _overflow = _overflow == null ? TextOverflow.ellipsis : null;
    });
  }

  @override
  void initState() {
    super.initState();
    _audioController =
        AnimationController(duration: Duration(seconds: 10), vsync: this);
    _audioController.addListener(() => setState(() {}));
    _playPauseController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    // _playPauseController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _audioController.dispose();
    _playPauseController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _args = ModalRoute.of(context).settings.arguments;
    Position _userPosition = _args['userPosition'];
    Trip _trip = _args['trip'];
    List<Place> _places = _trip.places;

    if (!_ordered) orderPlaces(_places, _userPosition);

    if (!_loaded) {
      getPlaceDistance(_trip, _userPosition).then((v) {
        setState(() {
          _trip = _trip;
          _loaded = true;
        });
      });
    }

    String audioTime() {
      int duration = 75;
      return '${(Duration(seconds: duration).inMinutes.remainder(60) - (_audioController.value).toInt()).toString().padLeft(2, '0')}:${(Duration(seconds: duration).inSeconds.remainder(60) - (_audioController.value * 10).toInt()).toString().padLeft(2, '0')}';
    }

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          centerTitle: true,
          backgroundColor: Colors.red[900],
          floating: true,
          pinned: true,
          actions: [
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () => print('share'),
            ),
            IconButton(
              iconSize: 30,
              icon: _trip.saved
                  ? Icon(
                      Icons.favorite,
                    )
                  : Icon(
                      Icons.favorite_border,
                    ),
              onPressed: () {
                _trip.toggleSaved();
                setState(() {
                  _trip = _trip;
                });
              },
            ),
          ],
          expandedHeight: MediaQuery.of(context).size.height / 3.5,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Text(
              '${_trip.name}',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2),
            ),
            background: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: '${_trip.imageUrl}',
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(
                  strokeWidth: 0.5,
                  valueColor: AlwaysStoppedAnimation(Colors.grey[100]),
                ),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    //location & purchase
                    ListTile(
                      title: Text(
                        '${_trip.city}, ${_trip.country}',
                        softWrap: true,
                        style: _titleStyle,
                      ),
                      subtitle: Text(
                        'location',
                        style: _subtitleStyle,
                      ),
                      trailing: Builder(
                        builder: (ctx) => RaisedButton(
                            color: _trip.purchased
                                ? Colors.grey[400]
                                : Colors.green[700],
                            child: Text(
                              _trip.purchased
                                  ? 'purchased'
                                  : 'add to cart (\$${_trip.price})',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: 1.5),
                            ),
                            onPressed: () {
                              _trip.toggleSaved();
                              _trip.togglePurchased();
                              Scaffold.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _trip.purchased
                                        ? 'trip added to cart!'
                                        : 'trip removed!',
                                  ),
                                  action: SnackBarAction(
                                      label: 'DISMISS',
                                      onPressed: () {
                                        Scaffold.of(ctx).hideCurrentSnackBar();
                                      }),
                                ),
                              );
                              setState(() {
                                _trip = _trip;
                              });
                            }),
                      ),
                    ),
                    Divider(
                      height: 30,
                    ),
                    //downloads, rating and language
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '15.6k',
                              style: _titleBigStyle,
                            ),
                            Text(
                              'downloads',
                              style: _subtitleStyle,
                            ),
                          ],
                        ),
                        VerticalDivider(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            RatingOverview(_trip),
                          ],
                        ),
                        VerticalDivider(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flag(
                              _trip.language.toUpperCase(),
                              height: 30,
                              width: 50,
                            ),
                            Text(
                              'language',
                              style: _subtitleStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(
                      height: 30,
                    ),
                    //preview audio
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              progress: _playPauseController,
                              color: Colors.green,
                              size: 35,
                            ),
                            onPressed: () {
                              if (_audioController.isAnimating) {
                                _playPauseController.reverse();
                                _audioController.stop();
                              } else {
                                if (_audioController.isDismissed) {
                                  _playPauseController.forward();
                                  _audioController.forward().then((_) {
                                    _audioController.value = 0;
                                    _playPauseController.reset();
                                  });
                                } else {
                                  _playPauseController.forward();
                                  _audioController.forward().then((_) {
                                    _audioController.value = 0;
                                    _playPauseController.reset();
                                  });
                                }
                              }
                            }),
                        Flexible(
                          child: LinearProgressIndicator(
                            value: _audioController.value,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation(Colors.green),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          audioTime(),
                          style: _subtitleStyle,
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                    Divider(
                      height: 30,
                    ),
                    //pictures
                    Container(
                      height: 100,
                      child: ListView.builder(
                          itemCount: _trip.places.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, i) => InkWell(
                                onTap: () {
                                  showDialog(
                                      barrierDismissible: true,
                                      barrierColor: Colors.black87,
                                      context: context,
                                      builder: (context) =>
                                          ImageList(_trip.places[i].imageUrl));
                                },
                                child: Card(
                                  elevation: 1,
                                  child: Hero(
                                    tag: '${_trip.places[i].imageUrl}',
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: '${_trip.places[i].imageUrl}',
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 0.5,
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.grey[100]),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              )),
                    ),
                    Divider(
                      height: 30,
                    ),
                    //description text
                    Text(
                      'about the trip',
                      style: _titleStyle,
                    ),
                    InkWell(
                      onTap: () => _toggleShowDescription(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Text(
                          '${_trip.description}',
                          maxLines: _maxLines,
                          textAlign: TextAlign.justify,
                          overflow: _overflow,
                        ),
                      ),
                    ),
                    Divider(
                      height: 30,
                    ),
                    //map and place list
                    Card(
                      child: Column(
                        children: [
                          Container(
                            child: !_loaded
                                ? CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.grey[300]),
                                  )
                                : TripMap(
                                    _trip, _userPosition, _selectedPlaceKey),
                          ),
                          ExpansionTile(
                            initiallyExpanded: true,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'total distance',
                                  style: _titleStyle,
                                ),
                                Text(
                                  '15.6 Km',
                                  style: _subtitleStyle,
                                ),
                                SizedBox(),
                              ],
                            ),
                            children: [
                              Container(
                                child: !_loaded || !_ordered
                                    ? CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.grey[300]),
                                      )
                                    : PlacesList(_places, _handleSelectMarker),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    //creator info
                    // Center(
                    //   child: Column(
                    //     children: [
                    //       CircleAvatar(
                    //         radius: 50,
                    //         backgroundImage:
                    //             AssetImage('assets/images/avatar.png'),
                    //       ),
                    //       SizedBox(height: 10),
                    //       Text(
                    //         '${_trip.creator}',
                    //         style: _titleStyle,
                    //       ),
                    //       Text(
                    //         '15 trips',
                    //         style: _subtitleStyle,
                    //       ),
                    //     ],
                    //   ),
                    // )
                  ],
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  TextStyle _titleStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  TextStyle _titleBigStyle =
      TextStyle(fontSize: 22, fontWeight: FontWeight.bold);

  TextStyle _subtitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.black38,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.1,
  );
}

// var _sortMenu = Padding(
//   padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
//   child: Row(
//     crossAxisAlignment: CrossAxisAlignment.end,
//     mainAxisAlignment: MainAxisAlignment.end,
//     children: <Widget>[
//       SortMenu(currentOption, handleChangeSortOption),
//     ],
//   ),
// )
