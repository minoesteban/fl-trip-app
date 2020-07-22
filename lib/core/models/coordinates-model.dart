class Coordinates {
  double latitude;
  double longitude;

  Coordinates({this.latitude, this.longitude});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      latitude: json['latitude'] == null ? null : json['latitude'],
      longitude: json['longitude'] == null ? null : json['longitude'],
    );
  }
}
