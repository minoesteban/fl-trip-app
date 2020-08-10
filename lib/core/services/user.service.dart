import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import '../../config.dart';
import '../../core/models/user.model.dart';

class UserService {
  Map<String, String> _headers = {'content-type': 'application/json'};

  String _endpoint = Platform.isAndroid ? API_ENDPOINT_ANDROID : API_ENDPOINT;

  Future<User> getUser(int userId) async {
    String url = '$_endpoint/users/$userId';
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
    String url = '$_endpoint/users/${newUser.id}';
    final res = await http.patch(url,
        headers: _headers, body: json.encode(newUser.toMap()));
    if (res.statusCode == HttpStatus.ok) {
      //json.decode(res.body)['item'][1] --> updated record
      return json.decode(res.body)[0]; //# updated records
    } else {
      throw HttpException(res.body);
    }
  }

  Future<String> uploadImage(int id, PickedFile pickedFile) async {
    String fileExtension = path.extension(pickedFile.path).substring(1);
    String url = '$_endpoint/users/$id/files?type=$fileExtension';
    var res = await http.put(url);
    if (res.statusCode == HttpStatus.ok) {
      String downloadUrl = json.decode(res.body)['downloadUrl'];
      File file = File(pickedFile.path);

      file = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        '${file.absolute.path.replaceAll('image_picker', 'compressed_image_picker')}',
        minHeight: 1000,
        minWidth: 1000,
        quality: 88,
      );

      res = await http.put(json.decode(res.body)['uploadUrl'],
          body: file.readAsBytesSync());
      if (res.statusCode == HttpStatus.ok) {
        String url = '$_endpoint/users/$id';
        final res = await http.patch(url,
            headers: _headers, body: json.encode({'imageUrl': downloadUrl}));
        if (res.statusCode == HttpStatus.ok) {
          return json.decode(res.body)['item'][1][0]['imageUrl'];
        } else {
          throw HttpException(res.body);
        }
      } else
        throw HttpException(res.body);
    } else
      throw HttpException(res.body);
  }
}
