import 'package:flutter/material.dart';
import 'package:tripit/models/trip_model.dart';

enum tripOption { save, details, pois }

class TripOptions extends StatelessWidget {
  final Trip trip;

  TripOptions({this.trip});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        padding: EdgeInsets.all(0),
        icon: Icon(
          Icons.more_vert,
          color: Colors.grey[600],
          size: 20,
        ),
        onSelected: (value) {},
        itemBuilder: (context) {
          return [
            PopupMenuItem<tripOption>(
              value: tripOption.details,
              child: Text(
                'trip details',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            PopupMenuItem<tripOption>(
              value: tripOption.pois,
              child: Text(
                'trip places',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ];
        });
  }
}
