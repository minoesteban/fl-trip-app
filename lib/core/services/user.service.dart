import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:tripper/core/utils/utils.dart';
import 'package:tripper/providers/credentials.provider.dart';
import '../../config.dart';
import '../../core/models/user.model.dart';
import '../models/http_exception.dart';

class UserService {
  Map<String, String> _headers = {'content-type': 'application/json'};
  String _endpoint = Platform.isAndroid ? API_ENDPOINT_ANDROID : API_ENDPOINT;

  Future<User> getUser(int userId) async {
    String url = '$_endpoint/users/$userId';
    try {
      var _headersJustKey = {'x-api-key': await getKey('gk')};
      final res = await http.get(url, headers: _headersJustKey);
      if (res.statusCode == HttpStatus.ok)
        return await parseUser(res.body);
      else
        throw HttpException(res.body);
    } on HttpException catch (err) {
      throw err;
    } catch (err) {
      throw err;
    }
  }

  Future<int> login(String user, String password) async {
    String url = '$_endpoint/users/login';
    try {
      final res = await http.post(url,
          headers: _headers,
          body: json
              .encode({'username': user.trim(), 'password': password.trim()}));
      switch (res.statusCode) {
        case HttpStatus.ok:
          //Seteo keys varias
          final storage = FlutterSecureStorage();
          await storage.write(
              key: 'keys', value: json.encode(json.decode(res.body)['keys']));
          print(await storage.read(key: 'keys'));
          return json.decode(res.body)['message'];
          break;
        case HttpStatus.badRequest:
          throw HttpException(json.decode(res.body)['message']);
          break;
        default:
          throw HttpException(json.decode(res.body));
      }
    } on HttpException catch (err) {
      throw err;
    } catch (err) {
      throw err;
    }
  }

  Future<bool> signup(String user, String password) async {
    String url = '$_endpoint/users/signup';
    try {
      final res = await http.post(url,
          headers: _headers,
          body: json
              .encode({'username': user.trim(), 'password': password.trim()}));

      switch (res.statusCode) {
        case HttpStatus.ok:
          return true;
          break;
        case HttpStatus.badRequest:
          throw HttpException(json.decode(res.body)['message']);
          break;
        default:
          throw HttpException(json.decode(res.body));
      }
    } on HttpException catch (err) {
      throw err;
    } catch (err) {
      throw err;
    }
  }

  Future<bool> activate(String user, String pin) async {
    String url = '$_endpoint/users/activate';
    try {
      final res = await http.put(url,
          headers: _headers,
          body: json.encode({'username': user.trim(), 'PIN': pin.trim()}));

      switch (res.statusCode) {
        case HttpStatus.ok:
          return true;
          break;
        case HttpStatus.badRequest:
          throw HttpException(json.decode(res.body)['message']);
          break;
        default:
          throw HttpException(json.decode(res.body));
      }
    } on HttpException catch (err) {
      throw err;
    } catch (err) {
      throw err;
    }
  }

  Future<int> update(User newUser) async {
    String url = '$_endpoint/users/${newUser.id}';
    try {
      var _headersWithKey = _headers;
      _headersWithKey['x-api-key'] = await getKey('gk');
      final res = await http.patch(url,
          headers: _headersWithKey, body: json.encode(newUser.toMapForDB()));

      switch (res.statusCode) {
        case HttpStatus.ok:
          return json.decode(res.body)[0]; //# updated records
          break;
        case HttpStatus.badRequest:
          throw HttpException(json.decode(res.body)['message']);
          break;
        default:
          throw HttpException(json.decode(res.body));
      }
    } on HttpException catch (err) {
      throw err;
    } catch (err) {
      throw err;
    }
  }

  Future<String> uploadImage(int id, File pickedFile) async {
    String fileExtension = path.extension(pickedFile.path).substring(1);
    String url = '$_endpoint/users/$id/files?type=$fileExtension';
    try {
      var _headersJustKey = {'x-api-key': await getKey('gk')};
      var _headersWithKey = _headers..addAll(_headersJustKey);

      final res = await http.put(url, headers: _headersJustKey);

      switch (res.statusCode) {
        case HttpStatus.ok:
          String downloadUrl = json.decode(res.body)['downloadUrl'];
          File file = File(pickedFile.path);
          file = await compress(file);
          final res2 = await http.put(json.decode(res.body)['uploadUrl'],
              body: file.readAsBytesSync());

          switch (res2.statusCode) {
            case HttpStatus.ok:
              String url = '$_endpoint/users/$id';
              final res3 = await http.patch(url,
                  headers: _headersWithKey,
                  body: json.encode({'imageUrl': downloadUrl}));
              if (res3.statusCode == HttpStatus.ok) {
                return json.decode(res3.body)['item'][1][0]['imageUrl'];
              } else {
                throw HttpException(res3.body);
              }
              break;
            case HttpStatus.badRequest:
              throw HttpException(json.decode(res2.body));
              break;
            default:
              throw HttpException(json.decode(res2.body));
          }
          break;
        case HttpStatus.badRequest:
          throw HttpException(json.decode(res.body)['message']);
          break;
        default:
          throw HttpException(json.decode(res.body));
      }
    } on HttpException catch (err) {
      throw err;
    } catch (err) {
      throw err;
    }
  }

  Future<User> parseUser(String data) async {
    final decoded = json.decode(data);
    return User.fromMap(decoded['user']);
  }
}
