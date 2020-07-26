import 'package:flutter/material.dart';
import 'package:tripit/core/controllers/country.controller.dart';
import '../core/models/country.model.dart';

class CountryProvider with ChangeNotifier {
  CountryController _controller = CountryController();
  List<Country> _countries;

  Future loadCountries() async {
    await _controller.getCountries().then((res) => _countries = res);
  }

  String getName(String code) {
    final result = _countries.firstWhere((cty) => cty.code == code).name;
    return result;
  }

  List<Country> getByName(String name) {
    final result = _countries
        .where((cty) => cty.name.toLowerCase().contains(name.toLowerCase()));
    return result.toList();
  }
}
