import 'dart:async';

import 'dart:io';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import 'package:tripit/core/geo/region-model.dart';
import 'package:tripit/core/geo/user-position-provider.dart';
import 'package:tripit/core/place/place-model.dart';
import 'package:tripit/core/trip/trip-model.dart';
import 'package:tripit/core/utils.dart';
import 'package:tripit/ui/screens/place/place-new.dart';
import 'package:tripit/ui/widgets/profile/profile-new-place-search.dart';

class TripNew extends StatefulWidget {
  static const routeName = '/profile/trip/new';

  @override
  _TripNewState createState() => _TripNewState();
}

class _TripNewState extends State<TripNew> {
  Completer<GoogleMapController> _controller = Completer();
  final _form = GlobalKey<FormState>();
  String _countryCode = '';
  Trip _newTrip = Trip(id: getRandString(10));
  List<Place> _newPlaces = [];
  CameraPosition _initialPosition = CameraPosition(target: LatLng(0, 0));
  final _imageFocus = FocusNode();
  final _imageController = TextEditingController();
  final _nameFocus = FocusNode();
  final _nameController = TextEditingController();
  final _locationFocus = FocusNode();
  final _locationController = TextEditingController();
  final _priceFocus = FocusNode();
  final _priceController = TextEditingController();
  final _audioFocus = FocusNode();
  final _audioController = TextEditingController();
  final _aboutFocus = FocusNode();
  final _aboutController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _imageFocus.addListener(_updateImage);
  }

  @override
  void dispose() {
    _imageFocus.removeListener(_updateImage);
    _imageFocus.dispose();
    _imageController.dispose();
    _nameFocus.dispose();
    _nameController.dispose();
    _locationFocus.dispose();
    _locationController.dispose();
    _priceFocus.dispose();
    _priceController.dispose();
    _audioFocus.dispose();
    _audioController.dispose();
    _aboutFocus.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  void _updateImage() {
    if (!_imageFocus.hasFocus) {
      setState(() {});
    }
  }

  void _saveForm(BuildContext ctx, Trip _newTrip) {
    if (_form.currentState.validate()) {
      if (_imageController.text.isEmpty || _audioController.text.isEmpty)
        showDialog(
          context: ctx,
          builder: (context) => AlertDialog(
            title: Text('the more, the better!'),
            content: Text(
                'it seems you have not uploaded a preview audio or a cover image. are you sure you want to proceed without them?'),
            actions: [
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('NO')),
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('YES')),
            ],
          ),
        ).then((res) {
          if (res) {
            _form.currentState.save();
            print(_newTrip.id);
            print(_newTrip.name);
            print(_newTrip.city);
            print(_newTrip.country);
            print(_newTrip.price);
            print(_newTrip.description);
            print(_newTrip.guideId);
            print(_newTrip.placeId);
            print(_newTrip.imageUrl);
            print(
                ('${_newTrip.region.latitude}, ${_newTrip.region.longitude}'));
            print(_newTrip.places.length);
            Navigator.of(context).pop(_newTrip);
          }
        });
    } else {
      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text('errors found! check each field for details'),
          action: SnackBarAction(
              label: 'OK',
              onPressed: () {
                Scaffold.of(ctx).hideCurrentSnackBar();
              }),
        ),
      );
    }
  }

  void _addNewPlace(Place _p) {
    if (_p != null) {
      _newPlaces.add(_p);
      setState(() {
        _newPlaces = _newPlaces;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Map _args = ModalRoute.of(context).settings.arguments;
    var _guideId = _args['userId'];
    var _userPosition =
        Provider.of<UserPosition>(context, listen: false).getPosition;
    _initialPosition = _initialPosition.target.latitude == 0
        ? CameraPosition(
            target: LatLng(_userPosition.latitude, _userPosition.longitude),
            zoom: 13,
          )
        : _initialPosition;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red[900],
        title: Text('new trip',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        actions: [
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                _saveForm(context, _newTrip);
              }),
        ],
      ),
      floatingActionButton: _countryCode.isEmpty
          ? FloatingActionButton(
              backgroundColor: Colors.grey[600],
              child: const Icon(Icons.add),
              onPressed: () {
                FocusScope.of(context).requestFocus(_locationFocus);
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('select location'),
                    content: Text(
                        'select the trip\'s main location before adding places!'),
                    actions: [
                      FlatButton(
                        child: Text(
                          'OK',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => Navigator.of(ctx).pop('location'),
                      ),
                    ],
                  ),
                );
              })
          : OpenContainer<Place>(
              transitionType: ContainerTransitionType.fadeThrough,
              transitionDuration: Duration(milliseconds: 500),
              closedColor: Colors.red[800],
              closedShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(56 / 2),
                ),
              ),
              closedBuilder: (context, _) => SizedBox(
                  height: 56,
                  width: 56,
                  child: Center(
                      child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ))),
              openBuilder: (context, _) =>
                  PlaceNew(_userPosition, _initialPosition, _countryCode),
              onClosed: (_newPlace) {
                _addNewPlace(_newPlace);
              }),
      body: SafeArea(
        child: Form(
          key: _form,
          onChanged: () {
            _newTrip.name = _nameController.text;
            _newTrip.description = _aboutController.text;
            _newTrip.imageUrl = _imageController.text;
            _newTrip.price = _priceController.text.isEmpty
                ? 0
                : double.parse(_priceController.text);
            _newTrip.guideId = _guideId;
            _newTrip.places = _newPlaces;
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                //cover image
                Stack(alignment: Alignment.bottomCenter, children: [
                  Container(
                    color: Colors.grey[300],
                    height: MediaQuery.of(context).size.height / 3.5,
                    width: MediaQuery.of(context).size.width,
                    child: CachedNetworkImage(
                      imageUrl: _imageController.text,
                      fit: BoxFit.cover,
                      placeholder: (_, _a) => Icon(
                        Icons.photo_camera,
                        color: Colors.grey[600],
                        size: 75,
                      ),
                      errorWidget: (_, _a, _b) => Icon(
                        Icons.photo_camera,
                        color: Colors.grey[600],
                        size: 75,
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.black38,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: TextFormField(
                        style: TextStyle(color: Colors.white70),
                        decoration: InputDecoration(
                          labelText: 'cover image',
                          labelStyle: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold),
                          suffixIcon: IconButton(
                            onPressed: () {},
                            color: Colors.white70,
                            icon: const Icon(Icons.file_upload),
                          ),
                        ),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.next,
                        focusNode: _imageFocus,
                        controller: _imageController,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_nameFocus),
                      ),
                    ),
                  )
                ]),
                const SizedBox(
                  height: 20,
                ),
                //rest of the form
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //trip name
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'trip name',
                        ),
                        textInputAction: TextInputAction.next,
                        controller: _nameController,
                        focusNode: _nameFocus,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_locationFocus),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      //location
                      TextFormField(
                        onTap: () async {
                          PlaceDetails result = await showSearch(
                              context: context,
                              delegate: PlaceNewSearch(
                                  _userPosition, '', Caller.TripNew));
                          if (result != null) {
                            _controller.future.then(
                              (value) => value.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                    LatLng(result.geometry.location.lat,
                                        result.geometry.location.lng),
                                    14.5),
                              ),
                            );
                            _newTrip.city = result.name;
                            _newTrip.placeId = result.placeId;

                            _newTrip.region = Region(
                                latitude: result.geometry.location.lat,
                                longitude: result.geometry.location.lng,
                                latitudeDelta: 1,
                                longitudeDelta: 1);

                            _initialPosition = CameraPosition(
                              target: LatLng(result.geometry.location.lat,
                                  result.geometry.location.lng),
                              zoom: 14.5,
                            );

                            result.addressComponents
                                .forEach((comp) => comp.types.forEach((type) {
                                      if (type == 'country') {
                                        _newTrip.country = comp.longName;
                                        _countryCode = comp.shortName;
                                      }
                                    }));

                            setState(() {
                              _initialPosition = _initialPosition;
                              _countryCode = _countryCode;
                              _newTrip = _newTrip;
                              _locationController.text =
                                  '${_newTrip.city}, ${_newTrip.country}';
                            });
                          }
                        },
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'location',
                          helperText: 'trip\'s main city / location',
                          suffixIcon: const Icon(Icons.search),
                        ),
                        controller: _locationController,
                        focusNode: _locationFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_aboutFocus),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      //price
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'price',
                          helperText: 'write 0 for free',
                        ),
                        validator: (value) => value.isEmpty
                            ? 'input a valid price! insert 0 for free'
                            : null,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.next,
                        controller: _priceController,
                        focusNode: _priceFocus,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_aboutFocus),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      //about
                      TextFormField(
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          labelText: 'about the trip',
                        ),
                        textInputAction: TextInputAction.newline,
                        controller: _aboutController,
                        focusNode: _aboutFocus,
                        onFieldSubmitted: (value) =>
                            FocusScope.of(context).requestFocus(_audioFocus),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      //preview audio
                      TextFormField(
                        onTap: () {},
                        decoration: InputDecoration(
                          labelText: 'preview audio',
                          helperText: 'upload preview audio',
                          suffixIcon: Icon(Icons.file_upload),
                        ),
                        readOnly: true,
                        textInputAction: TextInputAction.next,
                        controller: _audioController,
                        focusNode: _audioFocus,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      //map & places
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            'places',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border:
                                Border.all(width: 1, color: Colors.grey[400]),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        padding: const EdgeInsets.all(5),
                        height: 300,
                        child: GoogleMap(
                          liteModeEnabled: Platform.isAndroid ? true : null,
                          buildingsEnabled: false,
                          mapToolbarEnabled: false,
                          myLocationButtonEnabled: false,
                          myLocationEnabled: true,
                          mapType: MapType.normal,
                          initialCameraPosition: _initialPosition,
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                        ),
                      ),
                      Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _newPlaces.length,
                          itemBuilder: (ctx, i) {
                            return Card(
                              elevation: 1,
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: '${_newPlaces[i].imageUrl}',
                                      placeholder: (_, _a) => const Icon(
                                        Icons.photo_camera,
                                        size: 30,
                                      ),
                                      errorWidget: (_, _a, _b) => const Icon(
                                        Icons.camera_alt,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  '${_newPlaces[i].name}',
                                  style: _titleStyle,
                                ),
                                subtitle: Text(
                                  _newPlaces[i].price > 0
                                      ? '\$ ${_newPlaces[i].price}'
                                      : 'free',
                                  style: _subtitleStyle,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('are you sure?'),
                                              content: Text(
                                                  'you are deleting ${_newPlaces[i].name} from the places list'),
                                              actions: [
                                                FlatButton(
                                                  child: Text('NO'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                FlatButton(
                                                  child: Text('YES'),
                                                  onPressed: () {
                                                    _newPlaces.removeAt(i);
                                                    setState(() {
                                                      _newPlaces = _newPlaces;
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _titleStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  TextStyle _subtitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.black38,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.1,
  );
}
