import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/language.model.dart';

class LanguageService {
  Future<List<Language>> getLanguages() async {
    String data = await rootBundle.loadString('assets/countries-full.json');
    return parseLanguages(data);
  }

  List<Language> parseLanguages(String data) {
    final decoded = json.decode(data);
    List<dynamic> languagesRaw = [];
    decoded.forEach((json) {
      languagesRaw.addAll(json['languages'].map((e) => e));
    });
    return languagesRaw.map((lang) => Language.fromMap(lang)).toList();
  }
}
