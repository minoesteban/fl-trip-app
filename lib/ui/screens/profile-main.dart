import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripit/core/models/trip-model.dart';
import 'package:tripit/providers/trips-provider.dart';
import 'package:tripit/ui/screens/trip-new.dart';
import '../widgets/profile-trips-list.dart';

class Profile extends StatefulWidget {
  static const routeName = '/profile';

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
    String _userId = 'giorgio';
    String _userDescription =
        'Lorem ipsum dolor sit amet consectetur adipiscing elit sollicitudin, aptent pharetra volutpat ridiculus eu hendrerit magna, nunc auctor curabitur nullam orci feugiat parturient. Massa aliquam tincidunt ac neque tempus congue et dis, facilisis tempor tellus erat felis nisl nisi curabitur ad, purus laoreet ante sodales gravida sociosqu potenti. Habitant lobortis facilisis cursus litora orci praesent volutpat non congue, iaculis inceptos venenatis senectus a leo mus. Sociosqu penatibus pharetra litora feugiat tempor iaculis proin convallis volutpat duis, mus rutrum nec ligula sapien sagittis tincidunt vivamus nascetur donec, malesuada sodales fermentum semper quis dictum erat lacinia velit. Volutpat conubia senectus habitasse varius at libero rhoncus curae velit, sodales tristique condimentum felis vestibulum in sed rutrum, pharetra massa accumsan etiam platea mollis potenti vitae. Est ornare libero primis dui elementum luctus aenean tempus aptent, mus metus accumsan ridiculus magnis eleifend aliquam vel nulla donec, cras congue faucibus integer ante nascetur laoreet bibendum. Quisque quam ante libero ac sagittis vel et dis bibendum, varius taciti porttitor tortor urna metus montes est habitant, mus pulvinar ultrices tellus sem neque aenean rhoncus. Erat torquent vulputate pharetra tortor hendrerit purus praesent sollicitudin ultrices, sagittis tincidunt justo libero habitasse rutrum venenatis tellus leo, augue arcu montes molestie netus iaculis viverra vehicula.';
    var _tripsProvider = Provider.of<Trips>(context, listen: false);
    var _trips = _tripsProvider.findByGuide(_userId);
    var _languages = _trips.map((e) => e.language).toSet();
    var _countries = _trips.map((e) => e.country).toSet();
    var _cities = _trips.map((e) => e.city).toSet();
    var _places = _trips
        .map((e) => e.places.map((e) => e.placeId).toList())
        .toList()
        .expand((element) => element)
        .toList();

    var _rating = _trips.map((e) => e.tripRating) == null
        ? 0.0
        : _trips.map((e) => e.tripRating).reduce((a, b) => a + b) /
            _trips.length;

    List<Widget> buildAvatar() {
      return [
        CircleAvatar(
          radius: 60,
          backgroundImage: AssetImage('assets/images/avatar.png'),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          _userId,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ];
    }

    Widget buildStats() {
      return Padding(
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
      );
    }

    List<Widget> buildDescription() {
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
              _userDescription,
              maxLines: _maxLines,
              textAlign: TextAlign.justify,
              overflow: _overflow,
              style: TextStyle(fontSize: 14),
            ),
          ),
        )
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
          height: 50,
          width: MediaQuery.of(context).size.width - 40,
          child: Center(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: _languages.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Flag(
                  _languages.toList()[i],
                  width: 75,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        )
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

    void _addNewTrip(Trip _t) {
      _tripsProvider.addTrip(_t);
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red[900],
        title: Text(
          _userId,
          style:
              const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(TripNew.routeName, arguments: {
                  'userId': _userId
                }).then((_newTrip) => _addNewTrip(_newTrip));
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Center(
            child: Column(
              children: [
                //avatar & name
                ...buildAvatar(),
                Divider(
                  height: 30,
                ),
                //stats
                buildStats(),
                Divider(
                  height: 30,
                ),
                //about
                ...buildDescription(),
                Divider(
                  height: 30,
                ),
                //languages
                ...buildLanguages(),
                Divider(
                  height: 30,
                ),
                //trips
                ...buildTrips(),
              ],
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
