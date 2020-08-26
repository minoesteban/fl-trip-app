// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart-item.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartItemAdapter extends TypeAdapter<CartItem> {
  @override
  final int typeId = 7;

  @override
  CartItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartItem(
      fields[2] as Trip,
      fields[3] as Place,
      fields[4] as double,
    )
      ..id = fields[0] as String
      ..isTrip = fields[1] as bool
      ..createdAt = fields[5] as DateTime;
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.isTrip)
      ..writeByte(2)
      ..write(obj.trip)
      ..writeByte(3)
      ..write(obj.place)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
