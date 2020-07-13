import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tripit/core/geo/user-position-provider.dart';
import 'package:tripit/core/utils.dart';
import 'package:tripit/ui/screens/home/home-main.dart';
import 'package:tripit/ui/screens/map/map-main.dart';
import 'package:tripit/ui/screens/trip/trip-new.dart';
import 'package:tripit/ui/screens/store/store-main.dart';

import 'core/filters-provider.dart';
import 'core/place/place-model.dart';
import 'core/trip/trips-provider.dart';
import 'ui/screens/profile/profile-main.dart';
import 'ui/screens/tab-navigator.dart';
import 'ui/screens/place/place-dialog.dart';
import 'ui/screens/trip/trip-main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

  UserPosition _userPosition = UserPosition();

  runApp(MultiProvider(
    providers: [
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
        PlaceDialog.routeName: (_) => PlaceDialog(new Place(getRandString(1))),
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
  ));
}
