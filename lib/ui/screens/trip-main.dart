import 'package:cached_network_image/cached_network_image.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../providers/cart.provider.dart';
import '../../providers/language.provider.dart';
import '../../providers/country.provider.dart';
import '../../providers/user.provider.dart';
import '../../providers/trip.provider.dart';
import '../../core/models/place.model.dart';
import '../../core/models/trip.model.dart';
import '../../ui/widgets/image-list.dart';
import '../widgets/store-trip-places-list.dart';
import '../widgets/store-trip-map.dart';
import 'cart-main.dart';

class TripMain extends StatefulWidget {
  static const routeName = '/trip';
  @override
  _TripMainState createState() => _TripMainState();
}

class _TripMainState extends State<TripMain> with TickerProviderStateMixin {
  TextOverflow _overflow = TextOverflow.ellipsis;
  int _maxLines = 5;
  AnimationController _audioController;
  AnimationController _playPauseController;
  bool _loadingRating = true;
  double _rating = 0.0;
  CountryProvider _countryProvider;
  UserProvider _userProvider;
  TripProvider _tripProvider;
  LanguageProvider _languageProvider;
  CartProvider _cart;

  void _toggleShowDescription() {
    setState(() {
      _maxLines = _maxLines == null ? 5 : null;
      _overflow = _overflow == null ? TextOverflow.ellipsis : null;
    });
  }

  @override
  void initState() {
    super.initState();
    _audioController =
        AnimationController(duration: Duration(seconds: 10), vsync: this);
    _audioController.addListener(() => setState(() {}));
    _playPauseController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _countryProvider = Provider.of<CountryProvider>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
    _audioController.dispose();
    _playPauseController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map _args = ModalRoute.of(context).settings.arguments;
    Trip _trip = _args['trip'];
    List<Place> _places = _trip.places;

    _userProvider = Provider.of<UserProvider>(context);
    _tripProvider = Provider.of<TripProvider>(context);
    _languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    _cart = Provider.of<CartProvider>(context, listen: false);

    Position _userPosition = _userProvider.user.position;

    if (_loadingRating)
      _tripProvider.getAndSetTripRatings(_trip.id).then((rating) {
        setState(() {
          _rating = rating;
          _loadingRating = false;
        });
      });

    String audioTime() {
      int duration = 75;
      return '${(Duration(seconds: duration).inMinutes.remainder(60) - (_audioController.value).toInt()).toString().padLeft(2, '0')}:${(Duration(seconds: duration).inSeconds.remainder(60) - (_audioController.value * 10).toInt()).toString().padLeft(2, '0')}';
    }

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          centerTitle: true,
          backgroundColor: Colors.red[900],
          floating: true,
          pinned: true,
          actions: [
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () => print('share'),
            ),
            IconButton(
              iconSize: 30,
              icon: _userProvider.tripIsFavourite(_trip.id)
                  ? Icon(
                      Icons.favorite,
                    )
                  : Icon(
                      Icons.favorite_border,
                    ),
              onPressed: () {
                _userProvider.toggleFavouriteTrip(_trip.id);
              },
            ),
          ],
          expandedHeight: MediaQuery.of(context).size.height / 3.5,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Text(
              '${_trip.name}',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2),
            ),
            background: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: '${_trip.pictureUrl}',
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
                    //location & purchase
                    ListTile(
                      title: Text(
                        '${_countryProvider.getName(_trip.countryId)}',
                        softWrap: true,
                        style: _titleStyle,
                      ),
                      subtitle: Text(
                        'location',
                        style: _subtitleStyle,
                      ),
                      trailing: Builder(
                        builder: (ctx) => RaisedButton(
                            color: Colors.green[700],
                            child: Text(
                              _userProvider.tripIsPurchased(_trip.id)
                                  ? 'purchased'
                                  : 'add to cart \$${_trip.price}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: 1.5),
                            ),
                            onPressed: _userProvider.tripIsPurchased(_trip.id)
                                ? null
                                : () {
                                    _cart.addItem(_trip, null);
                                    _userProvider.togglePurchasedTrip(_trip.id);
                                    Scaffold.of(ctx).showSnackBar(
                                      SnackBar(
                                        duration: Duration(seconds: 1),
                                        content: Text(
                                          'trip added to cart!',
                                        ),
                                        action: SnackBarAction(
                                            label: 'GO TO CART',
                                            onPressed: () {
                                              Scaffold.of(ctx)
                                                  .hideCurrentSnackBar();
                                              Navigator.pushNamed(
                                                  context, CartMain.routeName);
                                            }),
                                      ),
                                    );
                                  }),
                      ),
                    ),

                    Divider(
                      height: 30,
                    ),
                    //downloads, rating and language
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              //TODO: obtener cantidad de purchases? o de ratings
                              '15.6k',
                              style: _titleBigStyle,
                            ),
                            Text(
                              'downloads',
                              style: _subtitleStyle,
                            ),
                          ],
                        ),
                        VerticalDivider(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${_rating.toStringAsPrecision(2)}',
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
                        ),
                        VerticalDivider(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flag(
                              _trip.languageFlagId.toUpperCase(),
                              height: 30,
                              width: 50,
                            ),
                            Text(
                              '${_languageProvider.getNativeName(_trip.languageNameId)}',
                              style: _subtitleStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(
                      height: 30,
                    ),
                    //preview audio
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              progress: _playPauseController,
                              color: Colors.green,
                              size: 35,
                            ),
                            onPressed: () {
                              if (_audioController.isAnimating) {
                                _playPauseController.reverse();
                                _audioController.stop();
                              } else {
                                if (_audioController.isDismissed) {
                                  _playPauseController.forward();
                                  _audioController.forward().then((_) {
                                    _audioController.value = 0;
                                    _playPauseController.reset();
                                  });
                                } else {
                                  _playPauseController.forward();
                                  _audioController.forward().then((_) {
                                    _audioController.value = 0;
                                    _playPauseController.reset();
                                  });
                                }
                              }
                            }),
                        Flexible(
                          child: LinearProgressIndicator(
                            value: _audioController.value,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation(Colors.green),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          audioTime(),
                          style: _subtitleStyle,
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                    Divider(
                      height: 30,
                    ),
                    //pictures
                    Container(
                      height: 100,
                      child: ListView.builder(
                          itemCount: _trip.places.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, i) => InkWell(
                                onTap: () {
                                  showDialog(
                                      barrierDismissible: true,
                                      // barrierColor: Colors.black87,
                                      context: context,
                                      builder: (context) => ImageList(
                                          _trip.places[i].pictureUrl1));
                                },
                                child: Card(
                                  elevation: 1,
                                  child: Hero(
                                    tag: '${_trip.places[i].pictureUrl1}',
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl:
                                          '${_trip.places[i].pictureUrl1}',
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 0.5,
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.grey[100]),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              )),
                    ),
                    Divider(
                      height: 30,
                    ),
                    //about text
                    Text(
                      'about the trip',
                      style: _titleStyle,
                    ),
                    InkWell(
                      onTap: () => _toggleShowDescription(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Text(
                          '${_trip.about}',
                          maxLines: _maxLines,
                          textAlign: TextAlign.justify,
                          overflow: _overflow,
                        ),
                      ),
                    ),
                    Divider(
                      height: 30,
                    ),
                    //map and place list
                    Card(
                      child: Column(
                        children: [
                          Container(
                            child: TripMap(_trip, _userPosition),
                          ),
                          ExpansionTile(
                            initiallyExpanded: true,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //TODO: obtener distancia total del trip (lineas con geometry?)
                                Text(
                                  'total distance',
                                  style: _titleStyle,
                                ),
                                Text(
                                  '15.6 Km',
                                  style: _subtitleStyle,
                                ),
                                SizedBox(),
                              ],
                            ),
                            children: [
                              Container(
                                child: PlacesList(_places),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  TextStyle _titleStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  TextStyle _titleBigStyle =
      TextStyle(fontSize: 22, fontWeight: FontWeight.bold);

  TextStyle _subtitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.black38,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.1,
  );
}

// var _sortMenu = Padding(
//   padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
//   child: Row(
//     crossAxisAlignment: CrossAxisAlignment.end,
//     mainAxisAlignment: MainAxisAlignment.end,
//     children: <Widget>[
//       SortMenu(currentOption, handleChangeSortOption),
//     ],
//   ),
// )
