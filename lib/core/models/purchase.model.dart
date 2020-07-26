import 'dart:convert';

class Purchase {
  int id;
  int tripId;
  int userId;
  int rating;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime deletedAt;
  Purchase({
    this.id,
    this.tripId,
    this.userId,
    this.rating,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  Purchase copyWith({
    int id,
    int tripId,
    int userId,
    int rating,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime deletedAt,
  }) {
    return Purchase(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'userId': userId,
      'rating': rating,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'deletedAt': deletedAt?.millisecondsSinceEpoch,
    };
  }

  static Purchase fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Purchase(
      id: map['id'],
      tripId: map['tripId'],
      userId: map['userId'],
      rating: map['rating'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      deletedAt: DateTime.fromMillisecondsSinceEpoch(map['deletedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  static Purchase fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'Purchase(id: $id, tripId: $tripId, userId: $userId, rating: $rating, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Purchase &&
        o.id == id &&
        o.tripId == tripId &&
        o.userId == userId &&
        o.rating == rating &&
        o.createdAt == createdAt &&
        o.updatedAt == updatedAt &&
        o.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tripId.hashCode ^
        userId.hashCode ^
        rating.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }
}
