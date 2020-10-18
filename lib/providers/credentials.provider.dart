import 'package:flutter/material.dart';
import '../credentials.dart';

class CredentialsProvider extends ChangeNotifier {
  // Map<String, dynamic> _keys;
  // CredentialsProvider() {
  //   final storage = FlutterSecureStorage();
  //   storage.read(key: 'keys').then((v) {
  //     _keys = v != null ? json.decode(v) : {};
  //   });
  // }
  // Future<String> getKey(String key) async {
  //   final storage = FlutterSecureStorage();
  //   return json.decode(await storage.read(key: 'keys'))[key];
  // }

  String get googlePlacesApiKey {
    return GP;
    // return _keys['gp'];
  }

  String get awsAccessKey {
    return AK;
    // return _keys['ak'];
  }

  String get awsSecretKey {
    return SK;
    // return _keys['sk'];
  }

  String get gatewayApiKey {
    return GK;
    // return _keys['gk'];
  }

  String get oneSignalAppId {
    return OI;
    // return _keys['oi'];
  }
}

String getKey(String key) {
  switch (key) {
    case 'gp':
      return GP;
      break;
    case 'ak':
      return AK;
      break;
    case 'sk':
      return SK;
      break;
    case 'gk':
      return GK;
      break;
    case 'oi':
      return OI;
      break;
    default:
      return '';
  }
}
