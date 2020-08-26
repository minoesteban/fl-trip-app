// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TripAdapter extends TypeAdapter<Trip> {
  @override
  final int typeId = 2;

  @override
  Trip read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Trip(
      id: fields[0] as int,
      name: fields[1] as String,
      ownerId: fields[2] as int,
      googlePlaceId: fields[3] as String,
      locationName: fields[4] as String,
      countryId: fields[5] as String,
      previewAudioUrl: fields[9] as String,
      languageNameId: fields[10] as String,
      languageFlagId: fields[11] as String,
      price: fields[12] as double,
      about: fields[13] as String,
      submitted: fields[14] as bool,
      published: fields[15] as bool,
      imageUrl: fields[7] as String,
      places: (fields[16] as List)?.cast<Place>(),
      createdAt: fields[17] as DateTime,
      updatedAt: fields[18] as DateTime,
      deletedAt: fields[19] as DateTime,
    )
      ..imageOrigin = fields[6] as FileOrigin
      ..audioOrigin = fields[8] as FileOrigin
      ..needSync = fields[20] as bool;
  }

  @override
  void write(BinaryWriter writer, Trip obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.ownerId)
      ..writeByte(3)
      ..write(obj.googlePlaceId)
      ..writeByte(4)
      ..write(obj.locationName)
      ..writeByte(5)
      ..write(obj.countryId)
      ..writeByte(6)
      ..write(obj.imageOrigin)
      ..writeByte(7)
      ..write(obj.imageUrl)
      ..writeByte(8)
      ..write(obj.audioOrigin)
      ..writeByte(9)
      ..write(obj.previewAudioUrl)
      ..writeByte(10)
      ..write(obj.languageNameId)
      ..writeByte(11)
      ..write(obj.languageFlagId)
      ..writeByte(12)
      ..write(obj.price)
      ..writeByte(13)
      ..write(obj.about)
      ..writeByte(14)
      ..write(obj.submitted)
      ..writeByte(15)
      ..write(obj.published)
      ..writeByte(16)
      ..write(obj.places)
      ..writeByte(17)
      ..write(obj.createdAt)
      ..writeByte(18)
      ..write(obj.updatedAt)
      ..writeByte(19)
      ..write(obj.deletedAt)
      ..writeByte(20)
      ..write(obj.needSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
