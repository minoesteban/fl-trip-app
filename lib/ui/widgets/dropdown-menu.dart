import 'package:flutter/material.dart';

enum tripOption { save, details, places }

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        icon: Icon(
          Icons.more_vert,
          // color: Colors.grey[800],
          // size: 20,
        ),
        onSelected: (value) {},
        itemBuilder: (context) {
          return [
            PopupMenuItem<void>(
              value: tripOption.details,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    Icons.share,
                    color: Colors.grey,
                  ),
                  Text(
                    'share',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
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
