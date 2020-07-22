import 'package:flutter/material.dart';
import 'package:tripit/core/models/trip-model.dart';

class RatingOverview extends StatefulWidget {
  final Trip _trip;

  RatingOverview(this._trip);

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
                size: 18,
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
