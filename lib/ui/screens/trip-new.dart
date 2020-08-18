import 'dart:io';
import 'dart:async';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../ui/utils/trip-submit.dart';
import '../../core/utils/utils.dart';
import '../../ui/screens/place-new.dart';
import '../../ui/utils/show-message.dart';
import '../../core/models/trip.model.dart';
import '../../providers/trip.provider.dart';
import '../../providers/user.provider.dart';
import '../../core/models/place.model.dart';
import '../../ui/widgets/store-trip-map.dart';
import '../../ui/utils/files-permission.dart';
import '../../providers/country.provider.dart';
import '../../ui/widgets/place-new-search.dart';
import '../../providers/language.provider.dart';

enum ListItemType { Error, Warning, Info }

class TripNew extends StatefulWidget {
  static const routeName = '/profile/trip/new';
  final Trip trip;

  TripNew(this.trip);

  @override
  _TripNewState createState() => _TripNewState();
}

class _TripNewState extends State<TripNew> {
  Completer<GoogleMapController> _controller = Completer();
  Trip _newTrip;
  String _localeName;
  Position _userPosition;
  CountryProvider _countries;
  LanguageProvider _languages;
  List<Place> _newPlaces = [];
  CameraPosition _initialPosition;
  final _form = GlobalKey<FormState>();
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
  final _languageCodeFocus = FocusNode();
  final _languageCodeController = TextEditingController();
  final _languageFlagFocus = FocusNode();
  final _languageFlagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _imageFocus.addListener(_updateImage);
    _localeName = Platform.localeName;
    print(_localeName);
    _newTrip = widget.trip;
    _newPlaces = _newTrip.places ?? [];
    _nameController.text = _newTrip.name ?? '';
    _aboutController.text = _newTrip.about ?? '';
    _imageController.text = _newTrip.imageUrl ?? '';
    _priceController.text = _newTrip.price.toString() ?? '';
    _audioController.text = _newTrip.previewAudioUrl ?? '';
    _locationController.text = _newTrip.locationName ?? '';
    _languageCodeController.text = _newTrip.languageNameId != null
        ? _newTrip.languageNameId.isNotEmpty
            ? _newTrip.languageNameId
            : _localeName.split('_')[0].toUpperCase()
        : _localeName.split('_')[0].toUpperCase();
    _languageFlagController.text = _newTrip.languageFlagId != null
        ? _newTrip.languageFlagId.isNotEmpty
            ? _newTrip.languageFlagId
            : _localeName.split('_')[0].toUpperCase()
        : _localeName.split('_')[0].toUpperCase();
    if (_newTrip.imageUrl != null && _newTrip.imageUrl.length > 0)
      _newTrip.imageOrigin = _newTrip.imageUrl.startsWith('http')
          ? FileOrigin.Network
          : FileOrigin.Local;
    if (_newTrip.previewAudioUrl != null && _newTrip.previewAudioUrl.length > 0)
      _newTrip.audioOrigin = _newTrip.previewAudioUrl.startsWith('http')
          ? FileOrigin.Network
          : FileOrigin.Local;

    _languages = Provider.of<LanguageProvider>(context, listen: false);
    _countries = Provider.of<CountryProvider>(context, listen: false);
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
    _languageCodeController.dispose();
    _languageCodeFocus.dispose();
    _languageFlagController.dispose();
    _languageFlagFocus.dispose();
    super.dispose();
  }

  void _saveForm(BuildContext ctx, Trip newTrip) {
    if (_form.currentState.validate()) {
      _form.currentState.save();
      Navigator.of(context).pop({'action': 'create/update', 'item': newTrip});
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

  void _updateImage() {
    if (!_imageFocus.hasFocus) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build trip new');

    //get location name
    if (_locationController.text == '' && _newTrip.id > 0) {
      print('obtengo location de places');
      places
          .getDetailsByPlaceId(
            _newTrip.googlePlaceId,
            language: _localeName.split('_')[0],
          )
          .then((result) => result.result.addressComponents.forEach(
                (comp) => comp.types.forEach(
                  (type) {
                    if (type == 'country')
                      setState(() => _locationController.text =
                          '${result.result.name}, ${comp.longName}');
                  },
                ),
              ));
    }

    List<Widget> buildCoverImage() {
      return [
        Consumer<TripProvider>(builder: (_, tripProvider, __) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                color: Colors.grey[300],
                height: MediaQuery.of(context).size.height / 3.5,
                width: MediaQuery.of(context).size.width,
                child: _newTrip.imageOrigin == FileOrigin.Local
                    ? Image.asset(
                        _imageController.text,
                        fit: BoxFit.cover,
                      )
                    : CachedNetworkImage(
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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: TextFormField(
                    onTap: () async {
                      if (await onAddFileClicked(context, FileType.image)) {
                        File file =
                            await FilePicker.getFile(type: FileType.image);
                        if (file != null) {
                          setState(() {
                            _newTrip.imageUrl = file.path;
                            _imageController.text = file.path;
                            _newTrip.imageOrigin = FileOrigin.Local;
                          });
                        }
                      }
                    },
                    readOnly: true,
                    style: TextStyle(color: Colors.white70),
                    decoration: InputDecoration(
                      labelText: 'cover image',
                      labelStyle: TextStyle(
                          color: Colors.white70, fontWeight: FontWeight.bold),
                      suffixIcon: Icon(
                        Icons.file_upload,
                        color: Colors.white70,
                      ),
                    ),
                    focusNode: _imageFocus,
                    controller: _imageController,
                  ),
                ),
              )
            ],
          );
        }),
        const SizedBox(height: 20)
      ];
    }

    List<Widget> buildName() {
      return [
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
      ];
    }

    List<Widget> buildPrice() {
      return [
        TextFormField(
          decoration: InputDecoration(
            labelText: 'price',
            helperText: 'write 0 for free',
            suffix: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text('USD'),
            ),
          ),
          validator: (value) =>
              value.isEmpty ? 'input a valid price! insert 0 for free' : null,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          controller: _priceController,
          focusNode: _priceFocus,
          onFieldSubmitted: (_) =>
              FocusScope.of(context).requestFocus(_aboutFocus),
        ),
        const SizedBox(
          height: 30,
        ),
      ];
    }

    List<Widget> buildDescription() {
      return [
        TextFormField(
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            labelText: 'about the trip',
          ),
          textInputAction: TextInputAction.newline,
          controller: _aboutController,
          focusNode: _aboutFocus,
          onFieldSubmitted: (value) =>
              FocusScope.of(context).requestFocus(_priceFocus),
        ),
        const SizedBox(
          height: 30,
        ),
      ];
    }

    List<Widget> buildLocation() {
      return [
        TextFormField(
          onTap: () async {
            PlaceDetails result = await showSearch(
                context: context,
                delegate: PlaceNewSearch(_userPosition, '', Caller.TripNew));
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
                target: LatLng(
                    result.geometry.location.lat, result.geometry.location.lng),
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
                _newTrip = _newTrip;
                _locationController.text = '${result.name}, $_countryName';
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
        )
      ];
    }

    List<Widget> buildLanguage() {
      return [
        DropdownButtonFormField(
          decoration: InputDecoration(
            labelText: 'language',
          ),
          value: _languageCodeController.text,
          // _newTrip.languageNameId != null
          //     ? _newTrip.languageNameId.isNotEmpty
          //         ? _newTrip.languageNameId
          //         : _localeName.split('_')[0].toUpperCase()
          //     : _localeName.split('_')[0].toUpperCase(),
          items: _languages.languages
              .map((lang) => DropdownMenuItem<String>(
                  value: lang.code,
                  child: Text('${lang.nativeName} (${lang.code})')))
              .toList(),
          onChanged: (langCode) {
            var filteredCountries =
                _countries.getByLanguage(langCode, _localeName.split('_')[0]);
            String flagId = filteredCountries
                .firstWhere((c) => c.code == langCode,
                    orElse: () => _countries
                        .getByLanguage(langCode, _localeName.split('_')[0])
                        .firstWhere((c) => c.code == _localeName.split('_')[1],
                            orElse: () => _countries
                                .getByLanguage(
                                    langCode, _localeName.split('_')[0])
                                .first))
                .code;
            setState(
              () {
                _newTrip.languageNameId = langCode;
                _newTrip.languageFlagId = flagId;
                _languageCodeController.text = langCode;
                _languageFlagController.text = flagId;
              },
            );
          },
          validator: (value) =>
              value.isEmpty ? 'input a valid price! insert 0 for free' : null,
        ),
        const SizedBox(
          height: 30,
        ),
        DropdownButtonFormField(
          isExpanded: true,
          decoration: InputDecoration(
              labelText: 'language flag',
              helperText:
                  'choose a country flag to show with the selected language'),
          value: _languageFlagController.text != null
              ? _languageFlagController.text.isNotEmpty
                  ? _languageFlagController.text
                  : _localeName.split('_')[0].toUpperCase()
              : _localeName.split('_')[0].toUpperCase(),
          items: _countries
              .getByLanguage(_newTrip.languageNameId, _localeName.split('_')[0])
              .map(
                (country) => DropdownMenuItem<String>(
                  value: country.code,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Flag(
                        country.code,
                        fit: BoxFit.cover,
                        height: 20,
                        width: 30,
                      ).build(context),
                      SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          '${country.name} (${country.code})',
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (val) => setState(
            () {
              _newTrip.languageFlagId = val;
              _languageFlagController.text = val;
            },
          ),
        ),
        const SizedBox(height: 30),
      ];
    }

    List<Widget> buildPreviewAudio() {
      return [
        TextFormField(
          onTap: () {},
          decoration: InputDecoration(
            labelText: 'preview audio',
            helperText: 'upload preview audio. max length 2 minutes',
            suffixIcon: IconButton(
              icon: Icon(Icons.file_upload),
              onPressed: () async {
                if (await onAddFileClicked(context, FileType.audio)) {
                  File file = await FilePicker.getFile(
                      type: FileType.custom,
                      allowedExtensions: [
                        'mpeg',
                        'wav',
                        'webm',
                        'ogg',
                        'mp3',
                        'mp4',
                        'm4a'
                      ]);

                  if (file != null) {
                    setState(() {
                      _audioController.text = file.absolute.path;
                      _newTrip.previewAudioUrl = file.path;
                      _newTrip.audioOrigin = FileOrigin.Local;
                    });
                  }
                }
              },
            ),
          ),
          readOnly: true,
          textInputAction: TextInputAction.next,
          controller: _audioController,
          focusNode: _audioFocus,
        ),
        const SizedBox(
          height: 30,
        ),
      ];
    }

    Widget addPlaceButton(TripProvider tripProvider) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _newTrip.countryId != null && _newTrip.countryId.length > 0
                  ? Navigator.of(context)
                      .push(
                      MaterialPageRoute(
                        builder: (_) => PlaceNew(
                          _newTrip.countryId,
                          Place(
                            id: 0,
                            tripId: _newTrip.id,
                            coordinates: LatLng(
                                _initialPosition.target.latitude,
                                _initialPosition.target.longitude),
                          ),
                        ),
                      ),
                    )
                      .then((res) {
                      if (res != null) {
                        if (res['item'].tripId > 0)
                          tripProvider.createPlace(res['item']).catchError(
                                (e) => showMessage(context, e, true),
                              );
                        else
                          setState(() {
                            _newPlaces.add(res['item']);
                          });
                      }
                    })
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
        ],
      );
    }

    Widget buildMap() {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey[400]),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        padding: const EdgeInsets.all(5),
        height: 300,
        child: TripMap(_newTrip, _userPosition),
      );
    }

    Widget buildPlacesList() {
      return Consumer<TripProvider>(
        builder: (_, tripProvider, __) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
                contentPadding: const EdgeInsets.only(bottom: 0),
                title: Text(
                  'places',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                trailing: addPlaceButton(tripProvider)),
            Container(
              child: ListView.separated(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: _newPlaces.length,
                padding: const EdgeInsets.all(0),
                separatorBuilder: (_, __) => Divider(
                  height: 10,
                ),
                itemBuilder: (ctx, i) {
                  return ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    leading: Container(
                      width: 60,
                      height: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: '${_newPlaces[i].imageUrl}',
                          placeholder: (_, __) => const Icon(
                            Icons.photo_camera,
                            size: 30,
                          ),
                          errorWidget: (_, __, ___) => const Icon(
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
                          ? _newPlaces[i].price != 99999
                              ? '\$ ${_newPlaces[i].price}'
                              : ''
                          : 'free',
                      style: _subtitleStyle,
                    ),
                    trailing: IconButton(
                      padding: const EdgeInsets.all(0),
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('are you sure?'),
                              content: Text(
                                  'you are deleting ${_newPlaces[i].name} from the places list'),
                              actions: [
                                FlatButton(
                                  child: const Text('NO'),
                                  textColor: Colors.grey[600],
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                                FlatButton(
                                  child: const Text('YES'),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            );
                          },
                        ).then((res) async {
                          if (res) {
                            await tripProvider
                                .deletePlace(_newPlaces[i])
                                .catchError(
                                  (e) => showMessage(context, e, true),
                                );
                          }
                        });
                      },
                    ),
                    onTap: () {
                      Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                          builder: (_) => PlaceNew(
                            _newTrip.countryId,
                            _newPlaces[i],
                          ),
                        ),
                      )
                          .then((res) {
                        if (res != null) {
                          try {
                            if (res['action'] == 'delete')
                              tripProvider.deletePlace(
                                res['item'],
                              );
                            else
                              tripProvider.updatePlace(
                                res['item'],
                              );
                          } catch (e) {
                            showMessage(context, e, true);
                          }
                        }
                      });
                    },
                  );
                },
              ),
            )
          ],
        ),
      );
    }

    return WillPopScope(
      onWillPop: () => onWillPop(_newTrip, context),
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
              icon: Icon(Icons.info_outline),
              onPressed: () {},
            ),
            IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => onDeleteButton(_newTrip, context)),
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
        body: SafeArea(
            child: Form(
          key: _form,
          onChanged: () {
            _newTrip.places = _newPlaces;
            _newTrip.name = _nameController.text;
            _newTrip.about = _aboutController.text;
            _newPlaces.sort((a, b) => a.order.compareTo(b.order));
            _newTrip.locationName = _locationController.text;
            _newTrip.price = _priceController.text.isEmpty
                ? 0
                : double.parse(_priceController.text);
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                //cover image
                ...buildCoverImage(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //trip name
                      ...buildName(),
                      //location
                      ...buildLocation(),
                      //about
                      ...buildDescription(),
                      //price
                      ...buildPrice(),
                      //preview audio
                      ...buildPreviewAudio(),
                      //language
                      ...buildLanguage(),
                      //places list
                      buildPlacesList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
        floatingActionButton: _newTrip.id > 0
            ? FloatingActionButton.extended(
                onPressed: () => submitTrip(_newTrip, context),
                label: const Text(
                  'submit',
                  style: TextStyle(fontSize: 17),
                ),
                icon: const Icon(Icons.cloud_upload),
                backgroundColor: Colors.green[800],
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  final TextStyle _titleStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  final TextStyle _subtitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.black38,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.1,
  );
}

Future<bool> onWillPop(Trip trip, BuildContext context) {
  if (trip.countryId.length > 0 && trip.name.length > 0)
    return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Are you sure you want to exit?'),
          content: Text('You will loose your changes'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'NO',
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            FlatButton(
              child: Text(
                'YES',
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  else
    return Future.delayed(Duration.zero).then((value) => true);
}

void onDeleteButton(Trip trip, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('are you sure?'),
        content: Text('you are deleting the entire trip and its places'),
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
  ).then((res) {
    if (res)
      Navigator.of(context).pop({
        'action': 'delete',
        'item': trip,
      });
  });
}
