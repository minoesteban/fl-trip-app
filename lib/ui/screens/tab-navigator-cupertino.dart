import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripit/core/models/place.model.dart';
import 'package:tripit/core/models/trip.model.dart';
import 'package:tripit/providers/user.provider.dart';
import 'package:tripit/ui/screens/cart-main.dart';
import 'package:tripit/ui/screens/login.dart';
import 'package:tripit/ui/screens/place-dialog.dart';
import 'package:tripit/ui/screens/trip-main.dart';
import 'package:tripit/ui/screens/trip-new.dart';
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
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
          iconSize: 25,
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
            )
          ]),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          routes: {
            '/': (context) => LoginMain(),
            TabNavigator.routeName: (context) => TabNavigator(),
            Home.routeName: (context) => Home(),
            MapMain.routeName: (context) => MapMain(),
            Store.routeName: (context) => Store(),
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
                          ownerId:
                              Provider.of<UserProvider>(context, listen: false)
                                  .user
                                  .id);
                  return TripNew(trip);
                });
              case TripMain.routeName:
                return MaterialPageRoute<Map<String, dynamic>>(
                    builder: (context) {
                      Trip trip = args['trip'];
                      return TripMain(trip);
                    },
                    settings: settings);
              case Profile.routeName:
                return MaterialPageRoute<Map<String, dynamic>>(
                    builder: (context) {
                      int userId = args['id'];
                      return Profile(userId);
                    },
                    settings: settings);
              default:
                return MaterialPageRoute<void>(
                    builder: (context) => LoginMain());
            }
          },
          builder: (context) {
            return PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _pc,
              children: [
                MapMain(),
                Home(),
                Store(),
                Profile(
                    Provider.of<UserProvider>(context, listen: false).user.id),
              ],
            );
          },
        );
      },
    );
  }
}
