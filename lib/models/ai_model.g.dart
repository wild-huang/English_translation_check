// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AIModelAdapter extends TypeAdapter<AIModel> {
  @override
  final typeId = 1;

  @override
  AIModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AIModel(
      id: fields[0] as String,
      providerId: fields[1] as String,
      name: fields[2] as String,
      displayName: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AIModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.providerId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.displayName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
