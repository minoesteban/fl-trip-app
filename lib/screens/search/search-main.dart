import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../widgets/map/map_search.dart';
import '../../models/trip_model.dart';

class Search extends StatefulWidget {
  final List<Trip> _trips;
  final Position _userPosition;

  Search(this._trips, this._userPosition);
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('tripit',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.red[900],
        leading: IconButton(
          icon: Icon(Icons.search),
          onPressed: () async {
            var result = await showSearch(
                context: context,
                delegate: MapSearch(widget._trips, widget._userPosition));
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Text('search'),
        ),
      ),
    );
  }
}
