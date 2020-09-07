import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripit/core/utils/s3-auth-headers.dart';
import 'package:tripit/providers/download.provider.dart';
import 'package:tripit/providers/user.provider.dart';
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
    List<Trip> _ts = [];
    List<Trip> _purchased = [];
    List<Trip> _favourites = [];
    List<Trip> _newest = [];
    List<Trip> _recommended = [];

    Widget buildTripList(List<Trip> _ts) {
      return GridView.count(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        crossAxisCount: 2,
        primary: false,
        childAspectRatio: 0.85,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: _ts
            .map((trip) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(
                        context, TripMain.routeName,
                        arguments: {
                          'trip': trip,
                        }),
                    child: GridTile(
                      child: CachedNetworkImage(
                        httpHeaders: generateAuthHeaders(trip.imageUrl),
                        imageUrl: trip.imageUrl,
                        fit: BoxFit.cover,
                      ),
                      footer: GridTileBar(
                        backgroundColor: Colors.black38,
                        title: Text(
                          trip.name,
                          softWrap: true,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.1,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
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
                    onPressed: () =>
                        Navigator.pushNamed(context, CartMain.routeName)),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Provider.of<TripProvider>(context, listen: false).loadTrips();
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Consumer3<TripProvider, UserProvider, DownloadProvider>(
                  builder: (context, tripsData, userData, downloads, _) {
                _ts = tripsData.trips.where((trip) => trip.published)?.toList();
                _purchased = _ts
                    .where((trip) =>
                        (userData.user.purchasedTrips.contains(trip.id) ||
                            userData.user.purchasedPlaces
                                .contains(_ts.expand((t) => t.places))) ||
                        (downloads.existsByTrip(trip.id, trip.places.length)))
                    ?.toList();

                _favourites = _ts
                    .where((trip) =>
                        userData.user.favouriteTrips.contains(trip.id) ||
                        userData.user.favouritePlaces
                            .contains(_ts.expand((t) => t.places)))
                    ?.toList();

                _favourites.removeWhere((t) => _purchased.contains(t));

                _newest = _ts.where((trip) => trip.updatedAt != null)?.toList();
                _newest.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                _newest = _newest
                    ?.getRange(0, _newest.length < 5 ? _newest.length : 5)
                    ?.toList();

                _recommended = _ts
                    .where((t) =>
                        !_favourites.contains(t) &&
                        !_newest.contains(t) &&
                        !_purchased.contains(t))
                    ?.toList();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (_purchased.length > 0) ...[
                      Text(
                        'your purchased trips & places',
                        style: _title,
                      ),
                      const SizedBox(height: 15),
                      buildTripList(_purchased),
                      const Divider(height: 40),
                    ],
                    if (_favourites.length > 0) ...[
                      Text(
                        'your favourite trips & places',
                        style: _title,
                      ),
                      const SizedBox(height: 15),
                      buildTripList(_favourites),
                      const Divider(height: 40),
                    ],
                    if (_newest.length > 0) ...[
                      Text(
                        'newest trips',
                        style: _title,
                      ),
                      const SizedBox(height: 15),
                      buildTripList(_newest),
                      const Divider(height: 40),
                    ],
                    if (_recommended.length > 0) ...[
                      Text(
                        'recommended for you',
                        style: _title,
                      ),
                      const SizedBox(height: 15),
                      buildTripList(_recommended),
                      const Divider(height: 40),
                    ],
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

TextStyle _title = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
