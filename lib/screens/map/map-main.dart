import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tripit/components/map/map_search.dart';
import 'package:tripit/components/poi/poi_list.dart';
import 'package:tripit/components/trip/trip_list.dart';
import 'package:tripit/models/trip_model.dart';
import 'package:tripit/services/load-trips.dart' as TripService;

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  Completer<GoogleMapController> _controller = Completer();
  List<Trip> _trips = [];
  Position _userPosition = Position();
  bool _loaded = false;
  PanelController _pc = new PanelController();
  String _slidePanelViewItemType = 'trip';
  Trip _selectedTrip;
  String _selectedPlaceId;
  String _selectedPlaceName;

  handleChangeSlidePanelViewItemType(String type) {
    setState(() {
      _slidePanelViewItemType = type;
    });
  }

  Future setInitData() async {
    await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((value) => _userPosition = value)
        .catchError((err) => print('getCurrentPosition $err'));

    await TripService.loadTrips(_userPosition)
        .then((value) => _trips = value)
        .catchError((err) => print('loadTrips $err'));
  }

  Set<Marker> _loadMarkers() {
    Set<Marker> _markers = Set<Marker>();
    int _tripCount = 0;
    for (var trip in _trips) {
      _markers.addAll(trip.pois
          .map((t) => Marker(
              onTap: () {
                if (_pc.isPanelClosed) _pc.open();
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
    setInitData().then((val) => setState(() {
          _loaded = true;
          _userPosition = _userPosition;
          _trips = _trips;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Text('tripit.',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          centerTitle: true,
          backgroundColor: Colors.red[900],
          leading: IconButton(
            onPressed: () {
              showSearch(context: context, delegate: DataSearch());
            },
            icon: Icon(Icons.search),
          )),
      body: _loaded && _userPosition.latitude != null
          ? SlidingUpPanel(
              controller: _pc,
              parallaxEnabled: true,
              parallaxOffset: .5,
              margin: EdgeInsets.symmetric(horizontal: 0),
              maxHeight:
                  MediaQuery.of(context).orientation == Orientation.portrait
                      ? MediaQuery.of(context).size.height / 1.5
                      : MediaQuery.of(context).size.width / 4,
              minHeight:
                  MediaQuery.of(context).orientation == Orientation.portrait
                      ? MediaQuery.of(context).size.height / 25
                      : MediaQuery.of(context).size.width / 25,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50.0),
                topRight: Radius.circular(50.0),
              ),
              collapsed: Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      IconButton(
                        padding: EdgeInsets.all(0),
                        icon: Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.grey[500],
                          size: 30,
                        ),
                        onPressed: () => _pc.open(),
                      ),
                    ]),
              ),
              panelBuilder: (ScrollController sc) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: _slidePanelViewItemType == 'trip'
                        ? TripList(
                            sc: sc,
                            trips: _trips,
                            userPosition: _userPosition,
                            mapController: _controller.future,
                          )
                        : PoiList(
                            trips: _trips,
                            userPosition: _userPosition,
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
                    target:
                        LatLng(_userPosition.latitude, _userPosition.longitude),
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
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[300]),
                ),
              ),
            ),
    );
  }
}
