// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaceAdapter extends TypeAdapter<Place> {
  @override
  final int typeId = 3;

  @override
  Place read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Place(
      id: fields[0] as int,
      name: fields[1] as String,
      about: fields[2] as String,
      googlePlaceId: fields[3] as String,
      locationName: fields[4] as String,
      coordinates: fields[5] as Coordinates,
      fullAudioUrl: fields[6] as String,
      fullAudioOrigin: fields[7] as FileOrigin,
      fullAudioLength: fields[21] as double,
      previewAudioUrl: fields[8] as String,
      previewAudioOrigin: fields[9] as FileOrigin,
      imageUrl: fields[10] as String,
      price: fields[12] as double,
      order: fields[13] as int,
      tripId: fields[14] as int,
      ratingAvg: fields[15] as double,
      ratingCount: fields[16] as int,
      createdAt: fields[17] as DateTime,
      updatedAt: fields[18] as DateTime,
      deletedAt: fields[19] as DateTime,
    )
      ..imageOrigin = fields[11] as FileOrigin
      ..needSync = fields[20] as bool;
  }

  @override
  void write(BinaryWriter writer, Place obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.about)
      ..writeByte(3)
      ..write(obj.googlePlaceId)
      ..writeByte(4)
      ..write(obj.locationName)
      ..writeByte(5)
      ..write(obj.coordinates)
      ..writeByte(6)
      ..write(obj.fullAudioUrl)
      ..writeByte(7)
      ..write(obj.fullAudioOrigin)
      ..writeByte(8)
      ..write(obj.previewAudioUrl)
      ..writeByte(9)
      ..write(obj.previewAudioOrigin)
      ..writeByte(10)
      ..write(obj.imageUrl)
      ..writeByte(11)
      ..write(obj.imageOrigin)
      ..writeByte(12)
      ..write(obj.price)
      ..writeByte(13)
      ..write(obj.order)
      ..writeByte(14)
      ..write(obj.tripId)
      ..writeByte(15)
      ..write(obj.ratingAvg)
      ..writeByte(16)
      ..write(obj.ratingCount)
      ..writeByte(17)
      ..write(obj.createdAt)
      ..writeByte(18)
      ..write(obj.updatedAt)
      ..writeByte(19)
      ..write(obj.deletedAt)
      ..writeByte(20)
      ..write(obj.needSync)
      ..writeByte(21)
      ..write(obj.fullAudioLength);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
