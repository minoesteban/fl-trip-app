import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripit/core/controllers/user.controller.dart';
import 'package:tripit/core/models/user.model.dart';
import 'package:tripit/core/utils/utils.dart';

class UserProvider with ChangeNotifier {
  UserController _userController = UserController();
  User _user = User();

  Future<User> getUser(int userId) async {
    return await _userController
        .getUser(userId)
        .then((user) => _user = user)
        .catchError((err) => throw err);
  }

  Future<void> getUserPosition() async {
    await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((value) {
      _user.position = value;
      notifyListeners();
    }).catchError((err) => throw err);
  }

  void toggleFavouriteTrip(int id) {
    if (_user.favouriteTrips.contains(id))
      _user.favouriteTrips.removeWhere((trip) => trip == id);
    else
      _user.favouriteTrips.add(id);

    _userController.update(_user).catchError((err) => throw err);
    notifyListeners();
  }

  void toggleFavouritePlace(int id) {
    if (_user.favouritePlaces.contains(id))
      _user.favouritePlaces.removeWhere((trip) => trip == id);
    else
      _user.favouritePlaces.add(id);

    _userController.update(_user).catchError((err) => throw err);
    notifyListeners();
  }

  void togglePurchasedTrip(int id) {
    if (_user.purchasedTrips.contains(id))
      _user.purchasedTrips.removeWhere((trip) => trip == id);
    else
      _user.purchasedTrips.add(id);

    _userController.update(_user).catchError((err) => throw err);
    notifyListeners();
  }

  void togglePurchasedPlace(int id) {
    if (_user.purchasedPlaces.contains(id))
      _user.purchasedPlaces.removeWhere((trip) => trip == id);
    else
      _user.purchasedPlaces.add(id);

    _userController.update(_user).catchError((err) => throw err);
    notifyListeners();
  }

  bool tripIsFavourite(int id) {
    return _user.favouriteTrips.contains(id);
  }

  bool tripIsPurchased(int id) {
    return _user.purchasedTrips.contains(id);
  }

  bool placeIsFavourite(int id) {
    return _user.favouritePlaces.contains(id);
  }

  bool placeIsPurchased(int id) {
    return _user.purchasedPlaces.contains(id);
  }

  Future<int> update(User newUser) async {
    return await _userController.update(newUser).then((v) {
      _user = newUser;
      notifyListeners();
    }).catchError((err) => throw err);
  }

  void updateImage(PickedFile image) async {
    _user.imageUrl = image.path;
    _user.imageOrigin = FileOrigin.Local;
    notifyListeners();

    String downloadUrl = await _userController.uploadImage(_user.id, image);
    if (downloadUrl != null) {
      _user.imageUrl = downloadUrl;
      _user.imageOrigin = FileOrigin.Network;
    }
    notifyListeners();
  }

  String getImage() {
    // return '$_endpoint/${_user.imageUrl}';
    return '${_user.imageUrl}';
  }

  User get user {
    return _user;
  }
}
