// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 1;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as int,
      username: fields[1] as String,
      firstName: fields[2] as String,
      lastName: fields[3] as String,
      imageUrl: fields[4] as String,
      about: fields[7] as String,
      selectedLanguages: (fields[6] as List)?.cast<String>(),
      favouriteTrips: (fields[8] as List)?.cast<int>(),
      favouritePlaces: (fields[9] as List)?.cast<int>(),
      purchasedTrips: (fields[10] as List)?.cast<int>(),
      purchasedPlaces: (fields[11] as List)?.cast<int>(),
      downloadedTrips: (fields[12] as List)?.cast<int>(),
      downloadedPlaces: (fields[13] as List)?.cast<int>(),
      onlyNearest: fields[14] as bool,
      onlyFavourites: fields[15] as bool,
      onlyPurchased: fields[16] as bool,
      createdAt: fields[17] as DateTime,
      updatedAt: fields[18] as DateTime,
    )
      ..imageOrigin = fields[5] as FileOrigin
      ..needSync = fields[19] as bool;
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.firstName)
      ..writeByte(3)
      ..write(obj.lastName)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.imageOrigin)
      ..writeByte(6)
      ..write(obj.selectedLanguages)
      ..writeByte(7)
      ..write(obj.about)
      ..writeByte(8)
      ..write(obj.favouriteTrips)
      ..writeByte(9)
      ..write(obj.favouritePlaces)
      ..writeByte(10)
      ..write(obj.purchasedTrips)
      ..writeByte(11)
      ..write(obj.purchasedPlaces)
      ..writeByte(12)
      ..write(obj.downloadedTrips)
      ..writeByte(13)
      ..write(obj.downloadedPlaces)
      ..writeByte(14)
      ..write(obj.onlyNearest)
      ..writeByte(15)
      ..write(obj.onlyFavourites)
      ..writeByte(16)
      ..write(obj.onlyPurchased)
      ..writeByte(17)
      ..write(obj.createdAt)
      ..writeByte(18)
      ..write(obj.updatedAt)
      ..writeByte(19)
      ..write(obj.needSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
