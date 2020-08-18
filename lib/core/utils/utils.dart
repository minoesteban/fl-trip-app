import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';

String getRandString(int len) {
  var random = Random.secure();
  var values = List<int>.generate(len, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

Future<File> compress(File file) async {
  String fileName = path.basenameWithoutExtension(file.path);
  String fileNameZipped = fileName + '_cmp';
  return await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    '${file.absolute.path.replaceAll(fileName, fileNameZipped)}',
    minHeight: 400,
    minWidth: 400,
    quality: 90,
  );
}

enum FileOrigin { Local, Network }
