// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RatingAdapter extends TypeAdapter<Rating> {
  @override
  final int typeId = 4;

  @override
  Rating read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Rating(
      id: fields[0] as int,
      userId: fields[1] as int,
      tripId: fields[2] as int,
      placeId: fields[3] as int,
      rating: fields[4] as double,
      count: fields[5] as int,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
      deletedAt: fields[8] as DateTime,
    )..needSync = fields[9] as bool;
  }

  @override
  void write(BinaryWriter writer, Rating obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.tripId)
      ..writeByte(3)
      ..write(obj.placeId)
      ..writeByte(4)
      ..write(obj.rating)
      ..writeByte(5)
      ..write(obj.count)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.deletedAt)
      ..writeByte(9)
      ..write(obj.needSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RatingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
