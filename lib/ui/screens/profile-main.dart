import 'package:cached_network_image/cached_network_image.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripit/providers/language.provider.dart';
import 'package:tripit/providers/user.provider.dart';
import 'package:tripit/ui/utils/show-message.dart';

import '../../ui/screens/trip-main.dart';
import '../../core/models/trip.model.dart';
import '../../providers/trip.provider.dart';
import '../../ui/screens/trip-new.dart';

class Profile extends StatefulWidget {
  static const routeName = '/profile';

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _ownerId;
  List<Trip> _trips;
  Set<String> _userLanguages;
  Set<String> _countries;
  Set<String> _cities;
  int _places = 0;
  double _rating = 0;
  double _ratingAcum = 0;
  TextOverflow _overflow = TextOverflow.ellipsis;
  int _maxLines = 5;
  void _toggleShowDescription() {
    setState(() {
      _maxLines = _maxLines == null ? 5 : null;
      _overflow = _overflow == null ? TextOverflow.ellipsis : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('build profile');
    Future<void> initializeData(
        UserProvider userProvider, TripProvider tripsProvider) async {
      _ownerId = userProvider.user.id;
      _trips = tripsProvider.findByGuide(userProvider.user.id);
      _userLanguages = _userLanguages ??
          _trips
              .where((t) => t.languageFlagId != null)
              .map((e) => '${e.languageFlagId},${e.languageNameId}')
              .toSet();

      _countries = _countries ?? _trips.map((e) => e.countryId).toSet();

      _cities = _cities ?? _trips.map((trip) => trip.googlePlaceId).toSet();

      if (_places == 0)
        _trips.forEach((trip) {
          _places += trip.places?.length;
        });
    }

    Future<void> calculateRating(TripProvider tripsProvider) async {
      if (_rating == 0) {
        for (Trip trip in _trips) {
          await tripsProvider.getAndSetTripRatings(trip.id).then((rat) {
            _ratingAcum += rat;
          }).then((_) {
            _rating = _ratingAcum /
                _trips
                    .where((trip) => trip.places
                        .where((place) => place.rating == null
                            ? false
                            : place.rating.rating > 0)
                        .isNotEmpty)
                    .length;
          });
        }
        return _rating;
      }
    }

    Widget buildAvatar(String firstName, String lastName) {
      return Column(
        children: <Widget>[
          CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage('assets/images/avatar.png'),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            '${toBeginningOfSentenceCase(firstName)} ${toBeginningOfSentenceCase(lastName)}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          Divider(
            height: 30,
          ),
        ],
      );
    }

    List<Widget> buildStats(TripProvider tripsProvider) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    '${_trips?.length}',
                    style: _statNumber,
                  ),
                  Text(
                    'trips',
                    style: _subtitleStyle,
                  )
                ],
              ),
              Column(
                children: [
                  Text(
                    '${_countries?.length}',
                    style: _statNumber,
                  ),
                  Text(
                    'countries',
                    style: _subtitleStyle,
                  )
                ],
              ),
              FutureBuilder(
                  future: calculateRating(tripsProvider),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.grey[300]),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${_rating.toStringAsPrecision(2)}',
                              style: TextStyle(
                                  color: Colors.amber[500],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30),
                            ),
                            Icon(
                              Icons.star,
                              color: Colors.amber[500],
                              size: 15,
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
              Column(
                children: [
                  Text(
                    '${_cities?.length}',
                    style: _statNumber,
                  ),
                  Text(
                    'cities',
                    style: _subtitleStyle,
                  )
                ],
              ),
              Column(
                children: [
                  Text(
                    '$_places',
                    style: _statNumber,
                  ),
                  Text(
                    'places',
                    style: _subtitleStyle,
                  )
                ],
              ),
            ],
          ),
        ),
        Divider(
          height: 30,
        ),
      ];
    }

    List<Widget> buildDescription(String about) {
      return [
        Text(
          'about the creator',
          style: _titleStyle,
        ),
        InkWell(
          onTap: () => _toggleShowDescription(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(
              about,
              maxLines: _maxLines,
              textAlign: TextAlign.justify,
              overflow: _overflow,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        Divider(
          height: 30,
        ),
      ];
    }

    List<Widget> buildLanguages() {
      return [
        Text(
          'languages',
          style: _titleStyle,
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          height: 70,
          width: MediaQuery.of(context).size.width - 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: _userLanguages.length,
            itemBuilder: (ctx, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  Flag(
                    _userLanguages.elementAt(i).split(',')[0],
                    width: 75,
                    height: 45,
                    fit: BoxFit.cover,
                  ),
                  Text(Provider.of<LanguageProvider>(context, listen: false)
                      .getNativeName(_userLanguages.elementAt(i).split(',')[1]))
                ],
              ),
            ),
          ),
        ),
        Divider(
          height: 30,
        ),
      ];
    }

    List<Widget> buildTrips() {
      return [
        Text(
          'trips',
          style: _titleStyle,
        ),
        SizedBox(
          height: 10,
        ),
        // ProfileTripsList(_trips)
        Container(
          width: MediaQuery.of(context).size.width,
          child: Consumer<TripProvider>(
            builder: (context, tripsProvider, _) => ListView.builder(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: _trips.length,
                itemBuilder: (ctx, i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                      child: Container(
                        height: 150,
                        child: InkWell(
                          onTap: () => _trips[i].submitted == true
                              ? Navigator.pushNamed(
                                  context,
                                  TripMain.routeName,
                                  arguments: {
                                    'trip': _trips[i],
                                  },
                                )
                              : Navigator.pushNamed<Map<String, dynamic>>(
                                  context,
                                  TripNew.routeName,
                                  arguments: {'trip': _trips[i]},
                                ).then((res) {
                                  if (res != null) {
                                    if (res['action'] == 'delete')
                                      tripsProvider.delete(res['item'].id);
                                    else
                                      tripsProvider
                                          .update(res['item'])
                                          .catchError((e) =>
                                              showMessage(context, e, true));
                                  }
                                }).catchError(
                                  (e) => showMessage(context, e, true)),
                          child: GridTile(
                            header: _trips[i].submitted == true
                                ? null
                                : Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.black38,
                                        ),
                                        onPressed: null),
                                  ),
                            footer: GridTileBar(
                              backgroundColor: Colors.black38,
                              title: Text(
                                _trips[i].name,
                                softWrap: true,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            child: Opacity(
                              opacity: _trips[i].published == true
                                  ? 1
                                  : _trips[i].submitted == true ? 0.7 : 0.4,
                              child: CachedNetworkImage(
                                imageUrl: '${_trips[i].imageUrl}',
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  height: 150,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
        )
      ];
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red[900],
        title: Text(
          'profile',
          style:
              const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        backgroundColor: Colors.red[800],
        child: Consumer2<UserProvider, TripProvider>(
            builder: (_, user, tripsProvider, __) {
          return IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed<Map<String, dynamic>>(
                TripNew.routeName,
                arguments: {'ownerId': _ownerId},
              ).then((res) {
                if (res != null) {
                  if (res['action'] == 'delete')
                    tripsProvider
                        .delete(res['item'].id)
                        .catchError((e) => showMessage(context, e, true));
                  else
                    tripsProvider
                        .create(res['item'])
                        .catchError((e) => showMessage(context, e, true));
                }
              }).catchError((e) => showMessage(context, e, true));
            },
          );
        }),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Consumer2<UserProvider, TripProvider>(
            builder: (_, userProvider, tripsProvider, __) {
              return FutureBuilder(
                future: initializeData(userProvider, tripsProvider),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //avatar & name
                      buildAvatar(userProvider.user.firstName,
                          userProvider.user.lastName),
                      //stats
                      ...buildStats(tripsProvider),
                      //about
                      if (userProvider.user.about != null)
                        ...buildDescription(userProvider.user.about),
                      //languages
                      ...buildLanguages(),
                      //trips
                      ...buildTrips(),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  TextStyle _statNumber = TextStyle(
      color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20);

  TextStyle _titleStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  TextStyle _subtitleStyle = TextStyle(
    fontSize: 12,
    color: Colors.black38,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.1,
  );
}
