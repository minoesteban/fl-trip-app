import 'dart:async';

import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tripit/components/app_bar.dart';
import 'package:tripit/components/sort_menu.dart';
import 'package:tripit/components/store/pois_list.dart';
import 'package:tripit/components/trip/trip_map.dart';
import 'package:tripit/models/poi_model.dart';
import 'package:tripit/models/sort_options.dart';
import 'package:tripit/models/trip_model.dart';

class TripMain extends StatefulWidget {
  @override
  _TripMainState createState() => _TripMainState();
}

class _TripMainState extends State<TripMain> {
  Map _args = {};
  bool _loaded = false;
  bool _ordered = false;
  Option currentOption = SortOption.getSortOptions()[0].opt;
  Trip _trip;
  List<Poi> _pois = [];

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
    print(this.currentOption);
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

  @override
  Widget build(BuildContext context) {
    _args = ModalRoute.of(context).settings.arguments;
    Position _userPosition = _args['userPosition'];
    _trip = _args['trip'];
    _pois = _trip.pois;

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
      appBar: appBar,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: ListTile(
                          title: Text(
                            '${_trip.name}',
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 28,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${_trip.city}, ${_trip.country}',
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 18,
                                color: Colors.black38,
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: IconButton(
                            iconSize: 30,
                            icon: _trip.saved
                                ? Icon(
                                    Icons.favorite,
                                    color: Colors.red[800],
                                  )
                                : Icon(
                                    Icons.favorite_border,
                                    color: Colors.grey,
                                  ),
                            onPressed: () {
                              _trip.saved = _trip.saved ? false : true;
                              setState(() {
                                _trip = _trip;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 0,
                    color: Colors.white,
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      radius: 15,
                      backgroundImage: AssetImage('assets/images/avatar.png'),
                    ),
                    title: Text(
                      '${_trip.creator}',
                      style: TextStyle(
                          fontFamily: 'Nunito', color: Colors.grey[600]),
                    ),
                    trailing: Flag(
                      _trip.language.toUpperCase(),
                      height: 50,
                      width: 50,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${_trip.tripRating}',
                        style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nunito',
                            fontSize: 30),
                      ),
                      RatingBarIndicator(
                        rating: _trip.tripRating,
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 25.0,
//                          direction: Axis.vertical,
                      ),
                    ],
                  ),
                  Divider(
                    height: 20,
                    color: Colors.white,
                  ),
                  Container(
                    child: !_loaded
                        ? CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.grey[300]),
                          )
                        : TripMap(trip: _trip, userPosition: _userPosition),
                  ),
                  SizedBox(
                    height: 10,
                  ),
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
                                fontFamily: 'Nunito',
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
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        SortMenu(currentOption, handleChangeSortOption),
                      ],
                    ),
                  ),
                  Container(
                    child: !_loaded || !_ordered
                        ? CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.grey[300]),
                          )
                        : PoisList(pois: _pois),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
