import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flag/flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripit/ui/utils/show-message.dart';
import '../../core/models/user.model.dart';
import '../../core/utils/s3-auth-headers.dart';
import '../../core/models/trip.model.dart';
import '../../providers/purchase.provider.dart';
import '../../providers/cart.provider.dart';
import '../../providers/language.provider.dart';
import '../../providers/country.provider.dart';
import '../../providers/user.provider.dart';
import '../../providers/trip.provider.dart';
import '../widgets/audio-components.dart';
import '../widgets/collapsible-text.dart';
import '../widgets/image-list.dart';
import '../widgets/store-trip-places-list.dart';
import '../widgets/store-trip-map.dart';
import 'profile-main.dart';
import 'cart-main.dart';

class TripMain extends StatelessWidget {
  static const routeName = '/trip';
  final Trip trip;

  TripMain(this.trip);

  @override
  Widget build(BuildContext context) {
    Widget buildAppBar() {
      return SliverAppBar(
        centerTitle: true,
        backgroundColor: Colors.red[900],
        floating: true,
        pinned: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
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
                fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          background: CachedNetworkImage(
            httpHeaders: generateAuthHeaders(trip.imageUrl),
            fit: BoxFit.cover,
            imageUrl: trip.imageUrl,
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(
                strokeWidth: 0.5,
                valueColor: AlwaysStoppedAnimation(Colors.grey[100]),
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      );
    }

    List<Widget> buildSubmittedMessage() {
      return [
        Text(
            'this trip has been submitted and it is under review! we will let you know once it is published',
            maxLines: 5,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.red, fontSize: 22, fontWeight: FontWeight.bold)),
        const Divider(height: 30),
      ];
    }

    Widget buildLocationAndPurchase() {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
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
          builder: (_, user, __) => user.tripIsPurchased(trip.id) ||
                  user.user.id == trip.ownerId
              //TODO: switch to download trip audios locally + progress bar? or counter 1/5, 2/5, 3/5
              ? DownloadButton(trip: trip, user: user)
              : PurchaseButton(trip: trip),
        ),
      );
    }

    Widget buildDownloadsRatingLanguage() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  Provider.of<PurchaseProvider>(context, listen: false)
                      .getCountBy(trip.id, 0)
                      .toString(),
                  style: _titleBigStyle,
                ),
                Text('downloads', style: _subtitleStyle),
              ],
            ),
            const VerticalDivider(),
            FutureBuilder(
                future: Provider.of<TripProvider>(context, listen: false)
                    .getAndSetTripRatings(trip.id),
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.grey[200]),
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
                              snapshot.data?.toStringAsPrecision(2) ?? '-',
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
                  Provider.of<LanguageProvider>(context, listen: false)
                      .getNativeName(trip.languageNameId),
                  style: _subtitleStyle,
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget buildPictures() {
      return Container(
        height: 100,
        child: ListView.builder(
            itemCount: trip.places.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (ctx, i) => InkWell(
                  onTap: () {
                    List<String> images =
                        trip.places.map((e) => e.imageUrl).toList();
                    //TODO: remove when image carrousel is solved
                    images = [trip.places[i].imageUrl];

                    showDialog(
                        barrierDismissible: true,
                        // barrierColor: Colors.black87,
                        context: context,
                        builder: (context) => ImageList(images));
                  },
                  child: Card(
                    elevation: 1,
                    child: Hero(
                      tag: trip.places[i].imageUrl,
                      child: CachedNetworkImage(
                          httpHeaders:
                              generateAuthHeaders(trip.places[i].imageUrl),
                          fit: BoxFit.cover,
                          imageUrl: trip.places[i].imageUrl,
                          placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                  strokeWidth: 0.5,
                                  valueColor: AlwaysStoppedAnimation(
                                      Colors.grey[100]))),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error)),
                    ),
                  ),
                )),
      );
    }

    List<Widget> buildMapAndPlacesList() {
      return [
        Text('places', style: _titleStyle),
        Container(
          margin: const EdgeInsets.all(10),
          child: TripMap(trip),
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
              child: PlacesList(
                  trip.places..sort((a, b) => a.order.compareTo(b.order))),
            ),
          ],
        ),
      ];
    }

    List<Widget> buildCreator() {
      return [
        Text('your guide', style: _titleStyle),
        const SizedBox(height: 10),
        FutureBuilder(
            future: Provider.of<UserProvider>(context, listen: false)
                .getUser(trip.ownerId, false),
            builder: (_, AsyncSnapshot<User> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.hasError)
                return Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: LinearProgressIndicator(
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(Colors.grey[300])),
                );
              else
                return Center(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: ListTile(
                    onTap: () => Navigator.of(context).pushNamed(
                        Profile.routeName,
                        arguments: {'id': snapshot.data.id}),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: CachedNetworkImageProvider(
                        snapshot.data.imageUrl,
                        headers: generateAuthHeaders(snapshot.data.imageUrl),
                      ),
                    ),
                    title: Text(
                        '${snapshot.data.firstName} ${snapshot.data.lastName}',
                        style: _ownerNameStyle),
                    trailing: Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.grey[500],
                    ),
                  ),
                ));
            })
      ];
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          buildAppBar(),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      if (trip.submitted && !trip.published)
                        ...buildSubmittedMessage(),

                      buildLocationAndPurchase(),
                      const Divider(height: 10),
                      buildDownloadsRatingLanguage(),
                      const Divider(height: 30),

                      //preview audio
                      if (trip.previewAudioUrl != null)
                        Player(trip.previewAudioUrl, true, true),
                      if (trip.previewAudioUrl != null)
                        const SizedBox(height: 30),

                      buildPictures(),
                      const SizedBox(height: 40),

                      //about text
                      Text('about the trip', style: _titleStyle),
                      CollapsibleText(trip.about),
                      const SizedBox(height: 20),

                      ...buildCreator(),
                      const SizedBox(height: 40),

                      ...buildMapAndPlacesList(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final TextStyle _titleStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

final TextStyle _titleBigStyle =
    TextStyle(fontSize: 22, fontWeight: FontWeight.bold);

final TextStyle _ownerNameStyle =
    TextStyle(fontSize: 20, color: Colors.black54, fontWeight: FontWeight.bold);

final TextStyle _subtitleStyle = TextStyle(
  fontSize: 14,
  color: Colors.black38,
  fontWeight: FontWeight.bold,
  letterSpacing: 1.1,
);

class PurchaseButton extends StatelessWidget {
  const PurchaseButton({@required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) => RaisedButton(
          color: Colors.green[700],
          child: Text(
            trip.price == 0
                ? 'add to cart   (free)'
                : 'add to cart    \$${trip.price}',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1.5),
          ),
          onPressed: () {
            Provider.of<CartProvider>(context, listen: false)
                .addItem(trip, null);
            Scaffold.of(ctx).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 1),
                content: const Text('trip added to cart!'),
                action: SnackBarAction(
                    label: 'GO TO CART',
                    onPressed: () {
                      Scaffold.of(ctx).hideCurrentSnackBar();
                      Navigator.pushNamed(context, CartMain.routeName);
                    }),
              ),
            );
          }),
    );
  }
}

class DownloadButton extends StatelessWidget {
  const DownloadButton({
    Key key,
    @required this.trip,
    @required this.user,
  }) : super(key: key);

  final Trip trip;
  final UserProvider user;

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(builder: (context, trips, child) {
      var tripStatus = trips.isDownloaded(trip.id);
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          tripStatus == TripDownloadStatus.Downloaded
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('downloaded', style: _subtitleStyle),
                    const SizedBox(width: 10),
                    Icon(Icons.check, size: 30, color: Colors.red[800])
                  ],
                )
              : tripStatus == TripDownloadStatus.Downloading
                  ? DownloadProgressBar(trips, user, trip)
                  : Text('download', style: _subtitleStyle),
          const SizedBox(width: 10),
          Platform.isIOS
              ? CupertinoSwitch(
                  activeColor: Colors.red[800],
                  value: user.tripIsDownloaded(trip.id),
                  onChanged: (_) async {
                    try {
                      bool isDownloaded =
                          await user.toggleDownloadedTrip(trip.id);

                      if (!isDownloaded) {
                        trips.deleteTripFiles(trip);
                      } else if (trips.isDownloaded(trip.id) !=
                          TripDownloadStatus.Downloaded) {
                        await trips.downloadTripFiles(trip, context, user);
                      }
                    } catch (e) {
                      await user.toggleDownloadedTrip(trip.id);
                      showMessage(context, e, false);
                    }
                  })
              : Switch(
                  value: user.tripIsDownloaded(trip.id),
                  onChanged: (_) async {
                    try {
                      bool isDownloaded =
                          await user.toggleDownloadedTrip(trip.id);

                      if (!isDownloaded) {
                        trips.deleteTripFiles(trip);
                      } else if (trips.isDownloaded(trip.id) !=
                          TripDownloadStatus.Downloaded) {
                        await trips.downloadTripFiles(trip, context, user);
                      }
                    } catch (e) {
                      await user.toggleDownloadedTrip(trip.id);
                      showMessage(context, e, false);
                    }
                  })
        ],
      );
    });
  }
}

class DownloadProgressBar extends StatelessWidget {
  final TripProvider trips;
  final Trip trip;
  final UserProvider user;

  DownloadProgressBar(this.trips, this.user, this.trip);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 180,
          child: LinearProgressIndicator(
            value: trips.downloadPercentage,
          ),
        ),
      ],
    );
  }
}
