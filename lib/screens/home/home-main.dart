import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tripit/components/app_bar.dart';
import 'package:tripit/components/home/home_search.dart';
import 'package:tripit/components/home/trip-list.dart';
import 'package:tripit/components/map/map_search.dart';
import 'package:tripit/models/trip_model.dart';

class Home extends StatefulWidget {
  final List<Trip> _trips;
  final Position _userPosition;

  Home(this._trips, this._userPosition);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Trip> _myTrips = [];
  List<Trip> _recommendedTrips = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _myTrips = widget._trips
        .where((e) => e.purchased == true || e.saved == true)
        .toList();
    _recommendedTrips =
        widget._trips.where((e) => !e.purchased && !e.saved).toList();
    setState(() {
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('tripit',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.red[900],
        leading: IconButton(
          icon: Icon(Icons.search),
          onPressed: () async {
            var result = await showSearch(
                context: context,
                delegate: HomeSearch(widget._trips, widget._userPosition));
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'recent trips',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Divider(
                  height: 20,
                ),
                !_loaded
                    ? CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.grey[300]),
                      )
                    : HomeTripList(_myTrips, widget._userPosition),
                Divider(
                  height: 20,
                ),
                Text(
                  'my trips',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Divider(
                  height: 20,
                ),
                !_loaded
                    ? CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.grey[300]),
                      )
                    : HomeTripList(_myTrips, widget._userPosition),
                Divider(
                  height: 20,
                ),
                Text(
                  'recommended trips',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Divider(
                  height: 20,
                ),
                !_loaded
                    ? CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.grey[300]),
                      )
                    : HomeTripList(_recommendedTrips, widget._userPosition),
                Divider(
                  height: 20,
                ),
                Text(
                  'new trips',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Divider(
                  height: 20,
                ),
                !_loaded
                    ? CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.grey[300]),
                      )
                    : HomeTripList(_recommendedTrips, widget._userPosition),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
