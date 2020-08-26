// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utils.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FileOriginAdapter extends TypeAdapter<FileOrigin> {
  @override
  final int typeId = 5;

  @override
  FileOrigin read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FileOrigin.Local;
      case 1:
        return FileOrigin.Network;
      default:
        return null;
    }
  }

  @override
  void write(BinaryWriter writer, FileOrigin obj) {
    switch (obj) {
      case FileOrigin.Local:
        writer.writeByte(0);
        break;
      case FileOrigin.Network:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileOriginAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CoordinatesAdapter extends TypeAdapter<Coordinates> {
  @override
  final int typeId = 8;

  @override
  Coordinates read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Coordinates(
      fields[0] as double,
      fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Coordinates obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoordinatesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
