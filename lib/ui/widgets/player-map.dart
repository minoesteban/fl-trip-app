import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripper/core/models/place.model.dart';
import 'package:tripper/core/models/trip.model.dart';

class PlayerMap extends StatelessWidget {
  final Completer<GoogleMapController> _controller = Completer();
  final int selectedPlaceId;
  final Trip trip;
  PlayerMap(this.trip, [this.selectedPlaceId = 0]);

  Set<Marker> _loadMarkers() {
    Set<Marker> _markers = trip.places
        .map(
          (t) => Marker(
            //TODO: https://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=1|F13E3E|FFFFFF
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
    // Place selectedPlace =
    //     _trip.places.firstWhere((p) => p.id == selectedPlaceId);
    // _controller.future.then(
    //   (value) => value.animateCamera(
    //     CameraUpdate.newLatLngZoom(
    //         LatLng(selectedPlace.coordinates.latitude,
    //             selectedPlace.coordinates.longitude),
    //         13.5),
    //   ),
    // );
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
    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  }

  _centerMap(GoogleMapController controller) {
    Place selectedPlace =
        trip.places.firstWhere((p) => p.id == selectedPlaceId);
    Future.delayed(
        Duration(milliseconds: 200),
        () => controller.animateCamera(CameraUpdate.newLatLngZoom(
            LatLng(selectedPlace.coordinates.latitude,
                selectedPlace.coordinates.longitude),
            13.5)));
    // Future.delayed(
    //     Duration(milliseconds: 200),
    //     () => controller.animateCamera(CameraUpdate.newLatLngBounds(
    //         boundsFromLatLngList(trip.places
    //             .map((place) => LatLng(
    //                 place.coordinates.latitude, place.coordinates.longitude))
    //             .toList()),
    //         80)));
  }

  moveToMarker() {
    Place selectedPlace =
        trip.places.firstWhere((p) => p.id == selectedPlaceId);
    Future.delayed(
        Duration(milliseconds: 200),
        () => _controller.future.then((controller) => controller.animateCamera(
              CameraUpdate.newLatLngZoom(
                  LatLng(selectedPlace.coordinates.latitude,
                      selectedPlace.coordinates.longitude),
                  13.5),
            )));
  }

  @override
  Widget build(BuildContext context) {
    final CameraPosition _initialPosition = CameraPosition(
      target: LatLng(trip.places[0].coordinates.latitude,
          trip.places[0].coordinates.longitude),
      zoom: 13,
    );

    return GoogleMap(
      // liteModeEnabled: Platform.isAndroid ? true : null,
      buildingsEnabled: false,
      // mapToolbarEnabled: false,
      // myLocationButtonEnabled: false,
      myLocationEnabled: true,
      mapType: MapType.normal,
      initialCameraPosition: _initialPosition,
      markers: _loadMarkers(),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
        _centerMap(controller);
      },
    );
  }
}
