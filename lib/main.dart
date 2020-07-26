import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/country.provider.dart';
import 'providers/user-position.provider.dart';
import 'ui/screens/home-main.dart';
import 'ui/screens/map-main.dart';
import 'ui/screens/trip-new.dart';
import 'ui/screens/store-main.dart';
import 'providers/filters.provider.dart';
import 'core/models/place.model.dart';
import 'providers/trip.provider.dart';
import 'ui/screens/profile-main.dart';
import 'ui/screens/tab-navigator.dart';
import 'ui/screens/place-dialog.dart';
import 'ui/screens/trip-main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

  UserPosition _userPosition = UserPosition();
  await _userPosition.getUserPosition();

  TripProvider _trips = TripProvider();
  await _trips.loadTrips();

  CountryProvider _countries = CountryProvider();
  await _countries.loadCountries();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CountryProvider>.value(
          value: _countries,
        ),
        ChangeNotifierProvider<TripProvider>.value(
          value: _trips,
        ),
        ChangeNotifierProvider<UserPosition>.value(
          value: _userPosition,
        ),
        ChangeNotifierProvider<Filters>(
          create: (_) => Filters(),
        ),
      ],
      child: MaterialApp(
        title: 'tripit',
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => TabNavigator(),
          Home.routeName: (_) => Home(),
          MapMain.routeName: (_) => MapMain(),
          Store.routeName: (_) => Store(),
          Profile.routeName: (_) => Profile(),
          TripMain.routeName: (_) => TripMain(),
          PlaceDialog.routeName: (_) => PlaceDialog(new Place()),
          TripNew.routeName: (_) => TripNew(),
        },
        theme: ThemeData(
          fontFamily: 'Nunito',
          primarySwatch: Colors.red,
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          }),
        ),
      ),
    ),
  );
}
