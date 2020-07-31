import 'package:flutter/material.dart';
import 'package:tripit/core/controllers/language.controller.dart';
import '../core/models/language.model.dart';

class LanguageProvider with ChangeNotifier {
  LanguageController _controller = LanguageController();
  List<Language> _languages;

  Future<List<Language>> loadLanguages() async {
    await _controller.getLanguages().then((res) {
      _languages = res;
      notifyListeners();
    }).catchError((err) => throw err);
    return _languages;
  }

  String getNativeName(String code) {
    return _languages
        .firstWhere((cty) => cty.code.toLowerCase() == code.toLowerCase())
        .nativeName
        .toLowerCase();
  }

  List<Language> get languages {
    return _languages;
  }
}
