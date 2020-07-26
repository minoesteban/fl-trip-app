import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/country.model.dart';

class CountryService {
  Future<List<Country>> getCountries() async {
    String data = await rootBundle.loadString('assets/countries-full.json');
    return parseCountries(data);
  }

  List<Country> parseCountries(String data) {
    final decoded = json.decode(data);
    return decoded?.map<Country>((json) => Country.fromMap(json))?.toList();
  }
}
