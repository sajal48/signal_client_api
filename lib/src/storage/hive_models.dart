import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'hive_models.g.dart';

/// Hive model for session storage
@HiveType(typeId: 0)
class HiveSessionRecord extends HiveObject {
  @HiveField(0)
  late String address;
  
  @HiveField(1)
  late Uint8List sessionData;
  
  @HiveField(2)
  late DateTime lastUsed;
  
  HiveSessionRecord({
    required this.address,
    required this.sessionData,
    required this.lastUsed,
  });
  
  HiveSessionRecord.empty();
}

/// Hive model for PreKey storage
@HiveType(typeId: 1)
class HivePreKeyRecord extends HiveObject {
  @HiveField(0)
  late int id;
  
  @HiveField(1)
  late Uint8List keyData;
  
  @HiveField(2)
  late DateTime created;
  
  HivePreKeyRecord({
    required this.id,
    required this.keyData,
    required this.created,
  });
  
  HivePreKeyRecord.empty();
}

/// Hive model for signed PreKey storage
@HiveType(typeId: 2)
class HiveSignedPreKeyRecord extends HiveObject {
  @HiveField(0)
  late int id;
  
  @HiveField(1)
  late Uint8List keyData;
  
  @HiveField(2)
  late Uint8List signature;
  
  @HiveField(3)
  late DateTime created;
  
  HiveSignedPreKeyRecord({
    required this.id,
    required this.keyData,
    required this.signature,
    required this.created,
  });
  
  HiveSignedPreKeyRecord.empty();
}

/// Hive model for sender key storage (group messaging)
@HiveType(typeId: 3)
class HiveSenderKeyRecord extends HiveObject {
  @HiveField(0)
  late String groupId;
  
  @HiveField(1)
  late String senderId;
  
  @HiveField(2)
  late Uint8List keyData;
  
  @HiveField(3)
  late DateTime created;
  
  HiveSenderKeyRecord({
    required this.groupId,
    required this.senderId,
    required this.keyData,
    required this.created,
  });
  
  HiveSenderKeyRecord.empty();
}

/// Hive model for cached Firebase keys
@HiveType(typeId: 4)
class CachedUserKeys extends HiveObject {
  @HiveField(0)
  late String userId;
  
  @HiveField(1)
  late String deviceId;
  
  @HiveField(2)
  late Map<String, dynamic> keyBundle;
  
  @HiveField(3)
  late DateTime lastSynced;
  
  @HiveField(4)
  late int version;
  
  CachedUserKeys({
    required this.userId,
    required this.deviceId,
    required this.keyBundle,
    required this.lastSynced,
    this.version = 1,
  });
  
  CachedUserKeys.empty();
}
