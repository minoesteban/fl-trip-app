import 'dart:async';

import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tripit/components/sort_menu.dart';
import 'package:tripit/components/store/pois_list.dart';
import 'package:tripit/components/store/rating_overview.dart';
import 'package:tripit/components/store/trip_map.dart';
import 'package:tripit/models/poi_model.dart';
import 'package:tripit/models/sort_options.dart';
import 'package:tripit/models/trip_model.dart';

class TripMain extends StatefulWidget {
  @override
  _TripMainState createState() => _TripMainState();
}

class _TripMainState extends State<TripMain>
    with SingleTickerProviderStateMixin {
  Map _args = {};
  bool _loaded = false;
  bool _ordered = false;
  Option currentOption = SortOption.getSortOptions()[0].opt;
  String _selectedPoiKey;
  TextOverflow _overflow = TextOverflow.ellipsis;
  int _maxLines = 5;
  AnimationController _animationController;

  Future getPoiDistance(Trip _trip, Position _userPosition) async {
    for (int i = 0; i < _trip.pois.length; i++) {
      _trip.pois[i].getDistanceFromUser(_userPosition);
    }
  }

  handleChangeSortOption(Option newOption) {
    setState(() {
      currentOption = newOption;
      _ordered = false;
    });
  }

  void orderPois(List<Poi> _pois, Position _userPosition) {
    _pois.sort((a, b) {
      switch (this.currentOption) {
        case Option.RatingAsc:
          return a.rating.compareTo(b.rating);
        case Option.RatingDsc:
          return b.rating.compareTo(a.rating);
        case Option.DistanceAsc:
          return a.distanceFromUser.compareTo(b.distanceFromUser);
        case Option.DistanceDsc:
          return b.distanceFromUser.compareTo(a.distanceFromUser);
        default:
          return a.order.compareTo(b.order);
      }
    });
    setState(() {
      _pois = _pois;
      _ordered = true;
    });
  }

  void _handleSelectMarker(String _selectedPoiKey) {
    print('tripmain handler $_selectedPoiKey');
    setState(() {
      _selectedPoiKey = _selectedPoiKey;
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
    _animationController =
        AnimationController(duration: Duration(seconds: 10), vsync: this);
    _animationController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    _args = ModalRoute.of(context).settings.arguments;
    Position _userPosition = _args['userPosition'];
    Trip _trip = _args['trip'];
    List<Poi> _pois = _trip.pois;

    if (!_ordered) orderPois(_pois, _userPosition);

    if (!_loaded) {
      getPoiDistance(_trip, _userPosition).then((v) {
        setState(() {
          _trip = _trip;
          _loaded = true;
        });
      });
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
                _trip.saved = _trip.saved ? false : true;
                setState(() {
                  _trip = _trip;
                });
              },
            ),
          ],
          expandedHeight: MediaQuery.of(context).size.height / 3.5,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              '${_trip.name}',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2),
            ),
            background: Image.asset(
              'assets/images/italy/roma.jpg',
              fit: BoxFit.fill,
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
                    //location, rating and language
                    ListTile(
                      title: Text(
                        '${_trip.city}, ${_trip.country}',
                        style: _titleStyle,
                      ),
                      subtitle: Text(
                        'location',
                        style: _subtitleStyle,
                      ),
                      trailing: LayoutBuilder(builder: (ctx, cns) {
                        return Container(
                          width: cns.maxWidth / 1.8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RatingOverview(_trip),
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
                        );
                      }),
                    ),
                    Divider(),
                    //preview audio
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: Icon(
                              Icons.play_circle_outline,
                              color: Colors.green,
                              size: 30,
                            ),
                            onPressed: () {
                              _animationController.value = 0;
                              _animationController.forward();
                            }),
                        Flexible(
                          child: LinearProgressIndicator(
                            value: _animationController.value,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation(Colors.green),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          '1:00',
                          style: _subtitleStyle,
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                    Divider(),
                    //pictures
                    Container(
                      height: 100,
                      child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: [
                          Card(
                            elevation: 3,
                            child: Image.asset(
                              'assets/images/italy/colosseo.jpg',
                              fit: BoxFit.fill,
                            ),
                          ),
                          Card(
                            elevation: 3,
                            child: Image.asset(
                              'assets/images/italy/fontana-di-trevi.jpeg',
                              fit: BoxFit.fill,
                            ),
                          ),
                          Card(
                            elevation: 3,
                            child: Image.asset(
                              'assets/images/italy/galleria-borghese.jpg',
                              fit: BoxFit.fill,
                            ),
                          ),
                          Card(
                            elevation: 3,
                            child: Image.asset(
                              'assets/images/italy/musei-vaticani.jpg',
                              fit: BoxFit.fill,
                            ),
                          ),
                          Card(
                            elevation: 3,
                            child: Image.asset(
                              'assets/images/italy/piazza-san-pietro.jpg',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      ),
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
                    //map and poi list
                    Text(
                      'trip places',
                      style: _titleStyle,
                    ),
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
                                    _trip, _userPosition, _selectedPoiKey),
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
                                    : PoisList(_pois, _handleSelectMarker),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    //purchase button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: SizedBox(
                        height: 40,
                        width: MediaQuery.of(context).size.width - 40,
                        child: RaisedButton(
                            color: Colors.green[700],
                            child: Text(
                              _trip.purchased
                                  ? 'delete trip'
                                  : 'purchase trip (\$${_trip.price})',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: 1.5),
                            ),
                            onPressed: () {
                              _trip.purchased = _trip.purchased ? false : true;
                              _trip.saved = _trip.saved ? false : true;
                              setState(() {
                                _trip = _trip;
                              });
                            }),
                      ),
                    ),
                    Divider(),
                    //creator info
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                AssetImage('assets/images/avatar.png'),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '${_trip.creator}',
                            style: _titleStyle,
                          ),
                          Text(
                            '15 trips',
                            style: _subtitleStyle,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  TextStyle _titleStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

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
