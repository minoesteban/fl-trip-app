import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripit/ui/screens/trip-main.dart';
import '../../core/models/place.model.dart';
import '../../core/utils/s3-auth-headers.dart';
import '../../providers/download.provider.dart';
import '../../providers/purchase.provider.dart';
import '../../providers/trip.provider.dart';
import '../../providers/cart.provider.dart';
import '../../providers/user.provider.dart';
import '../widgets/flat-player.dart';
import '../widgets/collapsible-text.dart';

class PlaceDialog extends StatelessWidget {
  static const routeName = '/trip/place-dialog';
  final Place _place;

  PlaceDialog(this._place);

  @override
  Widget build(BuildContext context) {
    int fullAudioLength =
        Duration(seconds: _place.fullAudioLength?.toInt() ?? 0).inMinutes;

    Widget buildHeader() {
      return Stack(alignment: Alignment.bottomCenter, children: [
        Hero(
          tag: '${_place.id}_image',
          child: CachedNetworkImage(
            fit: BoxFit.fitWidth,
            httpHeaders: generateAuthHeaders(_place.imageUrl),
            imageUrl: _place.imageUrl,
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
      ]);
    }

    Widget buildStats() {
      return Row(
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
          Column(
            children: [
              Text(fullAudioLength > 0 ? '$fullAudioLength\'' : '-',
                  style: _statNumber),
              Text('length', style: _statTitle),
            ],
          )
        ],
      );
    }

    Widget buildPurchaseDownload() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Consumer<UserProvider>(
          builder: (context, user, __) => user.placeIsPurchased(_place.id) ||
                  user.tripIsPurchased(_place.tripId) ||
                  user.user.id ==
                      Provider.of<TripProvider>(context, listen: false)
                          .findById(_place.tripId)
                          .ownerId
              ? Column(
                  children: [
                    DownloadButton(_place),
                    const Divider(height: 30),
                    SizedBox(
                      height: 40,
                      width: MediaQuery.of(context).size.width - 40,
                      child: Expanded(
                        child: StartButton(
                            Provider.of<TripProvider>(context, listen: false)
                                .findById(_place.tripId)),
                      ),
                    )
                  ],
                )
              : _place.price == 99999
                  ? Center()
                  : SizedBox(
                      height: 40,
                      width: MediaQuery.of(context).size.width - 40,
                      child: PurchaseButton(_place)),
        ),
      );
    }

    return AlertDialog(
      scrollable: true,
      titlePadding: const EdgeInsets.all(0),
      title: buildHeader(),
      content: Column(
        children: [
          //stats
          buildStats(),
          const SizedBox(height: 20),
          //preview audio
          Player(_place.previewAudioUrl, true, false),
          const SizedBox(height: 10),
          //about
          CollapsibleText(_place.about),
          //purchase / download
          const Divider(height: 30),
          buildPurchaseDownload(),
        ],
      ),
    );
  }
}

class PurchaseButton extends StatelessWidget {
  const PurchaseButton(this.place);
  final Place place;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) => RaisedButton(
          color: Colors.green[700],
          child: Text(
            place.price == 0
                ? 'add to cart   (free)'
                : 'add to cart   \$${place.price}',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1.5),
          ),
          onPressed: () {
            Provider.of<CartProvider>(context, listen: false)
                .addItem(null, place);
            Navigator.pop(context, true);
          }),
    );
  }
}

class DownloadButton extends StatelessWidget {
  const DownloadButton(this.place);
  final Place place;

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadProvider>(builder: (_, downloads, __) {
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            downloads.existsByPlace(place.id)
                ? Row(
                    children: [
                      Text('downloaded', style: _statTitle),
                      const SizedBox(width: 10),
                      Icon(Icons.check, size: 30, color: Colors.red[800])
                    ],
                  )
                : downloads.isDownloading
                    ? Container(
                        width: 180,
                        child: LinearProgressIndicator(
                            value: downloads.downloadPercentage))
                    : Text('download', style: _statTitle),
            const SizedBox(width: 10),
            CupertinoSwitch(
                activeColor: Colors.red[800],
                value: downloads.existsByPlace(place.id),
                onChanged: (value) async {
                  if (!value)
                    downloads.deleteByPlace(place.id);
                  else
                    await downloads.createByPlace(place, context);
                })
          ],
        ),
      );
    });
  }
}

// class StartButton extends StatelessWidget {
//   const StartButton(this.place);
//   final Place place;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 40,
//       width: MediaQuery.of(context).size.width - 40,
//       child: RaisedButton.icon(
//           color: Colors.red[900],
//           icon: Icon(Icons.directions_walk, color: Colors.white),
//           label: Text(
//             'start trip!',
//             style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//                 letterSpacing: 1.5),
//           ),
//           onPressed: () {
//             // Provider.of<TripProvider>(context, listen: false)
//             //     .trips
//             //     .firstWhere((t) => t.id == place.tripId);
//           }),
//     );
//   }
// }

const _statNumber = TextStyle(fontWeight: FontWeight.bold, fontSize: 22);

const _statTitle =
    TextStyle(color: Colors.black38, fontSize: 16, fontWeight: FontWeight.bold);
