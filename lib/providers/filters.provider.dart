import 'package:flutter/material.dart';

class Filters with ChangeNotifier {
  bool _nearest = true;
  bool _onlyDownloaded = false;
  bool _onlyPurchased = false;
  bool _onlyFavourites = false;
  bool _onlyFree = false;

  set nearest(val) {
    _nearest = val;
    notifyListeners();
  }

  set onlyDownloaded(val) {
    _onlyDownloaded = val;
    notifyListeners();
  }

  set onlyPurchased(val) {
    _onlyPurchased = val;
    notifyListeners();
  }

  set onlyFavourites(val) {
    _onlyFavourites = val;
    notifyListeners();
  }

  set onlyFree(val) {
    _onlyFree = val;
    notifyListeners();
  }

  bool get nearest {
    return _nearest;
  }

  bool get onlyDownloaded {
    return _onlyDownloaded;
  }

  bool get onlyPurchased {
    return _onlyPurchased;
  }

  bool get onlyFavourites {
    return _onlyFavourites;
  }

  bool get onlyFree {
    return _onlyFree;
  }

  void saveFilters() {
    notifyListeners();
  }
}
