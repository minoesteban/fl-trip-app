import 'package:flutter/material.dart';
import 'package:tripit/core/models/trip.model.dart';

enum tripOption { save, details, places }

class TripOptions extends StatelessWidget {
  final Trip trip;

  TripOptions({this.trip});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        icon: Icon(
          Icons.more_vert,
          color: Colors.grey[800],
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
              value: tripOption.places,
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
