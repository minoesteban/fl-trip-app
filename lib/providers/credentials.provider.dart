import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CredentialsProvider extends ChangeNotifier {
  Map<String, dynamic> _keys;

  CredentialsProvider() {
    final storage = FlutterSecureStorage();
    storage.read(key: 'keys').then((v) {
      _keys = json.decode(v);
    });
  }

  String get googlePlacesApiKey {
    return _keys['gp'];
  }

  String get awsAccessKey {
    return _keys['ak'];
  }

  String get awsSecretKey {
    return _keys['sk'];
  }

  String get gatewayApiKey {
    return _keys['gk'];
  }

  String get oneSignalAppId {
    return _keys['oi'];
  }
}

Future<String> getKey(String key) async {
  final storage = FlutterSecureStorage();
  return json.decode(await storage.read(key: 'keys'))[key];
}
