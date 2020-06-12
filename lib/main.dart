import 'package:flutter/material.dart';
import 'package:tripit/screens/home/home-main.dart';
import 'package:tripit/screens/map/map-main.dart';
import 'package:tripit/screens/profile/profile-main.dart';
import 'package:tripit/screens/search/search-main.dart';
import 'package:tripit/screens/store/store-main.dart';
import 'package:tripit/screens/store/trip-main.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/map',
      routes: {
        '/': (context) => Home(),
        '/home': (context) => Home(),
        '/map': (context) => Map(),
        '/store': (context) => Store(),
        '/search': (context) => Search(),
        '/profile': (context) => Profile(),
        '/trip-main': (context) => TripMain(),
      },
      theme: ThemeData(
          // Use the old theme but apply the following three changes
          fontFamily: 'Nunito'),
    ));
