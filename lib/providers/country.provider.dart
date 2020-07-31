import 'package:flutter/material.dart';
import 'package:tripit/core/controllers/country.controller.dart';
import '../core/models/country.model.dart';

class CountryProvider with ChangeNotifier {
  CountryController _controller = CountryController();
  List<Country> _countries;

  Future<List<Country>> loadCountries() async {
    await _controller.getCountries().then((res) {
      _countries = res;
      notifyListeners();
    }).catchError((err) => throw err);
    return _countries;
  }

  String getName(String code) {
    return _countries
        .firstWhere((cty) => cty.code.toLowerCase() == code.toLowerCase())
        .name;
  }

  List<Country> getByName(String name) {
    final result = _countries
        .where((cty) => cty.name.toLowerCase().contains(name.toLowerCase()));
    return result.toList();
  }

  List<Country> get countries {
    return _countries;
  }
}
