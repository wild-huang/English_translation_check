// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProviderModelAdapter extends TypeAdapter<ProviderModel> {
  @override
  final typeId = 0;

  @override
  ProviderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProviderModel(
      id: fields[0] as String,
      name: fields[1] as String,
      apiFormat: fields[2] as String,
      endpoint: fields[3] as String,
      apiKey: fields[4] as String,
      isPreset: fields[5] == null ? false : fields[5] as bool,
      apiPath: fields[6] == null ? '/chat/completions' : fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProviderModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.apiFormat)
      ..writeByte(3)
      ..write(obj.endpoint)
      ..writeByte(4)
      ..write(obj.apiKey)
      ..writeByte(5)
      ..write(obj.isPreset)
      ..writeByte(6)
      ..write(obj.apiPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
