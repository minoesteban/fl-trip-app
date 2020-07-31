import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../providers/filters.provider.dart';
import '../../providers/user.provider.dart';
import '../../core/models/trip.model.dart';
import '../../providers/trip.provider.dart';
import '../widgets/map-search.dart';
import '../widgets/map-places-list.dart';
import 'filters.dart';

class MapMain extends StatefulWidget {
  static const routeName = '/map';

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<MapMain> {
  Completer<GoogleMapController> _controller = Completer();
  PanelController _pc = new PanelController();
  TripProvider _tripProvider = TripProvider();
  String _selectedPlaceId;

  Set<Marker> _loadMarkers(List<Trip> trips) {
    Set<Marker> _markers = Set<Marker>();
    trips.forEach((trip) {
      _markers.addAll(trip.places
          .map(
            (t) => Marker(
              onTap: () {
                _pc.open();
                setState(() {
                  _selectedPlaceId = t.googlePlaceId;
                });
              },
              icon: BitmapDescriptor.defaultMarker,
              markerId: MarkerId(('${t.id};${t.googlePlaceId}')),
              draggable: false,
              position: LatLng(t.coordinates.latitude, t.coordinates.longitude),
              infoWindow: InfoWindow(title: t.name),
            ),
          )
          .toSet());
    });

    return _markers;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Position _userPosition = Provider.of<UserProvider>(context).user.position;
    _tripProvider = Provider.of<TripProvider>(context);
    List<Trip> _trips = _tripProvider.trips;
    Size _deviceSize = MediaQuery.of(context).size;
    var _filters = Provider.of<Filters>(context);

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
              context: context,
              delegate: MapSearch(_trips, _userPosition),
            );
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
                    value: _filters,
                    child: FiltersScreen(),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SlidingUpPanel(
        controller: _pc,
        parallaxEnabled: true,
        parallaxOffset: .5,
        renderPanelSheet: false,
        maxHeight: _deviceSize.height / 3,
        minHeight: 0,
        panelBuilder: (ScrollController sc) {
          return Center(
            child: PlaceList(
              selectedPlaceId: _selectedPlaceId,
            ),
          );
        },
        body: Consumer<Filters>(
          builder: (context, filters, _) => GoogleMap(
            trafficEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(_userPosition.latitude, _userPosition.longitude),
              zoom: 14,
            ),
            markers: _loadMarkers(_trips),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ),
      ),
    );
  }
}
