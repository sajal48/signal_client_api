// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveSessionRecordAdapter extends TypeAdapter<HiveSessionRecord> {
  @override
  final int typeId = 0;

  @override
  HiveSessionRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveSessionRecord(
      address: fields[0] as String,
      sessionData: fields[1] as Uint8List,
      lastUsed: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HiveSessionRecord obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.address)
      ..writeByte(1)
      ..write(obj.sessionData)
      ..writeByte(2)
      ..write(obj.lastUsed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveSessionRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HivePreKeyRecordAdapter extends TypeAdapter<HivePreKeyRecord> {
  @override
  final int typeId = 1;

  @override
  HivePreKeyRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HivePreKeyRecord(
      id: fields[0] as int,
      keyData: fields[1] as Uint8List,
      created: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HivePreKeyRecord obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.keyData)
      ..writeByte(2)
      ..write(obj.created);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HivePreKeyRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveSignedPreKeyRecordAdapter
    extends TypeAdapter<HiveSignedPreKeyRecord> {
  @override
  final int typeId = 2;

  @override
  HiveSignedPreKeyRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveSignedPreKeyRecord(
      id: fields[0] as int,
      keyData: fields[1] as Uint8List,
      signature: fields[2] as Uint8List,
      created: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HiveSignedPreKeyRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.keyData)
      ..writeByte(2)
      ..write(obj.signature)
      ..writeByte(3)
      ..write(obj.created);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveSignedPreKeyRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveSenderKeyRecordAdapter extends TypeAdapter<HiveSenderKeyRecord> {
  @override
  final int typeId = 3;

  @override
  HiveSenderKeyRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveSenderKeyRecord(
      groupId: fields[0] as String,
      senderId: fields[1] as String,
      keyData: fields[2] as Uint8List,
      created: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HiveSenderKeyRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.groupId)
      ..writeByte(1)
      ..write(obj.senderId)
      ..writeByte(2)
      ..write(obj.keyData)
      ..writeByte(3)
      ..write(obj.created);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveSenderKeyRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CachedUserKeysAdapter extends TypeAdapter<CachedUserKeys> {
  @override
  final int typeId = 4;

  @override
  CachedUserKeys read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedUserKeys(
      userId: fields[0] as String,
      deviceId: fields[1] as String,
      keyBundle: (fields[2] as Map).cast<String, dynamic>(),
      lastSynced: fields[3] as DateTime,
      version: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CachedUserKeys obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.deviceId)
      ..writeByte(2)
      ..write(obj.keyBundle)
      ..writeByte(3)
      ..write(obj.lastSynced)
      ..writeByte(4)
      ..write(obj.version);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedUserKeysAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
