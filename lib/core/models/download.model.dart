import 'dart:convert';

import 'package:hive/hive.dart';

part 'download.model.g.dart';

@HiveType(typeId: 9)
class Download {
  @HiveField(0)
  int id;
  @HiveField(1)
  int tripId;
  @HiveField(2)
  int placeId;
  @HiveField(3)
  String filePath;
  @HiveField(4)
  bool isFullAudio;

  Download({
    this.id,
    this.tripId,
    this.placeId,
    this.filePath,
  });

  Download copyWith({
    int id,
    int tripId,
    int placeId,
    String filePath,
  }) {
    return Download(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      placeId: placeId ?? this.placeId,
      filePath: filePath ?? this.filePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'placeId': placeId,
      'filePath': filePath,
    };
  }

  factory Download.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Download(
      id: map['id'],
      tripId: map['tripId'],
      placeId: map['placeId'],
      filePath: map['filePath'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Download.fromJson(String source) =>
      Download.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Download(id: $id, tripId: $tripId, placeId: $placeId, filePath: $filePath)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Download &&
        o.id == id &&
        o.tripId == tripId &&
        o.placeId == placeId &&
        o.filePath == filePath;
  }

  @override
  int get hashCode {
    return id.hashCode ^ tripId.hashCode ^ placeId.hashCode ^ filePath.hashCode;
  }
}
