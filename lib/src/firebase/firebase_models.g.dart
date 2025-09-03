// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FirebaseIdentityKeyImpl _$$FirebaseIdentityKeyImplFromJson(
        Map<String, dynamic> json) =>
    _$FirebaseIdentityKeyImpl(
      publicKey: json['publicKey'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      deviceId: json['deviceId'] as String,
    );

Map<String, dynamic> _$$FirebaseIdentityKeyImplToJson(
        _$FirebaseIdentityKeyImpl instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
      'timestamp': instance.timestamp,
      'deviceId': instance.deviceId,
    };

_$FirebaseRegistrationIdImpl _$$FirebaseRegistrationIdImplFromJson(
        Map<String, dynamic> json) =>
    _$FirebaseRegistrationIdImpl(
      registrationId: (json['registrationId'] as num).toInt(),
      timestamp: (json['timestamp'] as num).toInt(),
      deviceId: json['deviceId'] as String,
    );

Map<String, dynamic> _$$FirebaseRegistrationIdImplToJson(
        _$FirebaseRegistrationIdImpl instance) =>
    <String, dynamic>{
      'registrationId': instance.registrationId,
      'timestamp': instance.timestamp,
      'deviceId': instance.deviceId,
    };

_$FirebasePreKeyImpl _$$FirebasePreKeyImplFromJson(Map<String, dynamic> json) =>
    _$FirebasePreKeyImpl(
      preKeyId: (json['preKeyId'] as num).toInt(),
      publicKey: json['publicKey'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      deviceId: json['deviceId'] as String,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$$FirebasePreKeyImplToJson(
        _$FirebasePreKeyImpl instance) =>
    <String, dynamic>{
      'preKeyId': instance.preKeyId,
      'publicKey': instance.publicKey,
      'timestamp': instance.timestamp,
      'deviceId': instance.deviceId,
      'isActive': instance.isActive,
    };

_$FirebaseSignedPreKeyImpl _$$FirebaseSignedPreKeyImplFromJson(
        Map<String, dynamic> json) =>
    _$FirebaseSignedPreKeyImpl(
      signedPreKeyId: (json['signedPreKeyId'] as num).toInt(),
      publicKey: json['publicKey'] as String,
      signature: json['signature'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      deviceId: json['deviceId'] as String,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$$FirebaseSignedPreKeyImplToJson(
        _$FirebaseSignedPreKeyImpl instance) =>
    <String, dynamic>{
      'signedPreKeyId': instance.signedPreKeyId,
      'publicKey': instance.publicKey,
      'signature': instance.signature,
      'timestamp': instance.timestamp,
      'deviceId': instance.deviceId,
      'isActive': instance.isActive,
    };

_$FirebaseSenderKeyImpl _$$FirebaseSenderKeyImplFromJson(
        Map<String, dynamic> json) =>
    _$FirebaseSenderKeyImpl(
      groupId: json['groupId'] as String,
      senderKeyData: json['senderKeyData'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      deviceId: json['deviceId'] as String,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$$FirebaseSenderKeyImplToJson(
        _$FirebaseSenderKeyImpl instance) =>
    <String, dynamic>{
      'groupId': instance.groupId,
      'senderKeyData': instance.senderKeyData,
      'timestamp': instance.timestamp,
      'deviceId': instance.deviceId,
      'isActive': instance.isActive,
    };

_$FirebaseUserMetadataImpl _$$FirebaseUserMetadataImplFromJson(
        Map<String, dynamic> json) =>
    _$FirebaseUserMetadataImpl(
      userId: json['userId'] as String,
      deviceId: json['deviceId'] as String,
      lastUpdated: (json['lastUpdated'] as num).toInt(),
      keysVersion: (json['keysVersion'] as num).toInt(),
      displayName: json['displayName'] as String?,
      customData: json['customData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$FirebaseUserMetadataImplToJson(
        _$FirebaseUserMetadataImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'deviceId': instance.deviceId,
      'lastUpdated': instance.lastUpdated,
      'keysVersion': instance.keysVersion,
      'displayName': instance.displayName,
      'customData': instance.customData,
    };

_$FirebaseKeyBundleImpl _$$FirebaseKeyBundleImplFromJson(
        Map<String, dynamic> json) =>
    _$FirebaseKeyBundleImpl(
      userId: json['userId'] as String,
      deviceId: json['deviceId'] as String,
      identityKey: FirebaseIdentityKey.fromJson(
          json['identityKey'] as Map<String, dynamic>),
      registrationId: FirebaseRegistrationId.fromJson(
          json['registrationId'] as Map<String, dynamic>),
      signedPreKey: FirebaseSignedPreKey.fromJson(
          json['signedPreKey'] as Map<String, dynamic>),
      preKeys: (json['preKeys'] as List<dynamic>)
          .map((e) => FirebasePreKey.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: FirebaseUserMetadata.fromJson(
          json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$FirebaseKeyBundleImplToJson(
        _$FirebaseKeyBundleImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'deviceId': instance.deviceId,
      'identityKey': instance.identityKey,
      'registrationId': instance.registrationId,
      'signedPreKey': instance.signedPreKey,
      'preKeys': instance.preKeys,
      'metadata': instance.metadata,
    };

_$FirebaseSyncEventImpl _$$FirebaseSyncEventImplFromJson(
        Map<String, dynamic> json) =>
    _$FirebaseSyncEventImpl(
      eventType: json['eventType'] as String,
      userId: json['userId'] as String,
      deviceId: json['deviceId'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      keyType: json['keyType'] as String?,
      keyId: json['keyId'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$FirebaseSyncEventImplToJson(
        _$FirebaseSyncEventImpl instance) =>
    <String, dynamic>{
      'eventType': instance.eventType,
      'userId': instance.userId,
      'deviceId': instance.deviceId,
      'timestamp': instance.timestamp,
      'keyType': instance.keyType,
      'keyId': instance.keyId,
      'data': instance.data,
    };
