import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tripit/core/models/trip-model.dart';

class HomeTripList extends StatefulWidget {
  final List<Trip> _trips;
  final Position _userPosition;

  HomeTripList(this._trips, this._userPosition);

  @override
  _HomeTripListState createState() => _HomeTripListState();
}

class _HomeTripListState extends State<HomeTripList> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        height: MediaQuery.of(context).size.height / 6,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: widget._trips.length,
            itemBuilder: (context, index) {
              return Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width / 2.5,
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Wrap(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/store/trip-main',
                                  arguments: {
                                    'trip': widget._trips[index],
                                    'userPosition': widget._userPosition,
                                  });
                            },
                            child: Text(
                              '${widget._trips[index].name}',
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
}
