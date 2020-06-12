class Region {
  double latitude;
  double longitude;
  double latitudeDelta;
  double longitudeDelta;

  Region(
      {this.latitude, this.latitudeDelta, this.longitude, this.longitudeDelta});

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      latitude: json['latitude'] == null ? null : json['latitude'],
      latitudeDelta:
          json['latitudeDelta'] == null ? null : json['latitudeDelta'],
      longitude: json['longitude'] == null ? null : json['longitude'],
      longitudeDelta:
          json['longitudeDelta'] == null ? null : json['longitudeDelta'],
    );
  }
}
