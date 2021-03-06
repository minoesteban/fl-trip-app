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
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
    };
  }

  static Purchase fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Purchase(
      id: map['id'],
      tripId: map['tripId'],
      userId: map['userId'],
      rating: map['rating'],
      createdAt: DateTime.tryParse(map['created_at']),
      updatedAt: DateTime.tryParse(map['updated_at']),
      // deletedAt: DateTime.tryParse(map['deleted_at']),
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

class PurchaseCount {
  int tripId;
  int placeId;
  int count;
  PurchaseCount({
    this.tripId,
    this.placeId,
    this.count,
  });

  PurchaseCount copyWith({
    int tripId,
    int placeId,
    int count,
  }) {
    return PurchaseCount(
      tripId: tripId ?? this.tripId,
      placeId: placeId ?? this.placeId,
      count: count ?? this.count,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'placeId': placeId,
      'count': count,
    };
  }

  factory PurchaseCount.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return PurchaseCount(
      tripId: map['tripId'] ?? 0,
      placeId: map['placeId'] ?? 0,
      count: int.tryParse(map['count']) ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory PurchaseCount.fromJson(String source) =>
      PurchaseCount.fromMap(json.decode(source));

  @override
  String toString() =>
      'PurchaseCount(tripId: $tripId, placeId: $placeId, count: $count)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is PurchaseCount &&
        o.tripId == tripId &&
        o.placeId == placeId &&
        o.count == count;
  }

  @override
  int get hashCode => tripId.hashCode ^ placeId.hashCode ^ count.hashCode;
}
