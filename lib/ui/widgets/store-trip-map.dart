import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripit/core/models/trip.model.dart';

class TripMap extends StatelessWidget {
  final Trip trip;
  final int selectedPlaceId;
  TripMap(this.trip, [this.selectedPlaceId = 0]);

  void markSelectedPlace(int id) {}

  Set<Marker> _loadMarkers(Trip _trip) {
    Set<Marker> _markers = _trip.places
        .map(
          (t) => Marker(
            icon: selectedPlaceId == null || selectedPlaceId == 0
                ? BitmapDescriptor.defaultMarker
                : selectedPlaceId == t.id
                    ? BitmapDescriptor.defaultMarker
                    : BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueAzure,
                      ),
            markerId: MarkerId(t.id.toString()),
            draggable: false,
            position: LatLng(t.coordinates.latitude, t.coordinates.longitude),
            infoWindow: InfoWindow(title: t.name),
          ),
        )
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
        northeast: LatLng(x1 + 0.01, y1 + 0.005),
        southwest: LatLng(x0 - 0.005, y0 - 0.005));
  }

  _centerMap(GoogleMapController controller) {
    Future.delayed(
        Duration(milliseconds: 200),
        () => controller.animateCamera(CameraUpdate.newLatLngBounds(
            boundsFromLatLngList(trip.places
                .map((place) => LatLng(
                    place.coordinates.latitude, place.coordinates.longitude))
                .toList()),
            1)));
  }

  @override
  Widget build(BuildContext context) {
    final CameraPosition _initialPosition = CameraPosition(
      target: LatLng(trip.places[0].coordinates.latitude,
          trip.places[0].coordinates.longitude),
      zoom: 13,
    );

    return Container(
      height: 300,
      // padding: EdgeInsets.all(10),
      child: GoogleMap(
        liteModeEnabled: Platform.isAndroid ? true : null,
        buildingsEnabled: false,
        mapToolbarEnabled: false,
        myLocationButtonEnabled: false,
        myLocationEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: _initialPosition,
        markers: _loadMarkers(trip),
        onMapCreated: (GoogleMapController controller) {
          Completer<GoogleMapController> _controller = Completer();
          _controller.complete(controller);
          _centerMap(controller);
        },
      ),
    );
  }
}
