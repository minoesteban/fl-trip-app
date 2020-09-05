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
    Set<Marker> markers = Set<Marker>();
    trips.forEach((trip) {
      if (trip.places != null && trip.places.length > 1)
        markers.addAll(trip.places
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
                position:
                    LatLng(t.coordinates.latitude, t.coordinates.longitude),
                infoWindow: InfoWindow(title: t.name),
              ),
            )
            .toSet());
    });

    return markers;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Position userPosition =
        Provider.of<UserProvider>(context, listen: false).user.position;
    _tripProvider = Provider.of<TripProvider>(context);
    List<Trip> trips =
        _tripProvider.trips.where((trip) => trip.published).toList();
    Size deviceSize = MediaQuery.of(context).size;

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
              delegate: MapSearch(trips, userPosition),
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
                  return FiltersScreen();
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
        maxHeight: deviceSize.height / 2.3,
        minHeight: 50,
        collapsed: _selectedPlaceId != null && _selectedPlaceId != ''
            ? Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.grey,
                    ),
                    onPressed: () => _pc.open()),
              )
            : null,
        panelBuilder: (ScrollController sc) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: PlaceList(
                selectedPlaceId: _selectedPlaceId,
              ),
            ),
          );
        },
        body: Consumer<Filters>(
          builder: (context, filters, _) => GoogleMap(
            trafficEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: true,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(userPosition.latitude, userPosition.longitude),
              zoom: 14,
            ),
            markers: _loadMarkers(trips),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ),
      ),
    );
  }
}
