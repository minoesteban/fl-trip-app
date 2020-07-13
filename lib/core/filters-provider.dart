import 'package:flutter/material.dart';

class Filters with ChangeNotifier {
  bool _nearest = true;
  bool _onlyDownloaded = false;
  bool _onlyPurchased = false;
  bool _onlyFavourites = false;
  bool _onlyFree = false;

  set nearest(val) {
    _nearest = val;
    print('set only near');
    notifyListeners();
  }

  set onlyDownloaded(val) {
    _onlyDownloaded = val;
    print('set only dow');
    notifyListeners();
  }

  set onlyPurchased(val) {
    _onlyPurchased = val;
    print('set only pur');
    notifyListeners();
  }

  set onlyFavourites(val) {
    _onlyFavourites = val;
    print('set only fav');
    notifyListeners();
  }

  set onlyFree(val) {
    _onlyFree = val;
    print('set only free');
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
