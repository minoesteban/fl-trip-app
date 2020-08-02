import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../config.dart';
import '../../core/models/user.model.dart';

class UserService {
  Map<String, String> _headers = {'content-type': 'application/json'};

  String _endpoint = Platform.isAndroid ? API_ENDPOINT_ANDROID : API_ENDPOINT;

  Future<User> getUser(int userId) async {
    String url = '$_endpoint/user/$userId';
    final res = await http.get(url);
    if (res.statusCode == HttpStatus.ok)
      return await parseUser(res.body);
    else
      throw HttpException(res.body);
  }

  Future<User> parseUser(String data) async {
    final decoded = json.decode(data);
    return User.fromMap(decoded['user']);
  }

  Future<int> update(User newUser) async {
    String url = '$_endpoint/user/${newUser.id}';
    final res = await http.patch(url,
        headers: _headers, body: json.encode(newUser.toMap()));
    if (res.statusCode == HttpStatus.ok) {
      //json.decode(res.body)['item'][1] --> updated record
      return json.decode(res.body)[0]; //# updated records
    } else {
      throw HttpException(res.body);
    }
  }
}
