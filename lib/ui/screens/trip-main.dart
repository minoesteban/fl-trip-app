import 'package:cached_network_image/cached_network_image.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../core/models/trip.model.dart';
import '../../providers/purchase.provider.dart';
import '../../providers/cart.provider.dart';
import '../../providers/language.provider.dart';
import '../../providers/country.provider.dart';
import '../../providers/user.provider.dart';
import '../../providers/trip.provider.dart';
import '../../ui/widgets/audio-components.dart';
import '../../ui/widgets/collapsible-text.dart';
import '../../ui/widgets/image-list.dart';
import '../widgets/store-trip-places-list.dart';
import '../widgets/store-trip-map.dart';
import 'cart-main.dart';

class TripMain extends StatelessWidget {
  static const routeName = '/trip';
  final Trip trip;

  TripMain(this.trip);

  @override
  Widget build(BuildContext context) {
    Position userPosition =
        Provider.of<UserProvider>(context, listen: false).user.position;

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          centerTitle: true,
          backgroundColor: Colors.red[900],
          floating: true,
          pinned: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => print('share'),
            ),
            Consumer<UserProvider>(
              builder: (_, user, __) => IconButton(
                iconSize: 30,
                icon: user.tripIsFavourite(trip.id)
                    ? const Icon(
                        Icons.favorite,
                      )
                    : const Icon(
                        Icons.favorite_border,
                      ),
                onPressed: () {
                  user.toggleFavouriteTrip(trip.id);
                },
              ),
            ),
          ],
          expandedHeight: MediaQuery.of(context).size.height / 3.5,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Text(
              '${trip.name}',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2),
            ),
            background: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: '${trip.imageUrl}',
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(
                  strokeWidth: 0.5,
                  valueColor: AlwaysStoppedAnimation(Colors.grey[100]),
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    if (trip.submitted && !trip.published) ...[
                      Text(
                          'this trip has been submitted and it is under review! we will let you know once it is published',
                          maxLines: 5,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      const Divider(height: 30),
                    ],
                    //location & purchase
                    ListTile(
                      title: Text(
                        Provider.of<CountryProvider>(context, listen: false)
                            .getName(trip.countryId),
                        softWrap: true,
                        style: _titleStyle,
                      ),
                      subtitle: Text(
                        'location',
                        style: _subtitleStyle,
                      ),
                      trailing: Consumer<UserProvider>(
                        builder: (_, user, __) => Builder(
                          builder: (ctx) => RaisedButton(
                              color: Colors.green[700],
                              child: Text(
                                user.tripIsPurchased(trip.id)
                                    ? 'purchased'
                                    : trip.price == 0
                                        ? 'add to cart   (free)'
                                        : 'add to cart    \$${trip.price}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 1.5),
                              ),
                              onPressed: user.tripIsPurchased(trip.id) ||
                                      trip.ownerId == user.user.id
                                  ? null
                                  : () {
                                      Provider.of<CartProvider>(context,
                                              listen: false)
                                          .addItem(trip, null);
                                      user.togglePurchasedTrip(trip.id);
                                      Scaffold.of(ctx).showSnackBar(
                                        SnackBar(
                                          duration: const Duration(seconds: 1),
                                          content:
                                              const Text('trip added to cart!'),
                                          action: SnackBarAction(
                                              label: 'GO TO CART',
                                              onPressed: () {
                                                Scaffold.of(ctx)
                                                    .hideCurrentSnackBar();
                                                Navigator.pushNamed(context,
                                                    CartMain.routeName);
                                              }),
                                        ),
                                      );
                                    }),
                        ),
                      ),
                    ),
                    const Divider(height: 30),
                    //downloads, rating and language
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              Provider.of<PurchaseProvider>(context,
                                      listen: false)
                                  .getCountBy(trip.id, 0)
                                  .toString(),
                              style: _titleBigStyle,
                            ),
                            Text(
                              'downloads',
                              style: _subtitleStyle,
                            ),
                          ],
                        ),
                        const VerticalDivider(),
                        FutureBuilder(
                            future: Provider.of<TripProvider>(context,
                                    listen: false)
                                .getAndSetTripRatings(trip.id),
                            builder: (_, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting)
                                return Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                        Colors.grey[200]),
                                  ),
                                );
                              else
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          snapshot.data.toStringAsPrecision(2),
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
                                  ],
                                );
                            }),
                        const VerticalDivider(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flag(
                              trip.languageFlagId.toUpperCase(),
                              height: 30,
                              width: 50,
                            ),
                            Text(
                              Provider.of<LanguageProvider>(context,
                                      listen: false)
                                  .getNativeName(trip.languageNameId),
                              style: _subtitleStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    //preview audio
                    if (trip.previewAudioUrl != null)
                      Player(trip.previewAudioUrl, true),
                    if (trip.previewAudioUrl != null) const Divider(height: 30),

                    //pictures
                    Container(
                      height: 100,
                      child: ListView.builder(
                          itemCount: trip.places.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, i) => InkWell(
                                onTap: () {
                                  showDialog(
                                      barrierDismissible: true,
                                      // barrierColor: Colors.black87,
                                      context: context,
                                      builder: (context) =>
                                          ImageList(trip.places[i].imageUrl));
                                },
                                child: Card(
                                  elevation: 1,
                                  child: Hero(
                                    tag: trip.places[i].imageUrl,
                                    child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl: trip.places[i].imageUrl,
                                        placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(
                                                strokeWidth: 0.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        Colors.grey[100]))),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error)),
                                  ),
                                ),
                              )),
                    ),
                    const Divider(height: 40),
                    //about text
                    Text('about the trip', style: _titleStyle),
                    CollapsibleText(trip.about),
                    const Divider(height: 40),
                    //map and place list
                    Text('places', style: _titleStyle),
                    Card(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10),
                            child: TripMap(trip, userPosition),
                          ),
                          ExpansionTile(
                            initiallyExpanded: true,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //TODO: obtener distancia total del trip (lineas con geometry?)
                                Text('total distance', style: _titleStyle),
                                Text('15.6 Km', style: _subtitleStyle),
                                const SizedBox(),
                              ],
                            ),
                            children: [
                              Container(
                                child: PlacesList(trip.places
                                  ..sort((a, b) => a.order.compareTo(b.order))),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ]),
        ),
      ]),
    );
  }

  final TextStyle _titleStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  final TextStyle _titleBigStyle =
      TextStyle(fontSize: 22, fontWeight: FontWeight.bold);

  final TextStyle _subtitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.black38,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.1,
  );
}
