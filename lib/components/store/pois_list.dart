import 'package:flutter/material.dart';
import 'package:tripit/models/poi_model.dart';
import 'package:tripit/screens/store/poi-main.dart';

class PoisList extends StatefulWidget {
  final List<Poi> pois;
  final Function _handleSelectMarker;

  PoisList(this.pois, this._handleSelectMarker);

  @override
  _PoisListState createState() => _PoisListState();
}

class _PoisListState extends State<PoisList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.all(0),
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.pois.length,
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
                        child: PoiMain(widget.pois[index]),
                      ),
                    ),
                  );
                  widget._handleSelectMarker(widget.pois[index].key);
                },
                leading: Container(
                  width: 50,
                  height: 40,
                  child: Hero(
                    tag: '${widget.pois[index].key}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      child: Image.asset(
                        'assets/images/italy/${widget.pois[index].image}',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      widget.pois[index].name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                subtitle: Text(widget.pois[index].distanceFromUser > 1000
                    ? '${(widget.pois[index].distanceFromUser / 1000).toStringAsFixed(2)} Km'
                    : '${(widget.pois[index].distanceFromUser).toStringAsFixed(2)} m'),
                trailing: LayoutBuilder(builder: (ctx, cns) {
                  return Container(
                    width: cns.maxWidth / 2.8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${widget.pois[index].rating}',
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
                          onPressed: () {},
                          icon: Icon(Icons.play_circle_outline),
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
