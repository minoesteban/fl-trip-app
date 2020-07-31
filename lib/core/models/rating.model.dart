import 'dart:convert';

class Rating {
  int id;
  int userId;
  int tripId;
  int placeId;
  double rating;
  int count;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime deletedAt;
  Rating({
    this.id,
    this.userId,
    this.tripId,
    this.placeId,
    this.rating,
    this.count,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  Rating copyWith({
    int id,
    int userId,
    int tripId,
    int placeId,
    double rating,
    int count,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime deletedAt,
  }) {
    return Rating(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tripId: tripId ?? this.tripId,
      placeId: placeId ?? this.placeId,
      rating: rating ?? this.rating,
      count: count ?? this.count,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'tripId': tripId,
      'placeId': placeId,
      'rating': rating,
      'count': count,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
    };
  }

  static Rating fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Rating(
      id: map['id'],
      userId: map['userId'],
      tripId: map['tripId'],
      placeId: map['placeId'],
      rating: double.parse(map['rating']),
      count: int.parse(map['count']),
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      deletedAt: map['deletedAt'],
    );
  }

  String toJson() => json.encode(toMap());

  static Rating fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'Rating(id: $id, userId: $userId, tripId: $tripId, placeId: $placeId, rating: $rating, count: $count, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Rating &&
        o.id == id &&
        o.userId == userId &&
        o.tripId == tripId &&
        o.placeId == placeId &&
        o.rating == rating &&
        o.count == count &&
        o.createdAt == createdAt &&
        o.updatedAt == updatedAt &&
        o.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        tripId.hashCode ^
        placeId.hashCode ^
        rating.hashCode ^
        count.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }
}
