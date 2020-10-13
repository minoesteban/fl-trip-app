import 'package:flutter/material.dart';
import 'package:tripper/core/controllers/language.controller.dart';
import '../core/models/language.model.dart';

class LanguageProvider with ChangeNotifier {
  LanguageController _controller = LanguageController();
  List<Language> _languages;

  LanguageProvider() {
    loadLanguages().then((v) => print('languageprovider init'));
  }

  Future<void> loadLanguages() async {
    await _controller.getLanguages().then((res) {
      _languages = res..sort((a, b) => a.code.compareTo(b.code));
      _languages = _languages.toSet().toList();
      notifyListeners();
    }).catchError((err) => throw err);
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
