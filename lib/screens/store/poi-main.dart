import 'package:flutter/material.dart';
import 'package:tripit/models/poi_model.dart';

class PoiMain extends StatefulWidget {
  final Poi _poi;

  PoiMain(this._poi);

  @override
  _PoiMainState createState() => _PoiMainState();
}

class _PoiMainState extends State<PoiMain> with SingleTickerProviderStateMixin {
  TextOverflow _overflow = TextOverflow.ellipsis;
  int _maxLines = 5;
  AnimationController _animationController;

  void _toggleShowDescription() {
    setState(() {
      _maxLines = _maxLines == null ? 5 : null;
      _overflow = _overflow == null ? TextOverflow.ellipsis : null;
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: Duration(seconds: 10), vsync: this);
    _animationController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      useMaterialBorderRadius: true,
      scrollable: true,
      titlePadding: EdgeInsets.all(0),
      title: Stack(alignment: Alignment.bottomCenter, children: [
        Hero(
          tag: '${widget._poi.key}',
          child: Image.asset(
            'assets/images/italy/${widget._poi.image}',
            fit: BoxFit.fill,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget._poi.name}',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              IconButton(
                icon: Icon(Icons.favorite),
                onPressed: () {},
                color: Colors.white,
              ),
            ],
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
                    '${widget._poi.rating}',
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
            children: [
              IconButton(
                  icon: Icon(
                    Icons.play_circle_outline,
                    color: Colors.green,
                    size: 30,
                  ),
                  onPressed: () {
                    _animationController.value = 0;
                    _animationController.forward();
                  }),
              Flexible(
                child: LinearProgressIndicator(
                  value: _animationController.value,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation(Colors.green),
                ),
              ),
              SizedBox(width: 10),
              // Text(
              //   '1:00',
              //   style: TextStyle(color: Colors.black38, fontSize: 12),
              // ),
              SizedBox(width: 10),
            ],
          ),
          InkWell(
            onTap: () => _toggleShowDescription(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                '${widget._poi.description}',
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
                    'purchase place (\$${widget._poi.price})',
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
                    'purchase full trip (\$${widget._poi.price})',
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
