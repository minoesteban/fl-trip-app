import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tripper/core/controllers/user.controller.dart';
import 'package:tripper/core/models/user.model.dart';

class UserProvider with ChangeNotifier {
  UserController _controller = UserController();
  User _user = User();

  Future<int> login(String user, String password) async {
    int userId = await _controller.login(user, password);
    await getUser(userId, true);
    return userId;
  }

  Future<bool> signup(String user, String password) async {
    return await _controller.signup(user, password);
  }

  Future<bool> activate(String user, String pin) async {
    return await _controller.activate(user, pin);
  }

  Future<void> init() async {
    _user = await _controller.init();
  }

  Future<void> logout() async {
    return await _controller.logout();
  }

  Future<User> getUser(int userId, bool isCurrentUser) async {
    try {
      User user = await _controller.getUser(userId);
      if (isCurrentUser) {
        _user = user;
        _user.position = await getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 10));
        await _controller.setCurrentLocal(user);
      }
      return user;
    } catch (err) {
      throw err;
    }
  }

  Future<void> getUserPosition() async {
    try {
      Position position = await getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10));
      _user.position = position;
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  void toggleFavouriteTrip(int id) {
    if (_user.favouriteTrips.contains(id))
      _user.favouriteTrips.removeWhere((trip) => trip == id);
    else
      _user.favouriteTrips.add(id);

    _controller.update(_user).catchError((err) => throw err);
    notifyListeners();
  }

  void toggleFavouritePlace(int id) {
    if (_user.favouritePlaces.contains(id))
      _user.favouritePlaces.removeWhere((trip) => trip == id);
    else
      _user.favouritePlaces.add(id);

    _controller.update(_user).catchError((err) => throw err);
    notifyListeners();
  }

  void togglePurchasedTrip(int id) {
    if (_user.purchasedTrips.contains(id))
      _user.purchasedTrips.removeWhere((trip) => trip == id);
    else
      _user.purchasedTrips.add(id);

    _controller.update(_user).catchError((err) => throw err);
    notifyListeners();
  }

  void togglePurchasedPlace(int id) {
    if (_user.purchasedPlaces.contains(id))
      _user.purchasedPlaces.removeWhere((trip) => trip == id);
    else
      _user.purchasedPlaces.add(id);

    _controller.update(_user).catchError((err) => throw err);
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
    return await _controller.update(newUser).then((v) {
      _user = newUser;
      notifyListeners();
    }).catchError((err) => throw err);
  }

  void updateImage(File image) async {
    _user.imageUrl = image.path;
    notifyListeners();

    String downloadUrl = await _controller.uploadImage(_user.id, image);
    if (downloadUrl != null) {
      _user.imageUrl = downloadUrl;
    }
    notifyListeners();
  }

  User get user {
    return _user;
  }
}
