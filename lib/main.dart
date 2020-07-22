import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tripit/core/models/countries-model.dart';
import 'package:tripit/providers/user-position-provider.dart';
import 'package:tripit/core/utils/utils.dart';
import 'package:tripit/ui/screens/home-main.dart';
import 'package:tripit/ui/screens/map-main.dart';
import 'package:tripit/ui/screens/trip-new.dart';
import 'package:tripit/ui/screens/store-main.dart';

import 'providers/filters-provider.dart';
import 'core/models/place-model.dart';
import 'providers/trips-provider.dart';
import 'ui/screens/profile-main.dart';
import 'ui/screens/tab-navigator.dart';
import 'ui/screens/place-dialog.dart';
import 'ui/screens/trip-main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

  UserPosition _userPosition = UserPosition();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<Countries>(
          create: (_) => Countries(),
        ),
        ChangeNotifierProvider<Trips>(
          create: (_) => Trips(),
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
          PlaceDialog.routeName: (_) =>
              PlaceDialog(new Place(getRandString(1))),
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
