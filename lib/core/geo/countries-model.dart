import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Country {
  String _code;
  String _name;
  Map<String, String> _translations;

  Country(this._code, this._name, this._translations);

  factory Country.fromJson(Map<String, String> json) {
    return Country(
      json['alpha2Code'] == null ? null : json['alpha2Code'],
      json['name'] == null ? null : json['name'],
      json['translations'] == null ? null : jsonDecode(json['translations']),
    );
  }

  List<String> getNames() {
    List<String> _names = [];
    _names.add(_name);
    _names.addAll(_translations.values);
    return _names;
  }

  String get name {
    return _name;
  }

  String get code {
    return _code;
  }

  Map<String, String> get translations {
    return _translations;
  }
}

class Countries {
  List<Country> _countries = [];

  Countries() {
    _loadCountries();
  }

  Future _loadCountries() async {
    String jsonString =
        await rootBundle.loadString('assets/countries-full.json');
    final jsonResponse = jsonDecode(jsonString);
    for (var i = 0; i < jsonResponse.length; i++) {
      _countries.add(Country.fromJson(jsonResponse[i]));
    }
  }
}
