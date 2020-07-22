import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tripit/providers/filters-provider.dart';
import 'package:tripit/providers/user-position-provider.dart';
import 'package:tripit/core/models/trip-model.dart';
import 'package:tripit/providers/trips-provider.dart';
import 'filters.dart';
import '../widgets/map-search.dart';
import '../widgets/map-places-list.dart';

class MapMain extends StatefulWidget {
  static const routeName = '/map';

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<MapMain> {
  Completer<GoogleMapController> _controller = Completer();
  bool _loaded = false;
  PanelController _pc = new PanelController();
  PageController _pvc = new PageController();
  Trip _selectedTrip;
  String _selectedPlaceId;
  String _selectedPlaceName;

  handleChangeSlidePanelViewItemType(String type) {
    _pvc.animateToPage(0,
        duration: Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  Set<Marker> _loadMarkers(List<Trip> trips) {
    Set<Marker> _markers = Set<Marker>();
    int _tripCount = 0;
    for (var trip in trips) {
      _markers.addAll(trip.places
          .map(
            (t) => Marker(
              onTap: () {
                _pc.open();
                // _pvc.animateToPage(1,
                //     duration: Duration(milliseconds: 300),
                //     curve: Curves.easeIn);
                setState(() {
                  _selectedPlaceId = t.placeId;
                  _selectedPlaceName = t.name;
                  _selectedTrip = null;
                });
              },
              icon: BitmapDescriptor.defaultMarker,
              markerId: MarkerId(('${t.id};${t.placeId}')),
              draggable: false,
              position: LatLng(t.coordinates.latitude, t.coordinates.longitude),
              infoWindow:
                  InfoWindow(title: t.name, snippet: '$_tripCount trips'),
            ),
          )
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
    var _trips = Provider.of<Trips>(context).trips;
    var _userPosition = Provider.of<UserPosition>(context).getPosition;
    var _mq = MediaQuery.of(context);
    var _filters = Provider.of<Filters>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'tripit',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: Colors.red[900],
        leading: IconButton(
          onPressed: () async {
            _pc.close();
            Geometry result = await showSearch(
                context: context, delegate: MapSearch(_trips, _userPosition));
            if (result != null)
              _controller.future.then(
                (value) => value.animateCamera(
                  CameraUpdate.newLatLngZoom(
                      LatLng(result.location.lat, result.location.lng), 13.5),
                ),
              );
          },
          icon: Icon(Icons.search),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.tune),
              onPressed: () async {
                await showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (_) {
                      return ChangeNotifierProvider.value(
                          value: _filters, child: FiltersScreen());
                    });
              }),
        ],
      ),
      body: _loaded //&& _userPosition.latitude != null
          ? SlidingUpPanel(
              controller: _pc,
              parallaxEnabled: true,
              parallaxOffset: .5,
              renderPanelSheet: false,
              maxHeight: _mq.size.height / 3,
              minHeight: 0,
              panelBuilder: (ScrollController sc) {
                return Center(
                  child: Consumer<Filters>(
                    builder: (context, value, child) => PlaceList(
                      trips: _trips,
                      userPosition: _userPosition,
                      selectedTrip: _selectedTrip,
                      selectedPlaceId: _selectedPlaceId,
                      selectedPlaceName: _selectedPlaceName,
                      mapController: _controller.future,
                    ),
                  ),
                );
              },
              body: GoogleMap(
                trafficEnabled: false,
                compassEnabled: true,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target:
                      LatLng(_userPosition.latitude, _userPosition.longitude),
                  zoom: 14,
                ),
                markers: _loadMarkers(_trips),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
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
