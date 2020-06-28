import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tripit/models/trip_model.dart';
import 'package:tripit/screens/home/home-main.dart';
import 'package:tripit/screens/map/map-main.dart';
import 'package:tripit/screens/profile/profile-main.dart';
import 'package:tripit/screens/search/search-main.dart';
import 'package:tripit/screens/store/store-main.dart';
import 'package:tripit/screens/store/trip-main.dart';

class NavigatorMain extends StatefulWidget {
  final List<Trip> _trips;
  final Position _userPosition;

  NavigatorMain(this._trips, this._userPosition);

  @override
  _NavigatorMainState createState() => _NavigatorMainState();
}

class _NavigatorMainState extends State<NavigatorMain> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          Map(widget._trips, widget._userPosition),
          Home(widget._trips, widget._userPosition),
          Store(),
          Profile(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 5,
        iconSize: 25,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[300],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              backgroundColor: Colors.red[800],
              title: Text('map'),
              icon: Icon(Icons.location_on) 
              ),
          BottomNavigationBarItem(
              backgroundColor: Colors.red[800],
              title: Text('home'),
              icon: Icon(Icons.home) 
              ),
          BottomNavigationBarItem(
              backgroundColor: Colors.red[800],
              title: Text('store'),
              icon: Icon(Icons.local_grocery_store)
              ),
          BottomNavigationBarItem(
            backgroundColor: Colors.red[800],
            title: Text('profile'),
            icon: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}
