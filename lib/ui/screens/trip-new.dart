import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import 'package:tripit/core/utils/utils.dart';
import '../../providers/trip.provider.dart';
import '../../providers/user.provider.dart';
import '../../core/models/place.model.dart';
import '../../core/models/trip.model.dart';
import '../../ui/screens/place-new.dart';
import '../../ui/widgets/place-new-search.dart';

class TripNew extends StatefulWidget {
  static const routeName = '/profile/trip/new';

  @override
  _TripNewState createState() => _TripNewState();
}

class _TripNewState extends State<TripNew> {
  Completer<GoogleMapController> _controller = Completer();
  Position _userPosition;
  Map _args;
  final _form = GlobalKey<FormState>();
  Trip _newTrip = Trip(id: 0, name: '', countryId: '');
  bool _selectedCountry = false;
  List<Place> _newPlaces = [];
  CameraPosition _initialPosition;
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
    _userPosition =
        Provider.of<UserProvider>(context, listen: false).user.position;
    _initialPosition = CameraPosition(
      target: LatLng(_userPosition.latitude, _userPosition.longitude),
      zoom: 13,
    );
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

  void _saveForm(BuildContext ctx, Trip newTrip) {
    if (_form.currentState.validate()) {
      _form.currentState.save();
      Navigator.of(context).pop({'action': 'create', 'item': newTrip});
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

  void _addNewPlace(Place p) {}

  @override
  Widget build(BuildContext context) {
    print('build trip new');

    void _showMessage(dynamic e, bool isDialog) {
      print(e.toString());
      if (isDialog)
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('error!'),
              content: Text('${e.toString()}'),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    'REPORT...',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
      else
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('error! $e'),
            action: SnackBarAction(
                label: 'OK',
                onPressed: () {
                  Scaffold.of(context).hideCurrentSnackBar();
                }),
          ),
        );
    }

    void _initialization() {
      if (_args == null) {
        _args = ModalRoute.of(context).settings.arguments;
        if (_args['trip'] != null) {
          _newTrip = _args['trip'];
          _newPlaces = _newTrip.places;
          _nameController.text = _newTrip.name ?? '';
          _aboutController.text = _newTrip.about ?? '';
          _imageController.text = _newTrip.pictureUrl ?? '';
          _priceController.text = _newTrip.price.toString() ?? '';

          places
              .getDetailsByPlaceId(
            _newTrip.googlePlaceId,
            language: Platform.localeName.split('_')[0],
          )
              .then((result) {
            _controller.future.then(
              (_gm) => _gm.animateCamera(
                CameraUpdate.newLatLngZoom(
                    LatLng(result.result.geometry.location.lat,
                        result.result.geometry.location.lng),
                    13.5),
              ),
            );

            result.result.addressComponents.forEach(
              (comp) => comp.types.forEach(
                (type) {
                  if (type == 'country') {
                    setState(
                      () {
                        _selectedCountry = true;
                        _locationController.text =
                            '${result.result.name}, ${comp.longName}';
                      },
                    );
                  }
                },
              ),
            );
          });
        } else {
          _newTrip.ownerId = _args['ownerId'];
        }
      }
    }

    _initialization();

    return WillPopScope(
      onWillPop: () {
        if (_newTrip.countryId.length > 0 && _newTrip.name.length > 0)
          return showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('Do you want to save your changes?'),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      'DISCARD',
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                  FlatButton(
                    child: Text(
                      'CANCEL',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  FlatButton(
                    child: Text(
                      'SAVE',
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(_newTrip);
                    },
                  ),
                ],
              );
            },
          ).then((v) {
            if (v == _newTrip) {
              Navigator.of(context).pop({'action': 'create', 'item': _newTrip});
            }
            return v;
          });
        else
          return Future.delayed(Duration.zero).then((value) => true);
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.red[900],
          title: Text(
            _newTrip.id > 0 ? 'edit trip' : 'new trip',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('are you sure?'),
                      content: Text(
                          'you are deleting the entire trip and its places'),
                      actions: [
                        FlatButton(
                          child: Text(
                            'NO',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        FlatButton(
                          child: Text('YES'),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                ).then(
                  (res) => res
                      ? Navigator.of(context).pop({
                          'action': 'delete',
                          'item': _newTrip,
                        })
                      : Navigator.of(context).pop(),
                );
              },
            ),
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  _saveForm(ctx, _newTrip);
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: null,
          backgroundColor:
              _selectedCountry ? Colors.red[800] : Colors.grey[600],
          child: Consumer<TripProvider>(
            builder: (_, tripProvider, __) => IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _selectedCountry
                    ? Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (_) => PlaceNew(
                                _userPosition,
                                _initialPosition,
                                _newTrip.countryId,
                                _newTrip.id)))
                        .then(
                        (newPlace) {
                          if (newPlace != null) {
                            if (newPlace.tripId > 0)
                              tripProvider.createPlace(newPlace).catchError(
                                    (e) => _showMessage(e, true),
                                  );
                            else
                              setState(() {
                                _newPlaces.add(newPlace);
                              });
                          }
                        },
                      )
                    : showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('no location selected'),
                          content: Text(
                              'places select a main location before adding places'),
                          actions: [
                            FlatButton(
                              child: Text(
                                'OK',
                              ),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                          ],
                        ),
                      ).then(
                        (value) =>
                            FocusScope.of(context).requestFocus(_locationFocus),
                      );
              },
            ),
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _form,
            onChanged: () {
              _newTrip.name = _nameController.text;
              _newTrip.about = _aboutController.text;
              _newTrip.pictureUrl = _imageController.text;
              _newTrip.price = _priceController.text.isEmpty
                  ? 0
                  : double.parse(_priceController.text);

              _newPlaces.sort((a, b) => a.order.compareTo(b.order));
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
                          onFieldSubmitted: (_) => FocusScope.of(context)
                              .requestFocus(_locationFocus),
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

                              _newTrip.googlePlaceId = result.placeId;

                              _initialPosition = CameraPosition(
                                target: LatLng(result.geometry.location.lat,
                                    result.geometry.location.lng),
                                zoom: 14.5,
                              );

                              var _countryName = '';
                              result.addressComponents
                                  .forEach((comp) => comp.types.forEach((type) {
                                        if (type == 'country') {
                                          _newTrip.countryId = comp.shortName;
                                          _countryName = comp.longName;
                                        }
                                      }));

                              setState(() {
                                _initialPosition = _initialPosition;
                                _selectedCountry = true;
                                _newTrip = _newTrip;
                                _locationController.text =
                                    '${result.name}, $_countryName';
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
                        Consumer<TripProvider>(
                          builder: (_, tripProvider, __) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Text(
                                    'places',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black54),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.grey[400]),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                padding: const EdgeInsets.all(5),
                                height: 300,
                                child: GoogleMap(
                                  liteModeEnabled:
                                      Platform.isAndroid ? true : null,
                                  buildingsEnabled: false,
                                  mapToolbarEnabled: false,
                                  myLocationButtonEnabled: false,
                                  myLocationEnabled: true,
                                  mapType: MapType.normal,
                                  initialCameraPosition: _initialPosition,
                                  onMapCreated:
                                      (GoogleMapController controller) {
                                    _controller.complete(controller);
                                  },
                                ),
                              ),
                              Container(
                                child: ListView.builder(
                                  physics: ClampingScrollPhysics(),
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
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                            child: CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              imageUrl:
                                                  '${_newPlaces[i].pictureUrl1}',
                                              placeholder: (_, _a) =>
                                                  const Icon(
                                                Icons.photo_camera,
                                                size: 30,
                                              ),
                                              errorWidget: (_, _a, _b) =>
                                                  const Icon(
                                                Icons.camera_alt,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          '${i + 1}. ${_newPlaces[i].name}',
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title:
                                                          Text('are you sure?'),
                                                      content: Text(
                                                          'you are deleting ${_newPlaces[i].name} from the places list'),
                                                      actions: [
                                                        FlatButton(
                                                          child: Text(
                                                            'NO',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey[600],
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false);
                                                          },
                                                        ),
                                                        FlatButton(
                                                          child: Text('YES'),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(true);
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ).then((res) async {
                                                  if (res) {
                                                    await tripProvider
                                                        .deletePlace(
                                                            _newPlaces[i])
                                                        .catchError((e) =>
                                                            _showMessage(
                                                                e, true));
                                                  }
                                                });
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
                            ],
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
