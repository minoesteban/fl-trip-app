import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripit/core/utils/s3-auth-headers.dart';
import 'package:tripit/providers/trip.provider.dart';
import 'package:tripit/ui/screens/cart-main.dart';

import '../../core/models/place.model.dart';
import '../screens/place-dialog.dart';

class PlacesList extends StatelessWidget {
  final List<Place> places;

  PlacesList(this.places);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      itemCount: places.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  barrierDismissible: true,
                  opaque: false,
                  barrierColor: Colors.black54,
                  pageBuilder: (_, _a1, _a2) => FadeTransition(
                    opacity: _a1,
                    child: PlaceDialog(places[index]),
                  ),
                ),
              ).then((value) {
                if (value != null) {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      duration: Duration(seconds: 3),
                      content: Text(
                        value
                            ? 'place added to cart!'
                            : 'place removed from cart!',
                      ),
                      action: SnackBarAction(
                        label: 'GO TO CART',
                        onPressed: () {
                          Scaffold.of(context).hideCurrentSnackBar();
                          Navigator.pushNamed(context, CartMain.routeName);
                        },
                      ),
                    ),
                  );
                }
              });
            },
            leading: Container(
              width: 60,
              height: 40,
              child: Hero(
                tag: '${places[index].id}_image',
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    httpHeaders: generateAuthHeaders(places[index].imageUrl),
                    imageUrl: places[index].imageUrl,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 0.5,
                        valueColor: AlwaysStoppedAnimation(Colors.grey[100]),
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${places[index].name}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            trailing: LayoutBuilder(
              builder: (ctx, cns) {
                return Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Consumer<TripProvider>(
                            builder: (_, trips, __) => Text(
                              places[index].ratingAvg != null
                                  ? '${trips.trips.firstWhere((trip) => trip.id == places[index].tripId).places[index].ratingAvg.toStringAsPrecision(2)}'
                                  : '0',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 15,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
