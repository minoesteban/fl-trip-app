import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tripper/config.dart';

final places = GoogleMapsPlaces(apiKey: PLACES_API_KEY);

enum Caller { TripNew, PlaceNew }

class PlaceNewSearch extends SearchDelegate<PlaceDetails> {
  Position _userPosition;
  Caller _caller;
  String _countryCode;

  PlaceNewSearch(this._userPosition, this._countryCode, this._caller);

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
      List<Map<String, String>> _cities = [];
      List<Map<String, String>> _places = [];
      List<String> _searchTypes =
          _caller == Caller.PlaceNew ? ['establishment'] : ['(cities)'];

      return FutureBuilder<PlacesAutocompleteResponse>(
        future: places.autocomplete(query,
            components: _countryCode.isEmpty
                ? null
                : [Component('country', _countryCode)],
            language: Platform.localeName.split('_')[0],
            location: Location(_userPosition.latitude, _userPosition.longitude),
            types: _searchTypes),
        builder: (BuildContext context,
            AsyncSnapshot<PlacesAutocompleteResponse> res) {
          if (res.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red[800]),
              ),
            );
          } else {
            if (res.hasError)
              return Center(
                  child: Icon(
                Icons.sentiment_very_dissatisfied,
                size: 35,
                color: Colors.red[800],
              ));
            else {
              if (res.data.predictions.length > 0)
                addPredictionsToResults(res.data.predictions, _cities, _places);

              return SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                                      language:
                                          Platform.localeName.split('_')[0],
                                    );
                                    if (details.isOkay)
                                      close(context, details.result);
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
                                      language:
                                          Platform.localeName.split('_')[0],
                                    );
                                    if (details.isOkay)
                                      close(context, details.result);
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
                    ],
                  ),
                ),
              );
            }
          }
        },
      );
    } else {
      return Container();
    }
  }
}

addPredictionsToResults(List<Prediction> _preds,
    List<Map<String, String>> _cities, List<Map<String, String>> _places) {
  _preds.forEach((pred) {
    if ([
      'locality',
      'sublocality',
      'postal_code',
      'administrative_area_level_1',
      'administrative_area_level_2',
      'administrative_area_level_3'
    ].contains(pred.types[0])) {
      if (_cities.firstWhere(
              (e) =>
                  e['name'].toLowerCase() == pred.description.toLowerCase() ||
                  e['id'] == pred.placeId,
              orElse: () => null) ==
          null) _cities.add({'name': pred.description, 'id': pred.placeId});
    } else {
      if (_places.firstWhere(
              (e) =>
                  e['name'].toLowerCase() == pred.description.toLowerCase() ||
                  e['id'] == pred.placeId,
              orElse: () => null) ==
          null) _places.add({'name': pred.description, 'id': pred.placeId});
    }
  });
}
