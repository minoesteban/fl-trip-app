import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tripit/core/trip/trip-model.dart';
import 'package:tripit/credentials.dart';

final places = GoogleMapsPlaces(apiKey: PLACES_API_KEY);

class HomeSearch extends SearchDelegate<Geometry> {
  List<Trip> _trips = [];

  HomeSearch(this._trips);

  var recentResults = [];

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      textTheme: theme.textTheme.copyWith(
          headline6: theme.textTheme.headline6
              .copyWith(color: theme.primaryTextTheme.headline6.color)),
      primaryColor: Colors.red[900],
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        hintStyle: theme.textTheme.headline6.copyWith(
          color: Colors.white70,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResponses();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildResponses();
  }

  _buildResponses() {
    if (query.length > 2) {
      List<Map<String, String>> _countries = getCountries(_trips, query);
      List<Map<String, String>> _cities = getCities(_trips, query);
      List<Map<String, String>> _tripNames = getTrips(_trips, query);
      List<Map<String, String>> _places = getPlaces(_trips, query);

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_places.isNotEmpty)
                ListView.builder(
                    padding: EdgeInsets.all(0),
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _places.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          onTap: () async {
                            PlacesDetailsResponse details =
                                await places.getDetailsByPlaceId(
                              _places[index]['id'],
                              language: Platform.localeName.split('_')[0],
                            );
                            if (!details.isOkay)
                              print(
                                  'error en get place details ${details.errorMessage}');
                            else
                              close(context, details.result.geometry);
                          },
                          leading: Icon(Icons.place),
                          title: Text(
                            _places[index]['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            'place',
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                        ),
                      );
                    }),
              if (_tripNames.isNotEmpty)
                ListView.builder(
                    padding: EdgeInsets.all(0),
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _tripNames.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          onTap: () async {
                            PlacesDetailsResponse details =
                                await places.getDetailsByPlaceId(
                              _tripNames[index]['id'],
                              language: Platform.localeName.split('_')[0],
                            );
                            if (!details.isOkay)
                              print(
                                  'error en get place details ${details.errorMessage}');
                            else
                              close(context, details.result.geometry);
                          },
                          leading: Icon(Icons.map),
                          title: Text(
                            _tripNames[index]['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            'trip',
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                        ),
                      );
                    }),
              if (_cities.isNotEmpty)
                ListView.builder(
                    padding: EdgeInsets.all(0),
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _cities.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          onTap: () async {
                            PlacesDetailsResponse details =
                                await places.getDetailsByPlaceId(
                              _cities[index]['id'],
                              language: Platform.localeName.split('_')[0],
                            );
                            if (!details.isOkay)
                              print(
                                  'error en get place details ${details.errorMessage}');
                            else
                              close(context, details.result.geometry);
                          },
                          leading: Icon(Icons.location_city),
                          title: Text(
                            _cities[index]['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            'city / region',
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                        ),
                      );
                    }),
              if (_countries.isNotEmpty)
                ListView.builder(
                    padding: EdgeInsets.all(0),
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _countries.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          onTap: () async {
                            PlacesDetailsResponse details =
                                await places.getDetailsByPlaceId(
                              _countries[index]['id'],
                              language: Platform.localeName.split('_')[0],
                            );
                            if (!details.isOkay)
                              print(
                                  'error en get place details ${details.errorMessage}');
                            else
                              close(context, details.result.geometry);
                          },
                          leading: Icon(Icons.flag),
                          title: Text(
                            _countries[index]['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            'country',
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                        ),
                      );
                    }),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}

getCountries(List<Trip> _trips, String searchValue) {
  List<Map<String, String>> _countries = [];
  _trips
      .where((trip) =>
          trip.country.toLowerCase().contains(searchValue.toLowerCase()))
      .toList()
      .forEach((trip) {
    if (_countries.firstWhere(
            (e) =>
                e['name'].toLowerCase() == trip.country.toLowerCase() &&
                e['id'] == trip.placeId,
            orElse: () => null) ==
        null) _countries.add({'name': trip.country, 'id': trip.placeId});
  });
  _countries = _countries.toSet().toList();
  return _countries;
}

getCities(List<Trip> _trips, String searchValue) {
  List<Map<String, String>> _cities = [];
  _trips
      .where(
          (trip) => trip.city.toLowerCase().contains(searchValue.toLowerCase()))
      .toList()
      .forEach((trip) {
    if (_cities.firstWhere(
            (e) =>
                e['name'].toLowerCase() ==
                    '${trip.city}, ${trip.country}'.toLowerCase() &&
                e['id'] == trip.placeId,
            orElse: () => null) ==
        null)
      _cities
          .add({'name': '${trip.city}, ${trip.country}', 'id': trip.placeId});
  });
  _cities = _cities.toSet().toList();
  return _cities;
}

getTrips(List<Trip> _trips, String searchValue) {
  List<Map<String, String>> _tripNames = [];
  _trips
      .where(
          (trip) => trip.name.toLowerCase().contains(searchValue.toLowerCase()))
      .toList()
      .forEach((trip) {
    if (_tripNames.firstWhere(
            (e) =>
                e['name'].toLowerCase() == trip.name.toLowerCase() &&
                e['id'] == trip.placeId,
            orElse: () => null) ==
        null) _tripNames.add({'name': trip.name, 'id': trip.placeId});
  });
  _tripNames = _tripNames.toSet().toList();
  return _tripNames;
}

getPlaces(List<Trip> _trips, String searchValue) {
  List<Map<String, String>> _places = [];
  _trips.forEach((trip) => trip.places
          .where((place) =>
              place.name.toLowerCase().contains(searchValue.toLowerCase()))
          .toList()
          .forEach((place) {
        if (_places.firstWhere(
                (e) =>
                    e['name'].toLowerCase() == place.name.toLowerCase() ||
                    e['id'] == place.placeId,
                orElse: () => null) ==
            null) _places.add({'name': place.name, 'id': place.placeId});
      }));
  _places = _places.toSet().toList();
  return _places;
}
