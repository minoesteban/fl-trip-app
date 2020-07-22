import 'package:flutter/material.dart';
import 'package:tripit/core/models/trip-model.dart';
import 'package:tripit/providers/trips-provider.dart';

class Guide with ChangeNotifier {
  String _id = 'giorgio';
  List<Trip> _trips;

  Guide(String id) {
    _id = id;
    _trips = Trips().findByGuide(_id).toList();
    notifyListeners();
  }

  List<String> getLanguages() {
    List<String> languages = [];
    _trips.forEach((e) => languages.add(e.language));
    return languages;
  }

  double get rating {
    return 0.0;
  }
}
