import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tripit/screens/home/navigator-main.dart';
import 'package:tripit/screens/store/trip-main.dart';
import 'package:tripit/services/load-trips.dart' as TripService;
import 'models/trip_model.dart';

void main() async {
  List<Trip> _trips = [];
  Position _userPosition = Position();

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);


  await Geolocator()
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
      .then((value) => _userPosition = value)
      .catchError((err) => print('getCurrentPosition $err'));

  await TripService.loadTrips(_userPosition)
      .then((value) => _trips = value)
      .catchError((err) => print('loadTrips $err'));

  
  runApp(MaterialApp(
    title: 'tripit',
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/map': (context) => NavigatorMain(_trips, _userPosition),
      '/': (context) => NavigatorMain(_trips, _userPosition),
      '/store': (context) => NavigatorMain(_trips, _userPosition),
      '/profile': (context) => NavigatorMain(_trips, _userPosition),
      '/store/trip-main': (context) => TripMain(),
    },
    theme: ThemeData(
        // Use the old theme but apply the following three changes
        fontFamily: 'Nunito',
        primarySwatch: Colors.red,
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        })),
  ));
}

