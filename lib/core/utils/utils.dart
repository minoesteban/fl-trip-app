import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;

part 'utils.g.dart';

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

@HiveType(typeId: 5)
enum FileOrigin {
  @HiveField(0)
  Local,
  @HiveField(1)
  Network
}

@HiveType(typeId: 8)
class Coordinates {
  @HiveField(0)
  double latitude;
  @HiveField(1)
  double longitude;
  Coordinates(
    this.latitude,
    this.longitude,
  );

  Coordinates copyWith({
    double latitude,
    double longitude,
  }) {
    return Coordinates(
      latitude ?? this.latitude,
      longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Coordinates.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Coordinates(
      map['latitude'],
      map['longitude'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Coordinates.fromJson(String source) =>
      Coordinates.fromMap(json.decode(source));

  @override
  String toString() =>
      'Coordinates(latitude: $latitude, longitude: $longitude)';
}
