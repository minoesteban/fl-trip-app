import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tripit/components/app_bar.dart';
import 'package:tripit/models/trip_model.dart';
import 'package:tripit/services/load-trips.dart' as TripService;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Trip> _trips = [];
  Position _userPosition = Position();
  bool _loaded = false;

  Future setInitData() async {
    await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((value) => _userPosition = value)
        .catchError((err) => print('getCurrentPosition $err'));

    await TripService.loadTrips(_userPosition)
        .then((value) => _trips = value)
        .catchError((err) => print('loadTrips $err'));
  }

  @override
  void initState() {
    super.initState();
    setInitData().then((val) => setState(() {
          _loaded = true;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            children: <Widget>[
              Text('my trips'),
              Divider(
                height: 30,
              ),
              !_loaded
                  ? CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.grey[300]),
                    )
                  : Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _trips.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 1),
                              child: Card(
                                  child: ListTile(
                                onTap: () {
                                  Navigator.pushNamed(context, '/trip-main',
                                      arguments: {
                                        'trip': _trips[index],
                                        'userPosition': _userPosition
                                      });
                                },
                                title: Text(
                                  '${_trips[index].name}',
                                  style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2),
                                ),
                              )),
                            );
                          }),
                    ),
              Divider(
                height: 30,
              ),
              Text('recommended trips')
            ],
          ),
        ),
      ),
    );
  }
}
