import 'package:flutter/material.dart';
import 'home-main.dart';
import 'map-main.dart';
import 'profile-main.dart';
import 'store-main.dart';

class TabNavigator extends StatefulWidget {
  @override
  _TabNavigatorState createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
  int _currentIndex = 1;
  // PageController _pvc = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          MapMain(),
          Home(),
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
              icon: Icon(Icons.location_on)),
          BottomNavigationBarItem(
              backgroundColor: Colors.red[800],
              title: Text('home'),
              icon: Icon(Icons.home)),
          BottomNavigationBarItem(
              backgroundColor: Colors.red[800],
              title: Text('store'),
              icon: Icon(Icons.shop)),
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
