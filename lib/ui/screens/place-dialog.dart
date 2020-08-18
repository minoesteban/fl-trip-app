import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripit/providers/trip.provider.dart';
import 'package:tripit/ui/widgets/audio-components.dart';
import 'package:tripit/ui/widgets/collapsible-text.dart';
import '../../core/models/place.model.dart';
import '../../providers/cart.provider.dart';
import '../../providers/user.provider.dart';

class PlaceDialog extends StatelessWidget {
  static const routeName = '/trip/place-dialog';
  final Place _place;

  PlaceDialog(this._place);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      titlePadding: const EdgeInsets.all(0),
      title: Stack(alignment: Alignment.bottomCenter, children: [
        Hero(
          tag: '${_place.id}_image',
          child: CachedNetworkImage(
            fit: BoxFit.fitWidth,
            imageUrl: '${_place.imageUrl}',
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(
                strokeWidth: 0.5,
                valueColor: AlwaysStoppedAnimation(Colors.grey[100]),
              ),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
        Container(
          color: Colors.black45,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_place.name}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Consumer<UserProvider>(
                  builder: (_, user, __) => IconButton(
                    icon: user.placeIsFavourite(_place.id)
                        ? Icon(Icons.favorite)
                        : Icon(Icons.favorite_border),
                    onPressed: () {
                      user.toggleFavouritePlace(_place.id);
                    },
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
      content: Column(
        children: [
          //stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  //TODO: obtener cantidad de descargas (compras? o ratings?)
                  Text(
                    '${_place.rating.count}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    'ratings',
                    style: TextStyle(color: Colors.black38, fontSize: 12),
                  ),
                ],
              ),
              VerticalDivider(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_place.rating.rating.toStringAsPrecision(2)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 26,
                        color: Colors.amber[500],
                        fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.amber[500],
                    size: 18,
                  ),
                ],
              ),
              VerticalDivider(),
              Column(
                children: [
                  //TODO: obtener duracion del audio principal
                  Text(
                    '17\'',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    'audio',
                    style: TextStyle(color: Colors.black38, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          //preview audio
          Player(_place.previewAudioUrl, true),
          //about
          CollapsibleText(_place.about),
          Divider(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: SizedBox(
              height: 40,
              width: MediaQuery.of(context).size.width - 40,
              child: Builder(
                builder: (ctx) => Consumer2<UserProvider, TripProvider>(
                  builder: (context, user, trips, _) {
                    return RaisedButton(
                      color: Colors.green[700],
                      child: Text(
                        user.placeIsPurchased(_place.id) ||
                                user.tripIsPurchased(
                                    trips.findById(_place.tripId).id)
                            ? 'purchased'
                            : _place.price == 0
                                ? 'add to cart   (free)'
                                : _place.price == 99999
                                    ? 'not purchaseable'
                                    : 'add to cart   (\$${_place.price.toStringAsPrecision(3)})',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 1.5),
                      ),
                      onPressed: user.placeIsPurchased(_place.id) ||
                              user.tripIsPurchased(
                                  trips.findById(_place.tripId).id) ||
                              trips.findById(_place.tripId).ownerId ==
                                  user.user.id ||
                              _place.price == 99999
                          ? null
                          : () {
                              Provider.of<CartProvider>(context, listen: false)
                                  .addItem(null, _place);
                              user.togglePurchasedPlace(_place.id);
                              Navigator.pop(
                                  context, user.placeIsPurchased(_place.id));
                            },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
