import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../widgets/map/map_search.dart';
import '../../widgets/map/poi_list.dart';
import '../../widgets/map/trip_list.dart';
import '../../models/trip_model.dart';

class Map extends StatefulWidget {
  final List<Trip> _trips;
  final Position _userPosition;

  Map(this._trips, this._userPosition);

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  Completer<GoogleMapController> _controller = Completer();
  bool _loaded = false;
  PanelController _pc = new PanelController();
  String _slidePanelViewItemType = 'trip';
  Trip _selectedTrip;
  String _selectedPlaceId;
  String _selectedPlaceName;

  handleChangeSlidePanelViewItemType(String type) {
    // Navigator.push(context, MaterialPageRoute(builder: (BuildContext ctx) => PoiList()));
    setState(() {
      _slidePanelViewItemType = type;
    });
  }

  Set<Marker> _loadMarkers() {
    Set<Marker> _markers = Set<Marker>();
    int _tripCount = 0;
    for (var trip in widget._trips) {
      _markers.addAll(trip.pois
          .map((t) => Marker(
              onTap: () {
                _pc.open();
                setState(() {
                  _selectedPlaceId = t.placeId;
                  _selectedPlaceName = t.name;
                  _selectedTrip = null;
                  _slidePanelViewItemType = 'poi';
                });
              },
              icon: BitmapDescriptor.defaultMarker,
              markerId: MarkerId(('${t.key};${t.placeId}')),
              draggable: false,
              position: LatLng(t.coordinates.latitude, t.coordinates.longitude),
              infoWindow:
                  InfoWindow(title: t.name, snippet: '$_tripCount trips')))
          .toSet());
    }
    return _markers;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Text('tripit',
              style:
                  TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          centerTitle: true,
          backgroundColor: Colors.red[900],
          leading: IconButton(
            onPressed: () async {
              Geometry result = await showSearch(
                  context: context,
                  delegate: MapSearch(widget._trips, widget._userPosition));
              if (result != null)
                _controller.future.then((value) => value.animateCamera(
                    CameraUpdate.newLatLngZoom(
                        LatLng(result.location.lat, result.location.lng),
                        13.5)));
            },
            icon: Icon(Icons.search),
          )),
      body: _loaded && widget._userPosition.latitude != null
          ? SlidingUpPanel(
              controller: _pc,
              parallaxEnabled: true,
              parallaxOffset: .5,
              margin: EdgeInsets.symmetric(horizontal: 0),
              maxHeight: MediaQuery.of(context).size.height / 2.5,
              minHeight: MediaQuery.of(context).size.height / 35,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              collapsed: Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.grey[500],
                          size: 30,
                        ),
                        onTap: () => _pc.open(),
                      ),
                    ]),
              ),
              panelBuilder: (ScrollController sc) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: _slidePanelViewItemType == 'trip'
                        ? TripList(
                            sc: sc,
                            trips: widget._trips,
                            userPosition: widget._userPosition,
                            mapController: _controller.future,
                          )
                        : PoiList(
                            trips: widget._trips,
                            userPosition: widget._userPosition,
                            selectedTrip: _selectedTrip,
                            selectedPlaceId: _selectedPlaceId,
                            selectedPlaceName: _selectedPlaceName,
                            mapController: _controller.future,
                            handleChangeSlidePanelViewItemType:
                                handleChangeSlidePanelViewItemType,
                          ),
                  ),
                );
              },
              body: Container(
                color: Colors.white,
                child: GoogleMap(
                  trafficEnabled: false,
                  compassEnabled: true,
                  mapToolbarEnabled: false,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(widget._userPosition.latitude,
                        widget._userPosition.longitude),
                    zoom: 14,
                  ),
                  markers: _loadMarkers(),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
              ),
            )
          : Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red[800]),
                ),
              ),
            ),
    );
  }
}
