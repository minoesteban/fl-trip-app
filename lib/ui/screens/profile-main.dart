import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripper/core/utils/s3-auth-headers.dart';
import '../../ui/widgets/collapsible-text.dart';
import '../../core/models/user.model.dart';
import '../../core/models/trip.model.dart';
import '../../providers/language.provider.dart';
import '../../providers/user.provider.dart';
import '../../providers/trip.provider.dart';
import '../../ui/utils/files-permission.dart';
import '../../ui/utils/show-message.dart';
import '../../ui/screens/trip-main.dart';
import '../../ui/screens/trip-new.dart';

class Profile extends StatelessWidget {
  static const routeName = '/profile';
  final int userId;

  Profile(this.userId);

  @override
  Widget build(BuildContext context) {
    User currentUser;
    List<Trip> _trips;
    Set<String> _userLanguages;
    Set<String> _countries;
    Set<String> _cities;
    int _places = 0;
    double _rating = 0;
    double _ratingAcum = 0;
    TripProvider tripsProvider =
        Provider.of<TripProvider>(context, listen: false);
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    bool myProfile = userProvider.user.id == userId ? true : false;

    Future<void> setUser() async {
      if (userProvider.user.id == userId)
        currentUser = userProvider.user;
      else
        currentUser = await userProvider.getUser(userId, false);
    }

    Future<void> getUserRating(TripProvider tripsProvider) async {
      if (_rating == 0) {
        for (Trip trip in _trips) {
          await tripsProvider.getAndSetTripRatings(trip.id).then((rat) {
            _ratingAcum += rat;
          }).then((_) {
            _rating = _ratingAcum /
                _trips
                    .where((trip) => trip.places
                        .where((place) => place.ratingAvg == null
                            ? false
                            : place.ratingAvg > 0)
                        .isNotEmpty)
                    .length;
          });
        }
      }
    }

    Widget buildAvatar() {
      return Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8, right: 8),
                child: CircleAvatar(
                  radius: 75,
                  backgroundImage: currentUser.imageUrl != null
                      ? !currentUser.imageUrl.startsWith('http')
                          ? AssetImage(currentUser.imageUrl)
                          : CachedNetworkImageProvider(currentUser.imageUrl,
                              headers: generateAuthHeaders(
                                  currentUser.imageUrl, context))
                      : AssetImage('assets/images/avatar.png'),
                ),
              ),
              if (myProfile)
                IconButton(
                  padding: const EdgeInsets.all(0),
                  icon: Icon(Icons.camera_alt),
                  color: Colors.grey[400],
                  iconSize: 35,
                  onPressed: () async {
                    if (await onAddFileClicked(context, FileType.image)) {
                      File image =
                          await FilePicker.getFile(type: FileType.image);
                      if (image != null) {
                        userProvider.updateImage(image);
                      }
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 18),
              Text(
                '${currentUser.firstName} ${currentUser.lastName}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              InkWell(
                child: Icon(
                  Icons.edit,
                  size: 24,
                  color: Colors.grey[400],
                ),
                onTap: () =>
                    showDialog(context: context, child: Text('edit about')),
              )
            ],
          ),
          const Divider(height: 30),
        ],
      );
    }

    List<Widget> buildStats() {
      return [
        Consumer<TripProvider>(builder: (context, tripProvider, _) {
          _trips = tripsProvider.findByOwner(currentUser.id);
          _countries = _countries ?? _trips.map((e) => e.countryId).toSet();
          _cities = _cities ?? _trips.map((trip) => trip.googlePlaceId).toSet();
          _trips.forEach((trip) {
            _places += trip.places?.length;
          });

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text('${_trips?.length}', style: _statNumber),
                    Text('trips', style: _subtitleStyle)
                  ],
                ),
                Column(
                  children: [
                    Text('${_countries?.length}', style: _statNumber),
                    Text('countries', style: _subtitleStyle)
                  ],
                ),
                FutureBuilder(
                    future: getUserRating(tripsProvider),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation(Colors.grey[300]),
                          ),
                        );
                      }
                      return Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_rating.toStringAsPrecision(2) ?? '-'}',
                                style: TextStyle(
                                    color: Colors.amber[500],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30),
                              ),
                              Icon(Icons.star,
                                  color: Colors.amber[500], size: 15),
                            ],
                          ),
                        ],
                      );
                    }),
                Column(
                  children: [
                    Text('${_cities?.length}', style: _statNumber),
                    Text('cities', style: _subtitleStyle)
                  ],
                ),
                Column(
                  children: [
                    Text('$_places', style: _statNumber),
                    Text('places', style: _subtitleStyle)
                  ],
                ),
              ],
            ),
          );
        }),
        const Divider(height: 30),
      ];
    }

    List<Widget> buildDescription(String about) {
      return [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('about the creator', style: _titleStyle),
            InkWell(
              child: Icon(
                Icons.edit,
                color: Colors.grey[400],
              ),
              onTap: () =>
                  showDialog(context: context, child: Text('edit about')),
            )
          ],
        ),
        CollapsibleText(about),
        const Divider(height: 30),
      ];
    }

    List<Widget> buildLanguages() {
      return [
        Text('languages', style: _titleStyle),
        const SizedBox(height: 10),
        Container(
            // height: 70,
            width: MediaQuery.of(context).size.width - 40,
            child: Consumer<TripProvider>(builder: (context, trips, _) {
              _userLanguages = _trips
                  .where((t) => t.languageFlagId != null)
                  .map((e) => '${e.languageFlagId},${e.languageNameId}')
                  .toSet();
              return GridView.count(
                  // primary: false,
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  physics: const ClampingScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 20,
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  childAspectRatio: 1.6,
                  children: _userLanguages
                      .map((language) => Column(children: <Widget>[
                            Flag(language.split(',')[0],
                                width: 75, height: 45, fit: BoxFit.cover),
                            Text(
                              Provider.of<LanguageProvider>(context,
                                      listen: false)
                                  .getNativeName(language.split(',')[1]),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                  letterSpacing: 1.1),
                            )
                          ]))
                      .toList());
            })),
        const Divider(height: 30),
      ];
    }

    List<Widget> buildTrips() {
      return [
        Text('trips', style: _titleStyle),
        const SizedBox(height: 10),
        Container(
          width: MediaQuery.of(context).size.width,
          child: Consumer<TripProvider>(builder: (context, tripsProvider, _) {
            List<Trip> _tripsRaw =
                tripsProvider.findByOwner(currentUser.id).toList();
            _trips.clear();
            _trips.addAll(_tripsRaw.where((t) => !t.submitted));
            _trips.addAll(_tripsRaw.where((t) => t.submitted && !t.published));
            _trips.addAll(_tripsRaw.where((t) => t.submitted && t.published));
            return ListView.builder(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              itemCount: _trips.length,
              itemBuilder: (ctx, i) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.all(const Radius.circular(10)),
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
                                arguments: {'trip': _trips[i].copyWith()},
                              ).then((res) {
                                if (res != null) {
                                  if (res['action'] == 'delete')
                                    tripsProvider.deleteLocal(res['item']);
                                  else
                                    tripsProvider
                                        .updateLocal(res['item'])
                                        .catchError((e) =>
                                            showMessage(context, e, true));
                                }
                              }).catchError(
                                (e) => showMessage(context, e, true)),
                        child: GridTile(
                          header: _trips[i].submitted == true
                              ? null
                              : const Align(
                                  alignment: Alignment.topRight,
                                  child: const IconButton(
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
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 1.1,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ),
                          child: Opacity(
                            opacity: _trips[i].published == true
                                ? 1
                                : _trips[i].submitted == true
                                    ? 0.7
                                    : 0.4,
                            child: !_trips[i].imageUrl.startsWith('http')
                                ? Image.file(
                                    File(_trips[i].imageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : CachedNetworkImage(
                                    httpHeaders: generateAuthHeaders(
                                        _trips[i].imageUrl, context),
                                    imageUrl: _trips[i].imageUrl,
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
              },
            );
          }),
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red[900],
        title: Text('profile',
            style: const TextStyle(
                fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      floatingActionButton: !myProfile
          ? null
          : FloatingActionButton(
              onPressed: null,
              backgroundColor: Colors.red[800],
              child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed<Map<String, dynamic>>(
                    TripNew.routeName,
                  )
                      .then((res) {
                    if (res != null) {
                      if (res['action'] == 'create/update')
                        Provider.of<TripProvider>(context, listen: false)
                            .createLocal(res['item'])
                            .catchError((e) => showMessage(context, e, true));
                    }
                  }).catchError((e) => showMessage(context, e, true));
                },
              ),
            ),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: FutureBuilder(
          future: setUser(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //avatar & name
                  buildAvatar(),
                  //stats
                  ...buildStats(),
                  //about
                  ...buildDescription(
                      Provider.of<UserProvider>(context).user.about ?? ''),
                  //languages
                  ...buildLanguages(),
                  //trips
                  ...buildTrips(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  final TextStyle _statNumber = TextStyle(
      color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 24);

  final TextStyle _titleStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  final TextStyle _subtitleStyle = TextStyle(
    fontSize: 12,
    color: Colors.black38,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.1,
  );
}
