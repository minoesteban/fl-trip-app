import 'package:flutter/material.dart';
import 'package:tripit/models/poi_model.dart';
import 'package:tripit/models/trip_model.dart';

class RatingOverview extends StatefulWidget {
  final Trip _trip;
  final Poi _poi;

  RatingOverview(this._trip, [this._poi]);

  @override
  _RatingOverviewState createState() => _RatingOverviewState();
}

class _RatingOverviewState extends State<RatingOverview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget._trip.tripRating.toStringAsPrecision(2)}',
                style: TextStyle(
                    color: Colors.amber[500],
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              ),
              Icon(
                Icons.star,
                color: Colors.amber[500],
                size: 15,
              ),
            ],
          ),
          // Text(
          //   '(18.6k)',
          //   style: TextStyle(
          //     fontSize: 10,
          //     color: Colors.black38,
          //     fontWeight: FontWeight.bold,
          //     letterSpacing: 1.1,
          //   ),
          // )
        ],
      ),
    );
  }
}
