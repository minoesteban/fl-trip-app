import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripit/models/poi_model.dart';
import 'package:tripit/models/trip_model.dart';

class TripMap extends StatefulWidget {
  final Position userPosition;
  final Trip trip;
  final String selectedPoiKey;

  TripMap(this.trip, this.userPosition, this.selectedPoiKey);

  @override
  _TripMapState createState() => _TripMapState();
}

class _TripMapState extends State<TripMap> {
  Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _loadMarkers(Trip _trip) {
    Set<Marker> _markers = _trip.pois
        .map((t) => Marker(
            markerId: MarkerId(t.key),
            draggable: false,
            position: LatLng(t.coordinates.latitude, t.coordinates.longitude),
            infoWindow: InfoWindow(
                title: t.name, snippet: 'Rating ${t.rating.toString()} / 5')))
        .toSet();
    return _markers;
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
        northeast: LatLng(x1 + 0.005, y1 + 0.005),
        southwest: LatLng(x0 - 0.005, y0 - 0.005));
  }

  _centerMap(GoogleMapController controller) {
    Future.delayed(
        Duration(milliseconds: 200),
        () => controller.animateCamera(CameraUpdate.newLatLngBounds(
            boundsFromLatLngList(widget.trip.pois
                .map((poi) =>
                    LatLng(poi.coordinates.latitude, poi.coordinates.longitude))
                .toList()),
            1)));
  }

  _moveToMarker(GoogleMapController controller, String selectedPoiKey) {
    Poi selectedPoi =
        widget.trip.pois.singleWhere((poi) => poi.key == selectedPoiKey);
    Future.delayed(
        Duration(milliseconds: 200),
        () => controller.animateCamera(CameraUpdate.newLatLngBounds(
            boundsFromLatLngList([
              LatLng(selectedPoi.coordinates.latitude,
                  selectedPoi.coordinates.longitude)
            ]),
            1)));
  }

  @override
  Widget build(BuildContext context) {
    final CameraPosition _initialPosition = CameraPosition(
      target: LatLng(widget.trip.region.latitude, widget.trip.region.longitude),
      zoom: 13,
    );

    return Container(
      height: 300,
      padding: EdgeInsets.all(10),
      child: GoogleMap(
        liteModeEnabled: Platform.isAndroid ? true : null,
        buildingsEnabled: false,
        mapToolbarEnabled: false,
        myLocationButtonEnabled: false,
        myLocationEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: _initialPosition,
        markers: _loadMarkers(widget.trip),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          print('${widget.selectedPoiKey}');
          widget.selectedPoiKey == null
              ? _centerMap(controller)
              : _moveToMarker(controller, widget.selectedPoiKey);
        },
      ),
    );
  }
}
