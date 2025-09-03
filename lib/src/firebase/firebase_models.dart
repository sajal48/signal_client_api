/// Firebase data models for Signal Protocol
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'firebase_models.freezed.dart';
part 'firebase_models.g.dart';

/// User's public identity key stored in Firebase
@freezed
class FirebaseIdentityKey with _$FirebaseIdentityKey {
  const factory FirebaseIdentityKey({
    required String publicKey, // Base64 encoded public key
    required int timestamp,
    required String deviceId,
  }) = _FirebaseIdentityKey;

  factory FirebaseIdentityKey.fromJson(Map<String, dynamic> json) =>
      _$FirebaseIdentityKeyFromJson(json);
}

/// User's registration ID stored in Firebase
@freezed
class FirebaseRegistrationId with _$FirebaseRegistrationId {
  const factory FirebaseRegistrationId({
    required int registrationId,
    required int timestamp,
    required String deviceId,
  }) = _FirebaseRegistrationId;

  factory FirebaseRegistrationId.fromJson(Map<String, dynamic> json) =>
      _$FirebaseRegistrationIdFromJson(json);
}

/// PreKey bundle stored in Firebase
@freezed
class FirebasePreKey with _$FirebasePreKey {
  const factory FirebasePreKey({
    required int preKeyId,
    required String publicKey, // Base64 encoded public key
    required int timestamp,
    required String deviceId,
    required bool isActive,
  }) = _FirebasePreKey;

  factory FirebasePreKey.fromJson(Map<String, dynamic> json) =>
      _$FirebasePreKeyFromJson(json);
}

/// Signed PreKey stored in Firebase
@freezed
class FirebaseSignedPreKey with _$FirebaseSignedPreKey {
  const factory FirebaseSignedPreKey({
    required int signedPreKeyId,
    required String publicKey, // Base64 encoded public key
    required String signature, // Base64 encoded signature
    required int timestamp,
    required String deviceId,
    required bool isActive,
  }) = _FirebaseSignedPreKey;

  factory FirebaseSignedPreKey.fromJson(Map<String, dynamic> json) =>
      _$FirebaseSignedPreKeyFromJson(json);
}

/// Group sender key stored in Firebase
@freezed
class FirebaseSenderKey with _$FirebaseSenderKey {
  const factory FirebaseSenderKey({
    required String groupId,
    required String senderKeyData, // Base64 encoded sender key
    required int timestamp,
    required String deviceId,
    required bool isActive,
  }) = _FirebaseSenderKey;

  factory FirebaseSenderKey.fromJson(Map<String, dynamic> json) =>
      _$FirebaseSenderKeyFromJson(json);
}

/// User metadata stored in Firebase
@freezed
class FirebaseUserMetadata with _$FirebaseUserMetadata {
  const factory FirebaseUserMetadata({
    required String userId,
    required String deviceId,
    required int lastUpdated,
    required int keysVersion,
    String? displayName,
    Map<String, dynamic>? customData,
  }) = _FirebaseUserMetadata;

  factory FirebaseUserMetadata.fromJson(Map<String, dynamic> json) =>
      _$FirebaseUserMetadataFromJson(json);
}

/// Complete user key bundle for key exchange
@freezed
class FirebaseKeyBundle with _$FirebaseKeyBundle {
  const factory FirebaseKeyBundle({
    required String userId,
    required String deviceId,
    required FirebaseIdentityKey identityKey,
    required FirebaseRegistrationId registrationId,
    required FirebaseSignedPreKey signedPreKey,
    required List<FirebasePreKey> preKeys,
    required FirebaseUserMetadata metadata,
  }) = _FirebaseKeyBundle;

  factory FirebaseKeyBundle.fromJson(Map<String, dynamic> json) =>
      _$FirebaseKeyBundleFromJson(json);
}

/// Firebase sync event for real-time updates
@freezed
class FirebaseSyncEvent with _$FirebaseSyncEvent {
  const factory FirebaseSyncEvent({
    required String eventType, // 'key_updated', 'key_deleted', 'user_offline'
    required String userId,
    required String deviceId,
    required int timestamp,
    String? keyType, // 'identity', 'prekey', 'signed_prekey', 'sender_key'
    String? keyId,
    Map<String, dynamic>? data,
  }) = _FirebaseSyncEvent;

  factory FirebaseSyncEvent.fromJson(Map<String, dynamic> json) =>
      _$FirebaseSyncEventFromJson(json);
}
