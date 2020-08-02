import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripit/ui/screens/cart-main.dart';
import '../../core/models/trip.model.dart';
import '../../providers/cart.provider.dart';
import '../../providers/trip.provider.dart';
import '../widgets/home-search.dart';
import 'trip-main.dart';

class Home extends StatelessWidget {
  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    Widget buildTripList() {
      List<Trip> _ts = [];
      return Center(
        child: Container(
          width: MediaQuery.of(context).size.width - 40,
          height: MediaQuery.of(context).size.height / 6,
          child: Consumer<TripProvider>(
            builder: (context, tripsData, _) {
              _ts = tripsData.trips.where((trip) => trip.published).toList();
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: _ts.length,
                itemBuilder: (context, index) {
                  return Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width / 2.5,
                    child: Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Center(
                          child: Wrap(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, TripMain.routeName,
                                      arguments: {
                                        'trip': _ts[index],
                                      });
                                },
                                child: Text(
                                  '${_ts[index].name}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('tripit',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.red[900],
        leading: IconButton(
          icon: Icon(Icons.search),
          onPressed: () async {
            await showSearch(context: context, delegate: HomeSearch());
          },
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartData, _) => Center(
              child: Badge(
                showBadge: cartData.items.length > 0,
                badgeContent: Text(
                  '${cartData.items.length}',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                animationDuration: Duration(milliseconds: 300),
                animationType: BadgeAnimationType.scale,
                position: BadgePosition.topRight(top: 2, right: 2),
                badgeColor: Colors.white,
                child: IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.pushNamed(context, CartMain.routeName);
                    }),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'recent trips',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Divider(
                  height: 20,
                ),
                buildTripList(),
                // Divider(
                //   height: 20,
                // ),
                // Text(
                //   'my trips',
                //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                // ),
                // Divider(
                //   height: 20,
                // ),
                // buildTripList(),
                // Divider(
                //   height: 20,
                // ),
                // Text(
                //   'recommended trips',
                //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                // ),
                // Divider(
                //   height: 20,
                // ),
                // buildTripList(),
                // Divider(
                //   height: 20,
                // ),
                // Text(
                //   'new trips',
                //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                // ),
                // Divider(
                //   height: 20,
                // ),
                // buildTripList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
