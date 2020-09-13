import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripit/providers/user.provider.dart';
import 'home-main.dart';
import 'map-main.dart';
import 'profile-main.dart';
import 'store-main.dart';

class TabNavigator extends StatefulWidget {
  static const routeName = '/tabs';

  @override
  _TabNavigatorState createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
  int _currentIndex = 1;
  PageController _pc = PageController(initialPage: 1);
  @override
  Widget build(BuildContext context) {
    return AudioServiceWidget(
      child: Scaffold(
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pc,
          children: [
            MapMain(),
            Home(),
            Store(),
            Profile(Provider.of<UserProvider>(context, listen: false).user.id),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 5,
          iconSize: 25,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.red[300],
          currentIndex: _currentIndex,
          onTap: (index) {
            _pc.animateToPage(index,
                duration: Duration(milliseconds: 200), curve: Curves.easeIn);
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
                backgroundColor: Colors.red[900],
                title: Text('map'),
                icon: Icon(Icons.location_on)),
            BottomNavigationBarItem(
                backgroundColor: Colors.red[900],
                title: Text('home'),
                icon: Icon(Icons.home)),
            BottomNavigationBarItem(
                backgroundColor: Colors.red[900],
                title: Text('store'),
                icon: Icon(Icons.shop)),
            BottomNavigationBarItem(
              backgroundColor: Colors.red[900],
              title: Text('profile'),
              icon: Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }
}
