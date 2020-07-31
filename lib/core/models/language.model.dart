import 'dart:convert';

class Language {
  String code;
  String name;
  String nativeName;
  Language({
    this.code,
    this.name,
    this.nativeName,
  });

  Language copyWith({
    String code,
    String name,
    String nativeName,
  }) {
    return Language(
      code: code ?? this.code,
      name: name ?? this.name,
      nativeName: nativeName ?? this.nativeName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'nativeName': nativeName,
    };
  }

  static Language fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Language(
      code: map['iso639_1'],
      name: map['name'],
      nativeName: map['nativeName'],
    );
  }

  String toJson() => json.encode(toMap());

  static Language fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() =>
      'Language(code: $code, name: $name, nativeName: $nativeName)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Language &&
        o.code == code &&
        o.name == name &&
        o.nativeName == nativeName;
  }

  @override
  int get hashCode => code.hashCode ^ name.hashCode ^ nativeName.hashCode;
}
