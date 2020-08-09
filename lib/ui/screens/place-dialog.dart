import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripit/providers/trip.provider.dart';
import '../../core/models/place.model.dart';
import '../../providers/cart.provider.dart';
import '../../providers/user.provider.dart';

class PlaceDialog extends StatefulWidget {
  static const routeName = '/trip/place-dialog';
  final Place _place;

  PlaceDialog(this._place);

  @override
  _PlaceDialogState createState() => _PlaceDialogState();
}

class _PlaceDialogState extends State<PlaceDialog>
    with TickerProviderStateMixin {
  TextOverflow _overflow = TextOverflow.ellipsis;
  int _maxLines = 5;
  AnimationController _audioController;
  AnimationController _playPauseController;

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
  }

  @override
  void dispose() {
    _audioController.dispose();
    _playPauseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      titlePadding: const EdgeInsets.all(0),
      title: Stack(alignment: Alignment.bottomCenter, children: [
        Hero(
          tag: '${widget._place.id}_image',
          child: CachedNetworkImage(
            fit: BoxFit.fitWidth,
            imageUrl: '${widget._place.imageUrl}',
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
                  '${widget._place.name}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Consumer<UserProvider>(
                  builder: (_, user, __) => IconButton(
                    icon: user.placeIsFavourite(widget._place.id)
                        ? Icon(Icons.favorite)
                        : Icon(Icons.favorite_border),
                    onPressed: () {
                      user.toggleFavouritePlace(widget._place.id);
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
                    '${widget._place.rating.count}',
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
                    '${widget._place.rating.rating.toStringAsPrecision(2)}',
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
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
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
            ],
          ),
          //about
          InkWell(
            onTap: () => _toggleShowDescription(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                '${widget._place.about}',
                maxLines: _maxLines,
                textAlign: TextAlign.justify,
                overflow: _overflow,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
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
                        user.placeIsPurchased(widget._place.id) ||
                                user.tripIsPurchased(
                                    trips.findById(widget._place.tripId).id)
                            ? 'purchased'
                            : 'add to cart (\$${widget._place.price.toStringAsPrecision(2)})',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 1.5),
                      ),
                      onPressed: user.placeIsPurchased(widget._place.id) ||
                              user.tripIsPurchased(
                                  trips.findById(widget._place.tripId).id)
                          ? null
                          : () {
                              Provider.of<CartProvider>(context, listen: false)
                                  .addItem(null, widget._place);
                              user.togglePurchasedPlace(widget._place.id);
                              Navigator.pop(context,
                                  user.placeIsPurchased(widget._place.id));
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
