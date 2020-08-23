import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:tripit/providers/purchase.provider.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'core/models/place.model.dart';
import 'core/models/trip.model.dart';
import 'providers/cart.provider.dart';
import 'providers/language.provider.dart';
import 'providers/country.provider.dart';
import 'providers/user.provider.dart';
import 'providers/filters.provider.dart';
import 'providers/trip.provider.dart';
import 'ui/screens/cart-main.dart';
import 'ui/screens/login.dart';
import 'ui/screens/home-main.dart';
import 'ui/screens/map-main.dart';
import 'ui/screens/trip-new.dart';
import 'ui/screens/store-main.dart';
import 'ui/screens/profile-main.dart';
import 'ui/screens/tab-navigator.dart';
import 'ui/screens/place-dialog.dart';
import 'ui/screens/trip-main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

  // final Directory docDirectory =
  //     await path_provider.getApplicationDocumentsDirectory();
  // Hive.init(docDirectory.path);

  UserProvider _userProvider = UserProvider();
  //TODO: hacer el get dinamico segun login?
  await _userProvider.getUser(8);
  await _userProvider.getUserPosition();

  TripProvider _trips = TripProvider();
  await _trips.loadTrips();

  PurchaseProvider _purchases = PurchaseProvider();
  await _purchases.getCounts();

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
        ChangeNotifierProvider<PurchaseProvider>.value(
          value: _purchases,
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
          PlaceDialog.routeName: (context) => PlaceDialog(new Place()),
          CartMain.routeName: (context) => CartMain(),
        },
        onGenerateRoute: (settings) {
          Map<dynamic, dynamic> args = settings.arguments ?? {};
          switch (settings.name) {
            case TripNew.routeName:
              return MaterialPageRoute<Map<String, dynamic>>(
                  builder: (context) {
                Trip trip = args['trip'] ??
                    Trip(
                        id: 0,
                        name: '',
                        countryId: '',
                        ownerId: _userProvider.user.id);
                return TripNew(trip);
              });
            case TripMain.routeName:
              return MaterialPageRoute<Map<String, dynamic>>(
                  builder: (context) {
                    Trip trip = args['trip'];
                    return TripMain(trip);
                  },
                  settings: settings);
            default:
              return MaterialPageRoute<void>(builder: (context) => LoginMain());
          }
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
