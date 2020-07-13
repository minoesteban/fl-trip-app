import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class UserPosition with ChangeNotifier {
  Position _position;

  UserPosition() {
    Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((value) {
      _position = value;
      notifyListeners();
    }).catchError((err) => print('getCurrentPosition $err'));
  }

  void setPosition(Position p) {
    _position = p;
    notifyListeners();
  }

  Position get getPosition {
    return _position;
  }
}
