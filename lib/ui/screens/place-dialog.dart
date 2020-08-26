import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:tripit/providers/purchase.provider.dart';
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
    AudioPlayer _fullAudioPlayer = AudioPlayer();
    _fullAudioPlayer.setUrl(_place.fullAudioUrl);

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
            errorWidget: (context, url, error) => const Icon(Icons.error),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                      Provider.of<PurchaseProvider>(context, listen: false)
                          .getCountBy(_place.tripId, _place.id)
                          .toString(),
                      style: _statNumber),
                  const Text('downloads', style: _statTitle),
                ],
              ),
              const VerticalDivider(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${_place.ratingAvg.toStringAsPrecision(2)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 32,
                          color: Colors.amber[500],
                          fontWeight: FontWeight.bold)),
                  Icon(Icons.star, color: Colors.amber[500], size: 18),
                ],
              ),
              const VerticalDivider(),
              FutureBuilder(
                  future: _fullAudioPlayer.setUrl(_place.fullAudioUrl),
                  builder: (_, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.grey[300]),
                        ),
                      );
                    }
                    Duration duration = snapshot.data;

                    return Column(
                      children: [
                        Text('${duration.inMinutes}\'', style: _statNumber),
                        Text('audio', style: _statTitle),
                      ],
                    );
                  }),
            ],
          ),
          const SizedBox(height: 10),
          //preview audio
          Player(_place.previewAudioUrl, true),
          //about
          CollapsibleText(_place.about),
          const Divider(height: 20),
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

const _statNumber = TextStyle(fontWeight: FontWeight.bold, fontSize: 22);

const _statTitle =
    TextStyle(color: Colors.black38, fontSize: 16, fontWeight: FontWeight.bold);
