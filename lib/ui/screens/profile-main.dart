import 'package:cached_network_image/cached_network_image.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripit/providers/language.provider.dart';
import 'package:tripit/providers/user.provider.dart';

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
  LanguageProvider _languages;
  List<Trip> _trips;
  Set<String> _languageFlags;
  Set<String> _languageNames;
  Set<String> _countries;
  List<int> _cities = [];
  List<String> _places;
  double _rating;
  double _ratingAcum;
  TextOverflow _overflow = TextOverflow.ellipsis;
  int _maxLines = 5;
  void _toggleShowDescription() {
    setState(() {
      _maxLines = _maxLines == null ? 5 : null;
      _overflow = _overflow == null ? TextOverflow.ellipsis : null;
    });
  }

  @override
  void initState() {
    super.initState();
    // _tripsData = Provider.of<TripProvider>(context, listen: false);
    _languages = Provider.of<LanguageProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    Future<void> initializeData(
        UserProvider userProvider, TripProvider tripsProvider) async {
      _ownerId = userProvider.user.id;
      _trips = tripsProvider.findByGuide(userProvider.user.id);
      _languageFlags = _trips.map((e) => e.languageFlagId).toSet();
      _languageNames = _trips.map((e) => e.languageNameId).toSet();
      _countries = _trips.map((e) => e.countryId).toSet();
      //TODO: obtener ciudad del trip, agregando att en trip? o cityId? como lo hago traducible?
      _places = _trips
          .map((e) => e.places.map((e) => e.googlePlaceId).toList())
          .toList()
          .expand((element) => element)
          .toList();

      _rating = 0;
      _ratingAcum = 0;
      _trips.forEach((trip) {
        tripsProvider.getAndSetTripRatings(trip.id).then((rat) {
          _ratingAcum += rat;
        }).then((_) {
          _rating = _ratingAcum /
              _trips
                  .map((trip) =>
                      trip.places.map((place) => place.rating != null))
                  .toList()
                  .length;
        });
      });
    }

    List<Widget> buildAvatar(String firstName, String lastName) {
      return [
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
      ];
    }

    List<Widget> buildStats() {
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
                    '${_trips.length}',
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
                    '${_countries.length}',
                    style: _statNumber,
                  ),
                  Text(
                    'countries',
                    style: _subtitleStyle,
                  )
                ],
              ),
              Column(
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
              ),
              Column(
                children: [
                  Text(
                    '${_cities.length}',
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
                    '${_places.length}',
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
          child: Center(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: _languageFlags.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: <Widget>[
                    Flag(
                      _languageFlags.toList()[i],
                      width: 75,
                      height: 45,
                      fit: BoxFit.cover,
                    ),
                    Text(_languages.getNativeName(_languageNames.toList()[i]))
                  ],
                ),
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
        ProfileTripsList(_trips)
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
        onPressed: () {},
        backgroundColor: Colors.red[800],
        child: Consumer2<UserProvider, TripProvider>(
          builder: (_, user, trips, __) => IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(TripNew.routeName,
                    arguments: {'ownerId': _ownerId}).then((_newTrip) {
                  if (_newTrip != null) {
                    trips.addTrip(_newTrip);
                  }
                });
              }),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Center(
            child: Consumer2<UserProvider, TripProvider>(
              builder: (_, userProvider, tripsProvider, __) {
                return FutureBuilder(
                  future: initializeData(userProvider, tripsProvider),
                  builder: (context, snapshot) {
                    return Column(
                      children: [
                        //avatar & name
                        ...buildAvatar(userProvider.user.firstName,
                            userProvider.user.lastName),
                        //stats
                        ...buildStats(),
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

class ProfileTripsList extends StatelessWidget {
  final List<Trip> _trips;

  ProfileTripsList(this._trips);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
          itemCount: _trips.length,
          itemBuilder: (ctx, i) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: Container(
                  height: 200,
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(
                        context, TripMain.routeName,
                        arguments: {
                          'trip': _trips[i],
                        }),
                    child: GridTile(
                      footer: GridTileBar(
                        title: Text(
                          _trips[i].name,
                          softWrap: true,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: '${_trips[i].pictureUrl}',
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Expanded(
                          child: Container(
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
    );
  }
}
