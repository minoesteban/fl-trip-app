import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:tripit/models/poi_model.dart';

class PoisList extends StatefulWidget {
  final List<Poi> pois;

  PoisList({this.pois});

  @override
  _PoisListState createState() => _PoisListState();
}

class _PoisListState extends State<PoisList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: widget.pois.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              onTap: () {},
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    widget.pois[index].name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
                  ),
                  RatingBarIndicator(
                    rating: widget.pois[index].rating,
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 18.0,
//                          direction: Axis.vertical,
                  ),
                ],
              ),
              subtitle: Text(widget.pois[index].distanceFromUser > 1000
                  ? '${(widget.pois[index].distanceFromUser / 1000).toStringAsFixed(2)} Km'
                  : '${(widget.pois[index].distanceFromUser).toStringAsFixed(2)} m'),
              trailing: IconButton(
                onPressed: () {},
                icon: Icon(Icons.play_circle_outline),
                color: Colors.green[300],
              ),
            ),
          );
        });
  }
}
