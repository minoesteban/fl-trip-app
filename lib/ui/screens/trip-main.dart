import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flag/flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/download.provider.dart';
import '../../core/models/user.model.dart';
import '../../core/utils/s3-auth-headers.dart';
import '../../core/models/trip.model.dart';
import '../../providers/purchase.provider.dart';
import '../../providers/cart.provider.dart';
import '../../providers/language.provider.dart';
import '../../providers/country.provider.dart';
import '../../providers/user.provider.dart';
import '../../providers/trip.provider.dart';
import '../widgets/flat-player.dart';
import '../widgets/collapsible-text.dart';
import '../widgets/image-list.dart';
import '../widgets/store-trip-places-list.dart';
import '../widgets/store-trip-map.dart';
import 'profile-main.dart';
import 'cart-main.dart';
import 'trip-player.dart';

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
            httpHeaders: generateAuthHeaders(trip.imageUrl, context),
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
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trip.locationName.split(',')[0],
                  softWrap: true,
                  style: _titleStyle,
                ),
                Text(
                  Provider.of<CountryProvider>(context, listen: false)
                      .getName(trip.countryId),
                  style: _subtitleStyle,
                ),
              ],
            ),
            Consumer<UserProvider>(
              builder: (_, user, __) =>
                  user.tripIsPurchased(trip.id) || user.user.id == trip.ownerId
                      ? DownloadButton(trip)
                      // ? Text('purchased',
                      //     style: TextStyle(
                      //         color: Colors.black54,
                      //         fontWeight: FontWeight.bold))
                      : PurchaseButton(trip),
            ),
          ],
        ),
      );
    }

    Widget buildStats() {
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
                    List<String> names =
                        trip.places.map((e) => e.name).toList();
                    //TODO: remove when image carrousel is solved
                    // images = [trip.places[i].imageUrl];

                    showDialog(
                        barrierDismissible: true,
                        // barrierColor: Colors.black87,
                        context: context,
                        builder: (context) => ImageList(names, images, i));
                  },
                  child: Card(
                    elevation: 1,
                    child: Hero(
                      tag: trip.places[i].imageUrl,
                      child: CachedNetworkImage(
                          httpHeaders: generateAuthHeaders(
                              trip.places[i].imageUrl, context),
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
                        headers: generateAuthHeaders(
                            snapshot.data.imageUrl, context),
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
            }),
      ];
    }

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: StartButton(trip),
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
                      buildStats(),
                      const Divider(height: 30),
                      //preview audio
                      if (trip.previewAudioUrl != null)
                        Player(trip.previewAudioUrl, true, true),
                      if (trip.previewAudioUrl != null)
                        const SizedBox(height: 30),
                      buildPictures(),
                      const Divider(height: 40),
                      //about text
                      Text('about the trip', style: _titleStyle),
                      CollapsibleText(trip.about),
                      const Divider(height: 20),
                      ...buildCreator(),
                      const Divider(height: 40),
                      ...buildMapAndPlacesList(),
                      const SizedBox(height: 70),
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

class PurchaseButton extends StatelessWidget {
  const PurchaseButton(this.trip);
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) => RaisedButton(
          color: Colors.green[700],
          child: Text(
            trip.price == 0
                ? 'add to cart (free)'
                : 'add to cart \$${trip.price}',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
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
  const DownloadButton(this.trip);
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadProvider>(builder: (_, downloads, __) {
      return Row(
        children: [
          downloads.existsByTrip(trip.id, trip.places.length)
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('downloaded', style: _subtitleStyle),
                    const SizedBox(width: 10),
                    Icon(Icons.check, size: 30, color: Colors.red[800])
                  ],
                )
              : downloads.isDownloading
                  ? Container(
                      // constraints: BoxConstraints(maxWidth: 180, minWidth: 100),
                      width: 150,
                      child: LinearProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.red[600]),
                          value: downloads.downloadPercentage),
                    )
                  : Text('download', style: _subtitleStyle),
          const SizedBox(width: 10),
          CupertinoSwitch(
              activeColor: Colors.red[800],
              value: downloads.existsByTrip(trip.id, trip.places.length),
              onChanged: (value) async {
                if (!value)
                  downloads.deleteByTrip(trip.id);
                else
                  await downloads.createByTrip(trip, context);
              })
        ],
      );
    });
  }
}

enum StartTripOptions { DoNothing, StartNewTrip, ContinueCurrentTrip }

class StartButton extends StatelessWidget {
  const StartButton(this.trip);
  final Trip trip;

  Future<StartTripOptions> startNewTripDialog(
      BuildContext context, String currentTripName) async {
    return showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: RichText(
              text: TextSpan(
                text: currentTripName,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                ),
                children: [
                  TextSpan(
                    text: ' is currently on queue',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Nunito',
                    ),
                  )
                ],
              ),
            ),
            content: RichText(
              text: TextSpan(
                text: 'do you wish to continue with ',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontFamily: 'Nunito',
                ),
                children: [
                  TextSpan(
                    text: currentTripName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ', or ',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  TextSpan(
                    text: 'start trip ',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  TextSpan(
                    text: '${trip.name}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' ?',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontFamily: 'Nunito',
                    ),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'CANCEL',
                ),
                onPressed: () =>
                    Navigator.of(context).pop(StartTripOptions.DoNothing),
              ),
              FlatButton(
                child: Text(
                  'CONTINUE',
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
                onPressed: () => Navigator.of(context)
                    .pop(StartTripOptions.ContinueCurrentTrip),
              ),
              FlatButton(
                child: Text(
                  'START TRIP',
                  style: TextStyle(
                    color: Colors.green,
                  ),
                ),
                onPressed: () =>
                    Navigator.of(context).pop(StartTripOptions.StartNewTrip),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false);
    if (user.tripIsPurchased(trip.id) || user.user.id == trip.ownerId)
      return FloatingActionButton.extended(
          backgroundColor: Colors.red[900],
          icon: Icon(Icons.directions_walk, color: Colors.white),
          label: Text(
            'start trip!',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1.5),
          ),
          onPressed: () async {
            if (AudioService.playbackState?.processingState != null &&
                AudioService.playbackState?.processingState !=
                    AudioProcessingState.none &&
                AudioService.queue?.first?.album != trip.name) {
              Trip currentPlayingTrip =
                  Provider.of<TripProvider>(context, listen: false)
                      .findById(AudioService.currentMediaItem.extras['tripId']);
              var res = await startNewTripDialog(
                  context, AudioService.queue.first.album);
              switch (res) {
                case StartTripOptions.StartNewTrip:
                  Navigator.of(context).pushNamed(TripPlayer.routeName,
                      arguments: {'trip': trip});
                  break;
                case StartTripOptions.ContinueCurrentTrip:
                  Navigator.of(context).pushNamed(TripPlayer.routeName,
                      arguments: {'trip': currentPlayingTrip});
                  break;
                default:
                  return;
              }
            } else
              Navigator.of(context)
                  .pushNamed(TripPlayer.routeName, arguments: {'trip': trip});
          });
    else
      return Container();
  }
}

final TextStyle _titleStyle =
    TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

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
