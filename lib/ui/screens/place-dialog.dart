import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tripit/core/models/place-model.dart';

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
  Widget build(BuildContext context) {
    return AlertDialog(
      useMaterialBorderRadius: true,
      scrollable: true,
      titlePadding: EdgeInsets.all(0),
      title: Stack(alignment: Alignment.bottomCenter, children: [
        Hero(
          tag: '${widget._place.id}_image',
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4), topRight: Radius.circular(4)),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
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
                IconButton(
                  icon: Icon(Icons.favorite),
                  onPressed: () {},
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ]),
      content: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget._place.rating}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 28,
                        color: Colors.amber[500],
                        fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.amber[500],
                    size: 20,
                  ),
                ],
              ),
              VerticalDivider(),
              Column(
                children: [
                  Text(
                    '18.6k',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    'downloads',
                    style: TextStyle(color: Colors.black38, fontSize: 12),
                  ),
                ],
              ),
              VerticalDivider(),
              Column(
                children: [
                  Text(
                    '17min',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    'audio length',
                    style: TextStyle(color: Colors.black38, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
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
              // Text(
              //   '1:00',
              //   style: TextStyle(color: Colors.black38, fontSize: 12),
              // ),
              // SizedBox(width: 10),
            ],
          ),
          InkWell(
            onTap: () => _toggleShowDescription(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                '${widget._place.description}',
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
              child: RaisedButton(
                  color: Colors.green[400],
                  child: Text(
                    'purchase place (\$${widget._place.price})',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2),
                  ),
                  onPressed: () {}),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: SizedBox(
              height: 40,
              width: MediaQuery.of(context).size.width - 40,
              child: RaisedButton(
                  color: Colors.green[700],
                  child: Text(
                    'purchase full trip (\$${widget._place.price})',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2),
                  ),
                  onPressed: () {}),
            ),
          ),
        ],
      ),
    );
  }
}
