import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:tripit/providers/filters.provider.dart';
import 'package:tripit/providers/user-position.provider.dart';
import 'package:tripit/core/models/trip.model.dart';
import 'package:tripit/providers/trip.provider.dart';
import 'package:tripit/ui/screens/filters.dart';
import 'trip-main.dart';
import '../widgets/home-search.dart';

class Home extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Trip> _myTrips = [];
  List<Trip> _recommendedTrips = [];

  Widget buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[300]),
      ),
    );
  }

  Widget buildTripList(List<Trip> _ts, Position _uP) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        height: MediaQuery.of(context).size.height / 6,
        child: ListView.builder(
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
                              Navigator.pushNamed(context, TripMain.routeName,
                                  arguments: {
                                    'trip': _ts[index],
                                    'userPosition': _uP,
                                  }).then((_) => setState(() {}));
                            },
                            child: Text(
                              '${_ts[index].name}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  // color: Colors.white,
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
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('build HOME');
    var _userPosition = Provider.of<UserPosition>(context).getPosition;
    var _filters = Provider.of<Filters>(context, listen: false);
    var _tripsProvider = Provider.of<TripProvider>(context);
    _myTrips = _tripsProvider.trips;

    return Scaffold(
      appBar: AppBar(
        title: Text('tripit',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.red[900],
        leading: IconButton(
          icon: Icon(Icons.search),
          onPressed: () async {
            await showSearch(
                context: context, delegate: HomeSearch(_tripsProvider.trips));
          },
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.tune),
              onPressed: () async {
                await showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (_) {
                      return ChangeNotifierProvider.value(
                          value: _filters, child: FiltersScreen());
                    });
              }),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _tripsProvider.loadTrips(),
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
                  // !_loaded ? buildLoading() :
                  buildTripList(_myTrips, _userPosition),
                  Divider(
                    height: 20,
                  ),
                  Text(
                    'my trips',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    height: 20,
                  ),
                  // !_loaded ? buildLoading()
                  buildTripList(_myTrips, _userPosition),
                  Divider(
                    height: 20,
                  ),
                  Text(
                    'recommended trips',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    height: 20,
                  ),
                  // !_loaded ? buildLoading()
                  buildTripList(_recommendedTrips, _userPosition),
                  Divider(
                    height: 20,
                  ),
                  Text(
                    'new trips',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    height: 20,
                  ),
                  // !_loaded ? buildLoading()
                  buildTripList(_recommendedTrips, _userPosition),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
