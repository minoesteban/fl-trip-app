import 'dart:convert';

import 'package:flutter/foundation.dart';

class Country {
  String code;
  String name;
  Map<String, String> translations;
  Country({
    this.code,
    this.name,
    this.translations,
  });

  Country copyWith({
    String code,
    String name,
    Map<String, String> translations,
  }) {
    return Country(
      code: code ?? this.code,
      name: name ?? this.name,
      translations: translations ?? this.translations,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'translations': translations,
    };
  }

  static Country fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Country(
      code: map['alpha2Code'],
      name: map['name'],
      translations: Map<String, String>.from(map['translations']),
    );
  }

  String toJson() => json.encode(toMap());

  static Country fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() =>
      'Country(code: $code, name: $name, translations: $translations)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Country &&
        o.code == code &&
        o.name == name &&
        mapEquals(o.translations, translations);
  }

  @override
  int get hashCode => code.hashCode ^ name.hashCode ^ translations.hashCode;
}

// class Country {
//   String _code;
//   String _name;
//   Map<String, String> _translations;

//   Country(this._code, this._name, this._translations);

//   factory Country.fromMap(Map<String, String> map) {
//     return Country(
//       map['alpha2Code'] == null ? null : map['alpha2Code'],
//       map['name'] == null ? null : map['name'],
//       map['translations'] == null ? null : jsonDecode(map['translations']),
//     );
//   }

//   List<String> getNames() {
//     List<String> _names = [];
//     _names.add(_name);
//     _names.addAll(_translations.values);
//     return _names;
//   }

//   String get name {
//     return _name;
//   }

//   String get code {
//     return _code;
//   }

//   Map<String, String> get translations {
//     return _translations;
//   }
// }
