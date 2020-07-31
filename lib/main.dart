import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tripit/providers/cart.provider.dart';
import 'package:tripit/providers/language.provider.dart';
import 'package:tripit/ui/screens/cart-main.dart';
import 'package:tripit/ui/screens/login.dart';

import 'providers/country.provider.dart';
import 'providers/user.provider.dart';
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

  UserProvider _userProvider = UserProvider();
  //TODO: hacer el get dinamico segun login?
  await _userProvider.getUser(8);
  await _userProvider.getUserPosition();

  TripProvider _trips = TripProvider();
  await _trips.loadTrips();

  CountryProvider _countries = CountryProvider();
  await _countries.loadCountries();

  LanguageProvider _languages = LanguageProvider();
  await _languages.loadLanguages();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CountryProvider>.value(
          value: _countries,
        ),
        ChangeNotifierProvider<TripProvider>.value(
          value: _trips,
        ),
        ChangeNotifierProvider<UserProvider>.value(
          value: _userProvider,
        ),
        ChangeNotifierProvider<LanguageProvider>.value(
          value: _languages,
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider<Filters>(
          create: (_) => Filters(),
        ),
      ],
      child: MaterialApp(
        title: 'tripit',
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => LoginMain(),
          TabNavigator.routeName: (context) => TabNavigator(),
          Home.routeName: (context) => Home(),
          MapMain.routeName: (context) => MapMain(),
          Store.routeName: (context) => Store(),
          Profile.routeName: (context) => Profile(),
          TripMain.routeName: (context) => TripMain(),
          PlaceDialog.routeName: (context) => PlaceDialog(new Place()),
          TripNew.routeName: (context) => TripNew(),
          CartMain.routeName: (context) => CartMain(),
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
