import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tripit/core/models/place.model.dart';
import '../screens/place-dialog.dart';

class PlacesList extends StatefulWidget {
  final List<Place> places;

  PlacesList(this.places);

  @override
  _PlacesListState createState() => _PlacesListState();
}

class _PlacesListState extends State<PlacesList> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    List<AnimationController> _playPauseControllers = [];

    _playPauseControllers.addAll(widget.places
        .map((e) => AnimationController(
            duration: const Duration(milliseconds: 200), vsync: this))
        .toList());

    return ListView.builder(
        padding: EdgeInsets.all(0),
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.places.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
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
                        child: PlaceDialog(widget.places[index]),
                      ),
                    ),
                  );
                },
                leading: Container(
                  width: 50,
                  height: 40,
                  child: Hero(
                    tag: '${widget.places[index].id}_image',
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: '${widget.places[index].pictureUrl1}',
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 0.5,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.grey[100]),
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
                        '${widget.places[index].name}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                //TODO:obtener distancia del usuario al place
                // subtitle: Text(widget.places[index].distanceFromUser > 1000
                //     ? '${(widget.places[index].distanceFromUser / 1000).toStringAsFixed(2)} Km'
                //     : '${(widget.places[index].distanceFromUser).toStringAsFixed(2)} m'),
                trailing: LayoutBuilder(builder: (ctx, cns) {
                  return Container(
                    // width: cns.maxWidth / 3,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              //TODO: obtener rating del place
                              '7.6',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 15,
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            _playPauseControllers[index].isDismissed
                                ? _playPauseControllers[index].forward()
                                : _playPauseControllers[index].reverse();
                          },
                          iconSize: 35,
                          icon: AnimatedIcon(
                            icon: AnimatedIcons.play_pause,
                            progress: _playPauseControllers[index],
                          ),
                          color: Colors.green[300],
                        ),
                      ],
                    ),
                  );
                })),
          );
        });
  }
}