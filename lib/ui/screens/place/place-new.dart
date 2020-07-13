import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tripit/core/geo/coordinates-model.dart';
import 'package:tripit/core/place/place-model.dart';
import 'package:tripit/core/utils.dart';
import 'package:tripit/ui/widgets/profile/profile-new-place-search.dart';

class PlaceNew extends StatefulWidget {
  static const routeName = '/profile/trip/new/place/new';

  final CameraPosition _initialPosition;
  final Position _userPosition;
  final String _countryCode;

  PlaceNew(this._userPosition, this._initialPosition, this._countryCode);

  @override
  _PlaceNewState createState() => _PlaceNewState();
}

class _PlaceNewState extends State<PlaceNew> {
  Completer<GoogleMapController> _controller = Completer();
  final _form = GlobalKey<FormState>();
  Place _newPlace = Place(getRandString(10));
  final _imageFocus = FocusNode();
  final _imageController = TextEditingController();
  final _locationFocus = FocusNode();
  final _locationController = TextEditingController();
  final _nameFocus = FocusNode();
  final _nameController = TextEditingController();
  final _priceFocus = FocusNode();
  final _priceController = TextEditingController();
  final _fullAudioFocus = FocusNode();
  final _fullAudioController = TextEditingController();
  final _previewAudioFocus = FocusNode();
  final _previewAudioController = TextEditingController();
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
    _locationFocus.dispose();
    _locationController.dispose();
    _nameFocus.dispose();
    _nameController.dispose();
    _priceFocus.dispose();
    _priceController.dispose();
    _fullAudioFocus.dispose();
    _fullAudioController.dispose();
    _previewAudioFocus.dispose();
    _previewAudioController.dispose();
    _aboutFocus.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  void _updateImage() {
    if (!_imageFocus.hasFocus) {
      setState(() {});
    }
  }

  void _saveForm(BuildContext ctx) {
    if (_form.currentState.validate()) {
      if (_imageController.text.isEmpty || _previewAudioController.text.isEmpty)
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
            Navigator.of(context).pop(_newPlace);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red[900],
        title: Text('add place',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        actions: [
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          Builder(
            builder: (ctx) => IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  _saveForm(ctx);
                }),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          onChanged: () {
            _newPlace.name = _nameController.text;
            _newPlace.description = _aboutController.text;
            _newPlace.imageUrl = _imageController.text;
            _newPlace.price = _priceController.text.isEmpty
                ? 0
                : double.parse(_priceController.text);
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
                          labelText: 'place picture',
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
                            FocusScope.of(context).requestFocus(_locationFocus),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //map & location
                      Container(
                        decoration: BoxDecoration(
                            border:
                                Border.all(width: 1, color: Colors.grey[400]),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        height: 200,
                        padding: const EdgeInsets.all(5),
                        child: GoogleMap(
                          liteModeEnabled: Platform.isAndroid ? true : null,
                          buildingsEnabled: false,
                          mapToolbarEnabled: false,
                          myLocationButtonEnabled: false,
                          myLocationEnabled: false,
                          mapType: MapType.normal,
                          initialCameraPosition: widget._initialPosition,
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                        ),
                      ),
                      TextFormField(
                        onTap: () async {
                          PlaceDetails result = await showSearch(
                              context: context,
                              delegate: PlaceNewSearch(widget._userPosition,
                                  widget._countryCode, Caller.PlaceNew));
                          if (result != null) {
                            _controller.future.then(
                              (value) => value.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                    LatLng(result.geometry.location.lat,
                                        result.geometry.location.lng),
                                    14.5),
                              ),
                            );

                            _newPlace.name = result.name;
                            _newPlace.placeId = result.placeId;
                            _newPlace.coordinates = Coordinates(
                                latitude: result.geometry.location.lat,
                                longitude: result.geometry.location.lng);

                            setState(() {
                              _locationController.text = '${result.name}';
                              _nameController.text = '${result.name}';
                              _newPlace = _newPlace;
                            });
                          }
                        },
                        readOnly: true,
                        validator: (value) =>
                            value.isEmpty ? 'select a location!' : null,
                        decoration: InputDecoration(
                          labelText: 'location',
                          helperText: 'select a place',
                          suffixIcon: const Icon(Icons.search),
                        ),
                        controller: _locationController,
                        focusNode: _locationFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_nameFocus),
                      ),
                      Divider(
                        height: 30,
                      ),
                      //name
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'name',
                          helperText: 'custom place name',
                        ),
                        validator: (value) =>
                            value.isEmpty ? 'write a valid name!' : null,
                        textInputAction: TextInputAction.next,
                        controller: _nameController,
                        focusNode: _nameFocus,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_priceFocus),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      //price
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'price',
                          helperText:
                              'individual place price. write 0 for free',
                        ),
                        validator: (value) => value.isEmpty
                            ? 'input a valid place price! insert 0 for free'
                            : null,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.next,
                        controller: _priceController,
                        focusNode: _priceFocus,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_fullAudioFocus),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      //full audio
                      TextFormField(
                        onTap: () {},
                        decoration: InputDecoration(
                          labelText: 'full audio',
                          suffixIcon: Icon(Icons.file_upload),
                        ),
                        // validator: (value) =>
                        //     value.isEmpty ? 'upload the place audio' : null,
                        readOnly: true,
                        textInputAction: TextInputAction.next,
                        controller: _fullAudioController,
                        focusNode: _fullAudioFocus,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_previewAudioFocus),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      //preview audio
                      TextFormField(
                        onTap: () {},
                        decoration: InputDecoration(
                          labelText: 'preview audio',
                          helperMaxLines: 2,
                          helperText:
                              'upload preview audio. if no audio is uploaded here, the first 15 seconds of the full audio will be used as preview',
                          suffixIcon: Icon(Icons.file_upload),
                        ),
                        readOnly: true,
                        textInputAction: TextInputAction.next,
                        controller: _previewAudioController,
                        focusNode: _previewAudioFocus,
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
                          labelText: 'about the place',
                        ),
                        validator: (value) => value.isEmpty
                            ? 'write something about the place!'
                            : null,
                        textInputAction: TextInputAction.newline,
                        controller: _aboutController,
                        focusNode: _aboutFocus,
                      ),
                      const SizedBox(
                        height: 30,
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
}
