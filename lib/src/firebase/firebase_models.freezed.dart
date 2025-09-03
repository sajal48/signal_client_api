// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'firebase_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FirebaseIdentityKey _$FirebaseIdentityKeyFromJson(Map<String, dynamic> json) {
  return _FirebaseIdentityKey.fromJson(json);
}

/// @nodoc
mixin _$FirebaseIdentityKey {
  String get publicKey =>
      throw _privateConstructorUsedError; // Base64 encoded public key
  int get timestamp => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;

  /// Serializes this FirebaseIdentityKey to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FirebaseIdentityKey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FirebaseIdentityKeyCopyWith<FirebaseIdentityKey> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FirebaseIdentityKeyCopyWith<$Res> {
  factory $FirebaseIdentityKeyCopyWith(
          FirebaseIdentityKey value, $Res Function(FirebaseIdentityKey) then) =
      _$FirebaseIdentityKeyCopyWithImpl<$Res, FirebaseIdentityKey>;
  @useResult
  $Res call({String publicKey, int timestamp, String deviceId});
}

/// @nodoc
class _$FirebaseIdentityKeyCopyWithImpl<$Res, $Val extends FirebaseIdentityKey>
    implements $FirebaseIdentityKeyCopyWith<$Res> {
  _$FirebaseIdentityKeyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FirebaseIdentityKey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicKey = null,
    Object? timestamp = null,
    Object? deviceId = null,
  }) {
    return _then(_value.copyWith(
      publicKey: null == publicKey
          ? _value.publicKey
          : publicKey // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FirebaseIdentityKeyImplCopyWith<$Res>
    implements $FirebaseIdentityKeyCopyWith<$Res> {
  factory _$$FirebaseIdentityKeyImplCopyWith(_$FirebaseIdentityKeyImpl value,
          $Res Function(_$FirebaseIdentityKeyImpl) then) =
      __$$FirebaseIdentityKeyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String publicKey, int timestamp, String deviceId});
}

/// @nodoc
class __$$FirebaseIdentityKeyImplCopyWithImpl<$Res>
    extends _$FirebaseIdentityKeyCopyWithImpl<$Res, _$FirebaseIdentityKeyImpl>
    implements _$$FirebaseIdentityKeyImplCopyWith<$Res> {
  __$$FirebaseIdentityKeyImplCopyWithImpl(_$FirebaseIdentityKeyImpl _value,
      $Res Function(_$FirebaseIdentityKeyImpl) _then)
      : super(_value, _then);

  /// Create a copy of FirebaseIdentityKey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicKey = null,
    Object? timestamp = null,
    Object? deviceId = null,
  }) {
    return _then(_$FirebaseIdentityKeyImpl(
      publicKey: null == publicKey
          ? _value.publicKey
          : publicKey // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FirebaseIdentityKeyImpl implements _FirebaseIdentityKey {
  const _$FirebaseIdentityKeyImpl(
      {required this.publicKey,
      required this.timestamp,
      required this.deviceId});

  factory _$FirebaseIdentityKeyImpl.fromJson(Map<String, dynamic> json) =>
      _$$FirebaseIdentityKeyImplFromJson(json);

  @override
  final String publicKey;
// Base64 encoded public key
  @override
  final int timestamp;
  @override
  final String deviceId;

  @override
  String toString() {
    return 'FirebaseIdentityKey(publicKey: $publicKey, timestamp: $timestamp, deviceId: $deviceId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirebaseIdentityKeyImpl &&
            (identical(other.publicKey, publicKey) ||
                other.publicKey == publicKey) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, publicKey, timestamp, deviceId);

  /// Create a copy of FirebaseIdentityKey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FirebaseIdentityKeyImplCopyWith<_$FirebaseIdentityKeyImpl> get copyWith =>
      __$$FirebaseIdentityKeyImplCopyWithImpl<_$FirebaseIdentityKeyImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FirebaseIdentityKeyImplToJson(
      this,
    );
  }
}

abstract class _FirebaseIdentityKey implements FirebaseIdentityKey {
  const factory _FirebaseIdentityKey(
      {required final String publicKey,
      required final int timestamp,
      required final String deviceId}) = _$FirebaseIdentityKeyImpl;

  factory _FirebaseIdentityKey.fromJson(Map<String, dynamic> json) =
      _$FirebaseIdentityKeyImpl.fromJson;

  @override
  String get publicKey; // Base64 encoded public key
  @override
  int get timestamp;
  @override
  String get deviceId;

  /// Create a copy of FirebaseIdentityKey
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FirebaseIdentityKeyImplCopyWith<_$FirebaseIdentityKeyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FirebaseRegistrationId _$FirebaseRegistrationIdFromJson(
    Map<String, dynamic> json) {
  return _FirebaseRegistrationId.fromJson(json);
}

/// @nodoc
mixin _$FirebaseRegistrationId {
  int get registrationId => throw _privateConstructorUsedError;
  int get timestamp => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;

  /// Serializes this FirebaseRegistrationId to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FirebaseRegistrationId
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FirebaseRegistrationIdCopyWith<FirebaseRegistrationId> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FirebaseRegistrationIdCopyWith<$Res> {
  factory $FirebaseRegistrationIdCopyWith(FirebaseRegistrationId value,
          $Res Function(FirebaseRegistrationId) then) =
      _$FirebaseRegistrationIdCopyWithImpl<$Res, FirebaseRegistrationId>;
  @useResult
  $Res call({int registrationId, int timestamp, String deviceId});
}

/// @nodoc
class _$FirebaseRegistrationIdCopyWithImpl<$Res,
        $Val extends FirebaseRegistrationId>
    implements $FirebaseRegistrationIdCopyWith<$Res> {
  _$FirebaseRegistrationIdCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FirebaseRegistrationId
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? registrationId = null,
    Object? timestamp = null,
    Object? deviceId = null,
  }) {
    return _then(_value.copyWith(
      registrationId: null == registrationId
          ? _value.registrationId
          : registrationId // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FirebaseRegistrationIdImplCopyWith<$Res>
    implements $FirebaseRegistrationIdCopyWith<$Res> {
  factory _$$FirebaseRegistrationIdImplCopyWith(
          _$FirebaseRegistrationIdImpl value,
          $Res Function(_$FirebaseRegistrationIdImpl) then) =
      __$$FirebaseRegistrationIdImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int registrationId, int timestamp, String deviceId});
}

/// @nodoc
class __$$FirebaseRegistrationIdImplCopyWithImpl<$Res>
    extends _$FirebaseRegistrationIdCopyWithImpl<$Res,
        _$FirebaseRegistrationIdImpl>
    implements _$$FirebaseRegistrationIdImplCopyWith<$Res> {
  __$$FirebaseRegistrationIdImplCopyWithImpl(
      _$FirebaseRegistrationIdImpl _value,
      $Res Function(_$FirebaseRegistrationIdImpl) _then)
      : super(_value, _then);

  /// Create a copy of FirebaseRegistrationId
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? registrationId = null,
    Object? timestamp = null,
    Object? deviceId = null,
  }) {
    return _then(_$FirebaseRegistrationIdImpl(
      registrationId: null == registrationId
          ? _value.registrationId
          : registrationId // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FirebaseRegistrationIdImpl implements _FirebaseRegistrationId {
  const _$FirebaseRegistrationIdImpl(
      {required this.registrationId,
      required this.timestamp,
      required this.deviceId});

  factory _$FirebaseRegistrationIdImpl.fromJson(Map<String, dynamic> json) =>
      _$$FirebaseRegistrationIdImplFromJson(json);

  @override
  final int registrationId;
  @override
  final int timestamp;
  @override
  final String deviceId;

  @override
  String toString() {
    return 'FirebaseRegistrationId(registrationId: $registrationId, timestamp: $timestamp, deviceId: $deviceId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirebaseRegistrationIdImpl &&
            (identical(other.registrationId, registrationId) ||
                other.registrationId == registrationId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, registrationId, timestamp, deviceId);

  /// Create a copy of FirebaseRegistrationId
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FirebaseRegistrationIdImplCopyWith<_$FirebaseRegistrationIdImpl>
      get copyWith => __$$FirebaseRegistrationIdImplCopyWithImpl<
          _$FirebaseRegistrationIdImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FirebaseRegistrationIdImplToJson(
      this,
    );
  }
}

abstract class _FirebaseRegistrationId implements FirebaseRegistrationId {
  const factory _FirebaseRegistrationId(
      {required final int registrationId,
      required final int timestamp,
      required final String deviceId}) = _$FirebaseRegistrationIdImpl;

  factory _FirebaseRegistrationId.fromJson(Map<String, dynamic> json) =
      _$FirebaseRegistrationIdImpl.fromJson;

  @override
  int get registrationId;
  @override
  int get timestamp;
  @override
  String get deviceId;

  /// Create a copy of FirebaseRegistrationId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FirebaseRegistrationIdImplCopyWith<_$FirebaseRegistrationIdImpl>
      get copyWith => throw _privateConstructorUsedError;
}

FirebasePreKey _$FirebasePreKeyFromJson(Map<String, dynamic> json) {
  return _FirebasePreKey.fromJson(json);
}

/// @nodoc
mixin _$FirebasePreKey {
  int get preKeyId => throw _privateConstructorUsedError;
  String get publicKey =>
      throw _privateConstructorUsedError; // Base64 encoded public key
  int get timestamp => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this FirebasePreKey to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FirebasePreKey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FirebasePreKeyCopyWith<FirebasePreKey> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FirebasePreKeyCopyWith<$Res> {
  factory $FirebasePreKeyCopyWith(
          FirebasePreKey value, $Res Function(FirebasePreKey) then) =
      _$FirebasePreKeyCopyWithImpl<$Res, FirebasePreKey>;
  @useResult
  $Res call(
      {int preKeyId,
      String publicKey,
      int timestamp,
      String deviceId,
      bool isActive});
}

/// @nodoc
class _$FirebasePreKeyCopyWithImpl<$Res, $Val extends FirebasePreKey>
    implements $FirebasePreKeyCopyWith<$Res> {
  _$FirebasePreKeyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FirebasePreKey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? preKeyId = null,
    Object? publicKey = null,
    Object? timestamp = null,
    Object? deviceId = null,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      preKeyId: null == preKeyId
          ? _value.preKeyId
          : preKeyId // ignore: cast_nullable_to_non_nullable
              as int,
      publicKey: null == publicKey
          ? _value.publicKey
          : publicKey // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FirebasePreKeyImplCopyWith<$Res>
    implements $FirebasePreKeyCopyWith<$Res> {
  factory _$$FirebasePreKeyImplCopyWith(_$FirebasePreKeyImpl value,
          $Res Function(_$FirebasePreKeyImpl) then) =
      __$$FirebasePreKeyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int preKeyId,
      String publicKey,
      int timestamp,
      String deviceId,
      bool isActive});
}

/// @nodoc
class __$$FirebasePreKeyImplCopyWithImpl<$Res>
    extends _$FirebasePreKeyCopyWithImpl<$Res, _$FirebasePreKeyImpl>
    implements _$$FirebasePreKeyImplCopyWith<$Res> {
  __$$FirebasePreKeyImplCopyWithImpl(
      _$FirebasePreKeyImpl _value, $Res Function(_$FirebasePreKeyImpl) _then)
      : super(_value, _then);

  /// Create a copy of FirebasePreKey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? preKeyId = null,
    Object? publicKey = null,
    Object? timestamp = null,
    Object? deviceId = null,
    Object? isActive = null,
  }) {
    return _then(_$FirebasePreKeyImpl(
      preKeyId: null == preKeyId
          ? _value.preKeyId
          : preKeyId // ignore: cast_nullable_to_non_nullable
              as int,
      publicKey: null == publicKey
          ? _value.publicKey
          : publicKey // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FirebasePreKeyImpl implements _FirebasePreKey {
  const _$FirebasePreKeyImpl(
      {required this.preKeyId,
      required this.publicKey,
      required this.timestamp,
      required this.deviceId,
      required this.isActive});

  factory _$FirebasePreKeyImpl.fromJson(Map<String, dynamic> json) =>
      _$$FirebasePreKeyImplFromJson(json);

  @override
  final int preKeyId;
  @override
  final String publicKey;
// Base64 encoded public key
  @override
  final int timestamp;
  @override
  final String deviceId;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'FirebasePreKey(preKeyId: $preKeyId, publicKey: $publicKey, timestamp: $timestamp, deviceId: $deviceId, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirebasePreKeyImpl &&
            (identical(other.preKeyId, preKeyId) ||
                other.preKeyId == preKeyId) &&
            (identical(other.publicKey, publicKey) ||
                other.publicKey == publicKey) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, preKeyId, publicKey, timestamp, deviceId, isActive);

  /// Create a copy of FirebasePreKey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FirebasePreKeyImplCopyWith<_$FirebasePreKeyImpl> get copyWith =>
      __$$FirebasePreKeyImplCopyWithImpl<_$FirebasePreKeyImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FirebasePreKeyImplToJson(
      this,
    );
  }
}

abstract class _FirebasePreKey implements FirebasePreKey {
  const factory _FirebasePreKey(
      {required final int preKeyId,
      required final String publicKey,
      required final int timestamp,
      required final String deviceId,
      required final bool isActive}) = _$FirebasePreKeyImpl;

  factory _FirebasePreKey.fromJson(Map<String, dynamic> json) =
      _$FirebasePreKeyImpl.fromJson;

  @override
  int get preKeyId;
  @override
  String get publicKey; // Base64 encoded public key
  @override
  int get timestamp;
  @override
  String get deviceId;
  @override
  bool get isActive;

  /// Create a copy of FirebasePreKey
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FirebasePreKeyImplCopyWith<_$FirebasePreKeyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FirebaseSignedPreKey _$FirebaseSignedPreKeyFromJson(Map<String, dynamic> json) {
  return _FirebaseSignedPreKey.fromJson(json);
}

/// @nodoc
mixin _$FirebaseSignedPreKey {
  int get signedPreKeyId => throw _privateConstructorUsedError;
  String get publicKey =>
      throw _privateConstructorUsedError; // Base64 encoded public key
  String get signature =>
      throw _privateConstructorUsedError; // Base64 encoded signature
  int get timestamp => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this FirebaseSignedPreKey to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FirebaseSignedPreKey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FirebaseSignedPreKeyCopyWith<FirebaseSignedPreKey> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FirebaseSignedPreKeyCopyWith<$Res> {
  factory $FirebaseSignedPreKeyCopyWith(FirebaseSignedPreKey value,
          $Res Function(FirebaseSignedPreKey) then) =
      _$FirebaseSignedPreKeyCopyWithImpl<$Res, FirebaseSignedPreKey>;
  @useResult
  $Res call(
      {int signedPreKeyId,
      String publicKey,
      String signature,
      int timestamp,
      String deviceId,
      bool isActive});
}

/// @nodoc
class _$FirebaseSignedPreKeyCopyWithImpl<$Res,
        $Val extends FirebaseSignedPreKey>
    implements $FirebaseSignedPreKeyCopyWith<$Res> {
  _$FirebaseSignedPreKeyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FirebaseSignedPreKey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? signedPreKeyId = null,
    Object? publicKey = null,
    Object? signature = null,
    Object? timestamp = null,
    Object? deviceId = null,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      signedPreKeyId: null == signedPreKeyId
          ? _value.signedPreKeyId
          : signedPreKeyId // ignore: cast_nullable_to_non_nullable
              as int,
      publicKey: null == publicKey
          ? _value.publicKey
          : publicKey // ignore: cast_nullable_to_non_nullable
              as String,
      signature: null == signature
          ? _value.signature
          : signature // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FirebaseSignedPreKeyImplCopyWith<$Res>
    implements $FirebaseSignedPreKeyCopyWith<$Res> {
  factory _$$FirebaseSignedPreKeyImplCopyWith(_$FirebaseSignedPreKeyImpl value,
          $Res Function(_$FirebaseSignedPreKeyImpl) then) =
      __$$FirebaseSignedPreKeyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int signedPreKeyId,
      String publicKey,
      String signature,
      int timestamp,
      String deviceId,
      bool isActive});
}

/// @nodoc
class __$$FirebaseSignedPreKeyImplCopyWithImpl<$Res>
    extends _$FirebaseSignedPreKeyCopyWithImpl<$Res, _$FirebaseSignedPreKeyImpl>
    implements _$$FirebaseSignedPreKeyImplCopyWith<$Res> {
  __$$FirebaseSignedPreKeyImplCopyWithImpl(_$FirebaseSignedPreKeyImpl _value,
      $Res Function(_$FirebaseSignedPreKeyImpl) _then)
      : super(_value, _then);

  /// Create a copy of FirebaseSignedPreKey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? signedPreKeyId = null,
    Object? publicKey = null,
    Object? signature = null,
    Object? timestamp = null,
    Object? deviceId = null,
    Object? isActive = null,
  }) {
    return _then(_$FirebaseSignedPreKeyImpl(
      signedPreKeyId: null == signedPreKeyId
          ? _value.signedPreKeyId
          : signedPreKeyId // ignore: cast_nullable_to_non_nullable
              as int,
      publicKey: null == publicKey
          ? _value.publicKey
          : publicKey // ignore: cast_nullable_to_non_nullable
              as String,
      signature: null == signature
          ? _value.signature
          : signature // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FirebaseSignedPreKeyImpl implements _FirebaseSignedPreKey {
  const _$FirebaseSignedPreKeyImpl(
      {required this.signedPreKeyId,
      required this.publicKey,
      required this.signature,
      required this.timestamp,
      required this.deviceId,
      required this.isActive});

  factory _$FirebaseSignedPreKeyImpl.fromJson(Map<String, dynamic> json) =>
      _$$FirebaseSignedPreKeyImplFromJson(json);

  @override
  final int signedPreKeyId;
  @override
  final String publicKey;
// Base64 encoded public key
  @override
  final String signature;
// Base64 encoded signature
  @override
  final int timestamp;
  @override
  final String deviceId;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'FirebaseSignedPreKey(signedPreKeyId: $signedPreKeyId, publicKey: $publicKey, signature: $signature, timestamp: $timestamp, deviceId: $deviceId, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirebaseSignedPreKeyImpl &&
            (identical(other.signedPreKeyId, signedPreKeyId) ||
                other.signedPreKeyId == signedPreKeyId) &&
            (identical(other.publicKey, publicKey) ||
                other.publicKey == publicKey) &&
            (identical(other.signature, signature) ||
                other.signature == signature) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, signedPreKeyId, publicKey,
      signature, timestamp, deviceId, isActive);

  /// Create a copy of FirebaseSignedPreKey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FirebaseSignedPreKeyImplCopyWith<_$FirebaseSignedPreKeyImpl>
      get copyWith =>
          __$$FirebaseSignedPreKeyImplCopyWithImpl<_$FirebaseSignedPreKeyImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FirebaseSignedPreKeyImplToJson(
      this,
    );
  }
}

abstract class _FirebaseSignedPreKey implements FirebaseSignedPreKey {
  const factory _FirebaseSignedPreKey(
      {required final int signedPreKeyId,
      required final String publicKey,
      required final String signature,
      required final int timestamp,
      required final String deviceId,
      required final bool isActive}) = _$FirebaseSignedPreKeyImpl;

  factory _FirebaseSignedPreKey.fromJson(Map<String, dynamic> json) =
      _$FirebaseSignedPreKeyImpl.fromJson;

  @override
  int get signedPreKeyId;
  @override
  String get publicKey; // Base64 encoded public key
  @override
  String get signature; // Base64 encoded signature
  @override
  int get timestamp;
  @override
  String get deviceId;
  @override
  bool get isActive;

  /// Create a copy of FirebaseSignedPreKey
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FirebaseSignedPreKeyImplCopyWith<_$FirebaseSignedPreKeyImpl>
      get copyWith => throw _privateConstructorUsedError;
}

FirebaseSenderKey _$FirebaseSenderKeyFromJson(Map<String, dynamic> json) {
  return _FirebaseSenderKey.fromJson(json);
}

/// @nodoc
mixin _$FirebaseSenderKey {
  String get groupId => throw _privateConstructorUsedError;
  String get senderKeyData =>
      throw _privateConstructorUsedError; // Base64 encoded sender key
  int get timestamp => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this FirebaseSenderKey to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FirebaseSenderKey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FirebaseSenderKeyCopyWith<FirebaseSenderKey> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FirebaseSenderKeyCopyWith<$Res> {
  factory $FirebaseSenderKeyCopyWith(
          FirebaseSenderKey value, $Res Function(FirebaseSenderKey) then) =
      _$FirebaseSenderKeyCopyWithImpl<$Res, FirebaseSenderKey>;
  @useResult
  $Res call(
      {String groupId,
      String senderKeyData,
      int timestamp,
      String deviceId,
      bool isActive});
}

/// @nodoc
class _$FirebaseSenderKeyCopyWithImpl<$Res, $Val extends FirebaseSenderKey>
    implements $FirebaseSenderKeyCopyWith<$Res> {
  _$FirebaseSenderKeyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FirebaseSenderKey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupId = null,
    Object? senderKeyData = null,
    Object? timestamp = null,
    Object? deviceId = null,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      senderKeyData: null == senderKeyData
          ? _value.senderKeyData
          : senderKeyData // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FirebaseSenderKeyImplCopyWith<$Res>
    implements $FirebaseSenderKeyCopyWith<$Res> {
  factory _$$FirebaseSenderKeyImplCopyWith(_$FirebaseSenderKeyImpl value,
          $Res Function(_$FirebaseSenderKeyImpl) then) =
      __$$FirebaseSenderKeyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String groupId,
      String senderKeyData,
      int timestamp,
      String deviceId,
      bool isActive});
}

/// @nodoc
class __$$FirebaseSenderKeyImplCopyWithImpl<$Res>
    extends _$FirebaseSenderKeyCopyWithImpl<$Res, _$FirebaseSenderKeyImpl>
    implements _$$FirebaseSenderKeyImplCopyWith<$Res> {
  __$$FirebaseSenderKeyImplCopyWithImpl(_$FirebaseSenderKeyImpl _value,
      $Res Function(_$FirebaseSenderKeyImpl) _then)
      : super(_value, _then);

  /// Create a copy of FirebaseSenderKey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupId = null,
    Object? senderKeyData = null,
    Object? timestamp = null,
    Object? deviceId = null,
    Object? isActive = null,
  }) {
    return _then(_$FirebaseSenderKeyImpl(
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      senderKeyData: null == senderKeyData
          ? _value.senderKeyData
          : senderKeyData // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FirebaseSenderKeyImpl implements _FirebaseSenderKey {
  const _$FirebaseSenderKeyImpl(
      {required this.groupId,
      required this.senderKeyData,
      required this.timestamp,
      required this.deviceId,
      required this.isActive});

  factory _$FirebaseSenderKeyImpl.fromJson(Map<String, dynamic> json) =>
      _$$FirebaseSenderKeyImplFromJson(json);

  @override
  final String groupId;
  @override
  final String senderKeyData;
// Base64 encoded sender key
  @override
  final int timestamp;
  @override
  final String deviceId;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'FirebaseSenderKey(groupId: $groupId, senderKeyData: $senderKeyData, timestamp: $timestamp, deviceId: $deviceId, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirebaseSenderKeyImpl &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.senderKeyData, senderKeyData) ||
                other.senderKeyData == senderKeyData) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, groupId, senderKeyData, timestamp, deviceId, isActive);

  /// Create a copy of FirebaseSenderKey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FirebaseSenderKeyImplCopyWith<_$FirebaseSenderKeyImpl> get copyWith =>
      __$$FirebaseSenderKeyImplCopyWithImpl<_$FirebaseSenderKeyImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FirebaseSenderKeyImplToJson(
      this,
    );
  }
}

abstract class _FirebaseSenderKey implements FirebaseSenderKey {
  const factory _FirebaseSenderKey(
      {required final String groupId,
      required final String senderKeyData,
      required final int timestamp,
      required final String deviceId,
      required final bool isActive}) = _$FirebaseSenderKeyImpl;

  factory _FirebaseSenderKey.fromJson(Map<String, dynamic> json) =
      _$FirebaseSenderKeyImpl.fromJson;

  @override
  String get groupId;
  @override
  String get senderKeyData; // Base64 encoded sender key
  @override
  int get timestamp;
  @override
  String get deviceId;
  @override
  bool get isActive;

  /// Create a copy of FirebaseSenderKey
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FirebaseSenderKeyImplCopyWith<_$FirebaseSenderKeyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FirebaseUserMetadata _$FirebaseUserMetadataFromJson(Map<String, dynamic> json) {
  return _FirebaseUserMetadata.fromJson(json);
}

/// @nodoc
mixin _$FirebaseUserMetadata {
  String get userId => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  int get lastUpdated => throw _privateConstructorUsedError;
  int get keysVersion => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  Map<String, dynamic>? get customData => throw _privateConstructorUsedError;

  /// Serializes this FirebaseUserMetadata to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FirebaseUserMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FirebaseUserMetadataCopyWith<FirebaseUserMetadata> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FirebaseUserMetadataCopyWith<$Res> {
  factory $FirebaseUserMetadataCopyWith(FirebaseUserMetadata value,
          $Res Function(FirebaseUserMetadata) then) =
      _$FirebaseUserMetadataCopyWithImpl<$Res, FirebaseUserMetadata>;
  @useResult
  $Res call(
      {String userId,
      String deviceId,
      int lastUpdated,
      int keysVersion,
      String? displayName,
      Map<String, dynamic>? customData});
}

/// @nodoc
class _$FirebaseUserMetadataCopyWithImpl<$Res,
        $Val extends FirebaseUserMetadata>
    implements $FirebaseUserMetadataCopyWith<$Res> {
  _$FirebaseUserMetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FirebaseUserMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? deviceId = null,
    Object? lastUpdated = null,
    Object? keysVersion = null,
    Object? displayName = freezed,
    Object? customData = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as int,
      keysVersion: null == keysVersion
          ? _value.keysVersion
          : keysVersion // ignore: cast_nullable_to_non_nullable
              as int,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      customData: freezed == customData
          ? _value.customData
          : customData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FirebaseUserMetadataImplCopyWith<$Res>
    implements $FirebaseUserMetadataCopyWith<$Res> {
  factory _$$FirebaseUserMetadataImplCopyWith(_$FirebaseUserMetadataImpl value,
          $Res Function(_$FirebaseUserMetadataImpl) then) =
      __$$FirebaseUserMetadataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String deviceId,
      int lastUpdated,
      int keysVersion,
      String? displayName,
      Map<String, dynamic>? customData});
}

/// @nodoc
class __$$FirebaseUserMetadataImplCopyWithImpl<$Res>
    extends _$FirebaseUserMetadataCopyWithImpl<$Res, _$FirebaseUserMetadataImpl>
    implements _$$FirebaseUserMetadataImplCopyWith<$Res> {
  __$$FirebaseUserMetadataImplCopyWithImpl(_$FirebaseUserMetadataImpl _value,
      $Res Function(_$FirebaseUserMetadataImpl) _then)
      : super(_value, _then);

  /// Create a copy of FirebaseUserMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? deviceId = null,
    Object? lastUpdated = null,
    Object? keysVersion = null,
    Object? displayName = freezed,
    Object? customData = freezed,
  }) {
    return _then(_$FirebaseUserMetadataImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as int,
      keysVersion: null == keysVersion
          ? _value.keysVersion
          : keysVersion // ignore: cast_nullable_to_non_nullable
              as int,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      customData: freezed == customData
          ? _value._customData
          : customData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FirebaseUserMetadataImpl implements _FirebaseUserMetadata {
  const _$FirebaseUserMetadataImpl(
      {required this.userId,
      required this.deviceId,
      required this.lastUpdated,
      required this.keysVersion,
      this.displayName,
      final Map<String, dynamic>? customData})
      : _customData = customData;

  factory _$FirebaseUserMetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$FirebaseUserMetadataImplFromJson(json);

  @override
  final String userId;
  @override
  final String deviceId;
  @override
  final int lastUpdated;
  @override
  final int keysVersion;
  @override
  final String? displayName;
  final Map<String, dynamic>? _customData;
  @override
  Map<String, dynamic>? get customData {
    final value = _customData;
    if (value == null) return null;
    if (_customData is EqualUnmodifiableMapView) return _customData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'FirebaseUserMetadata(userId: $userId, deviceId: $deviceId, lastUpdated: $lastUpdated, keysVersion: $keysVersion, displayName: $displayName, customData: $customData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirebaseUserMetadataImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.keysVersion, keysVersion) ||
                other.keysVersion == keysVersion) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            const DeepCollectionEquality()
                .equals(other._customData, _customData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      deviceId,
      lastUpdated,
      keysVersion,
      displayName,
      const DeepCollectionEquality().hash(_customData));

  /// Create a copy of FirebaseUserMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FirebaseUserMetadataImplCopyWith<_$FirebaseUserMetadataImpl>
      get copyWith =>
          __$$FirebaseUserMetadataImplCopyWithImpl<_$FirebaseUserMetadataImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FirebaseUserMetadataImplToJson(
      this,
    );
  }
}

abstract class _FirebaseUserMetadata implements FirebaseUserMetadata {
  const factory _FirebaseUserMetadata(
      {required final String userId,
      required final String deviceId,
      required final int lastUpdated,
      required final int keysVersion,
      final String? displayName,
      final Map<String, dynamic>? customData}) = _$FirebaseUserMetadataImpl;

  factory _FirebaseUserMetadata.fromJson(Map<String, dynamic> json) =
      _$FirebaseUserMetadataImpl.fromJson;

  @override
  String get userId;
  @override
  String get deviceId;
  @override
  int get lastUpdated;
  @override
  int get keysVersion;
  @override
  String? get displayName;
  @override
  Map<String, dynamic>? get customData;

  /// Create a copy of FirebaseUserMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FirebaseUserMetadataImplCopyWith<_$FirebaseUserMetadataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

FirebaseKeyBundle _$FirebaseKeyBundleFromJson(Map<String, dynamic> json) {
  return _FirebaseKeyBundle.fromJson(json);
}

/// @nodoc
mixin _$FirebaseKeyBundle {
  String get userId => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  FirebaseIdentityKey get identityKey => throw _privateConstructorUsedError;
  FirebaseRegistrationId get registrationId =>
      throw _privateConstructorUsedError;
  FirebaseSignedPreKey get signedPreKey => throw _privateConstructorUsedError;
  List<FirebasePreKey> get preKeys => throw _privateConstructorUsedError;
  FirebaseUserMetadata get metadata => throw _privateConstructorUsedError;

  /// Serializes this FirebaseKeyBundle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FirebaseKeyBundle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FirebaseKeyBundleCopyWith<FirebaseKeyBundle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FirebaseKeyBundleCopyWith<$Res> {
  factory $FirebaseKeyBundleCopyWith(
          FirebaseKeyBundle value, $Res Function(FirebaseKeyBundle) then) =
      _$FirebaseKeyBundleCopyWithImpl<$Res, FirebaseKeyBundle>;
  @useResult
  $Res call(
      {String userId,
      String deviceId,
      FirebaseIdentityKey identityKey,
      FirebaseRegistrationId registrationId,
      FirebaseSignedPreKey signedPreKey,
      List<FirebasePreKey> preKeys,
      FirebaseUserMetadata metadata});

  $FirebaseIdentityKeyCopyWith<$Res> get identityKey;
  $FirebaseRegistrationIdCopyWith<$Res> get registrationId;
  $FirebaseSignedPreKeyCopyWith<$Res> get signedPreKey;
  $FirebaseUserMetadataCopyWith<$Res> get metadata;
}

/// @nodoc
class _$FirebaseKeyBundleCopyWithImpl<$Res, $Val extends FirebaseKeyBundle>
    implements $FirebaseKeyBundleCopyWith<$Res> {
  _$FirebaseKeyBundleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FirebaseKeyBundle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? deviceId = null,
    Object? identityKey = null,
    Object? registrationId = null,
    Object? signedPreKey = null,
    Object? preKeys = null,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      identityKey: null == identityKey
          ? _value.identityKey
          : identityKey // ignore: cast_nullable_to_non_nullable
              as FirebaseIdentityKey,
      registrationId: null == registrationId
          ? _value.registrationId
          : registrationId // ignore: cast_nullable_to_non_nullable
              as FirebaseRegistrationId,
      signedPreKey: null == signedPreKey
          ? _value.signedPreKey
          : signedPreKey // ignore: cast_nullable_to_non_nullable
              as FirebaseSignedPreKey,
      preKeys: null == preKeys
          ? _value.preKeys
          : preKeys // ignore: cast_nullable_to_non_nullable
              as List<FirebasePreKey>,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as FirebaseUserMetadata,
    ) as $Val);
  }

  /// Create a copy of FirebaseKeyBundle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FirebaseIdentityKeyCopyWith<$Res> get identityKey {
    return $FirebaseIdentityKeyCopyWith<$Res>(_value.identityKey, (value) {
      return _then(_value.copyWith(identityKey: value) as $Val);
    });
  }

  /// Create a copy of FirebaseKeyBundle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FirebaseRegistrationIdCopyWith<$Res> get registrationId {
    return $FirebaseRegistrationIdCopyWith<$Res>(_value.registrationId,
        (value) {
      return _then(_value.copyWith(registrationId: value) as $Val);
    });
  }

  /// Create a copy of FirebaseKeyBundle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FirebaseSignedPreKeyCopyWith<$Res> get signedPreKey {
    return $FirebaseSignedPreKeyCopyWith<$Res>(_value.signedPreKey, (value) {
      return _then(_value.copyWith(signedPreKey: value) as $Val);
    });
  }

  /// Create a copy of FirebaseKeyBundle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FirebaseUserMetadataCopyWith<$Res> get metadata {
    return $FirebaseUserMetadataCopyWith<$Res>(_value.metadata, (value) {
      return _then(_value.copyWith(metadata: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FirebaseKeyBundleImplCopyWith<$Res>
    implements $FirebaseKeyBundleCopyWith<$Res> {
  factory _$$FirebaseKeyBundleImplCopyWith(_$FirebaseKeyBundleImpl value,
          $Res Function(_$FirebaseKeyBundleImpl) then) =
      __$$FirebaseKeyBundleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String deviceId,
      FirebaseIdentityKey identityKey,
      FirebaseRegistrationId registrationId,
      FirebaseSignedPreKey signedPreKey,
      List<FirebasePreKey> preKeys,
      FirebaseUserMetadata metadata});

  @override
  $FirebaseIdentityKeyCopyWith<$Res> get identityKey;
  @override
  $FirebaseRegistrationIdCopyWith<$Res> get registrationId;
  @override
  $FirebaseSignedPreKeyCopyWith<$Res> get signedPreKey;
  @override
  $FirebaseUserMetadataCopyWith<$Res> get metadata;
}

/// @nodoc
class __$$FirebaseKeyBundleImplCopyWithImpl<$Res>
    extends _$FirebaseKeyBundleCopyWithImpl<$Res, _$FirebaseKeyBundleImpl>
    implements _$$FirebaseKeyBundleImplCopyWith<$Res> {
  __$$FirebaseKeyBundleImplCopyWithImpl(_$FirebaseKeyBundleImpl _value,
      $Res Function(_$FirebaseKeyBundleImpl) _then)
      : super(_value, _then);

  /// Create a copy of FirebaseKeyBundle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? deviceId = null,
    Object? identityKey = null,
    Object? registrationId = null,
    Object? signedPreKey = null,
    Object? preKeys = null,
    Object? metadata = null,
  }) {
    return _then(_$FirebaseKeyBundleImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      identityKey: null == identityKey
          ? _value.identityKey
          : identityKey // ignore: cast_nullable_to_non_nullable
              as FirebaseIdentityKey,
      registrationId: null == registrationId
          ? _value.registrationId
          : registrationId // ignore: cast_nullable_to_non_nullable
              as FirebaseRegistrationId,
      signedPreKey: null == signedPreKey
          ? _value.signedPreKey
          : signedPreKey // ignore: cast_nullable_to_non_nullable
              as FirebaseSignedPreKey,
      preKeys: null == preKeys
          ? _value._preKeys
          : preKeys // ignore: cast_nullable_to_non_nullable
              as List<FirebasePreKey>,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as FirebaseUserMetadata,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FirebaseKeyBundleImpl implements _FirebaseKeyBundle {
  const _$FirebaseKeyBundleImpl(
      {required this.userId,
      required this.deviceId,
      required this.identityKey,
      required this.registrationId,
      required this.signedPreKey,
      required final List<FirebasePreKey> preKeys,
      required this.metadata})
      : _preKeys = preKeys;

  factory _$FirebaseKeyBundleImpl.fromJson(Map<String, dynamic> json) =>
      _$$FirebaseKeyBundleImplFromJson(json);

  @override
  final String userId;
  @override
  final String deviceId;
  @override
  final FirebaseIdentityKey identityKey;
  @override
  final FirebaseRegistrationId registrationId;
  @override
  final FirebaseSignedPreKey signedPreKey;
  final List<FirebasePreKey> _preKeys;
  @override
  List<FirebasePreKey> get preKeys {
    if (_preKeys is EqualUnmodifiableListView) return _preKeys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preKeys);
  }

  @override
  final FirebaseUserMetadata metadata;

  @override
  String toString() {
    return 'FirebaseKeyBundle(userId: $userId, deviceId: $deviceId, identityKey: $identityKey, registrationId: $registrationId, signedPreKey: $signedPreKey, preKeys: $preKeys, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirebaseKeyBundleImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.identityKey, identityKey) ||
                other.identityKey == identityKey) &&
            (identical(other.registrationId, registrationId) ||
                other.registrationId == registrationId) &&
            (identical(other.signedPreKey, signedPreKey) ||
                other.signedPreKey == signedPreKey) &&
            const DeepCollectionEquality().equals(other._preKeys, _preKeys) &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      deviceId,
      identityKey,
      registrationId,
      signedPreKey,
      const DeepCollectionEquality().hash(_preKeys),
      metadata);

  /// Create a copy of FirebaseKeyBundle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FirebaseKeyBundleImplCopyWith<_$FirebaseKeyBundleImpl> get copyWith =>
      __$$FirebaseKeyBundleImplCopyWithImpl<_$FirebaseKeyBundleImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FirebaseKeyBundleImplToJson(
      this,
    );
  }
}

abstract class _FirebaseKeyBundle implements FirebaseKeyBundle {
  const factory _FirebaseKeyBundle(
      {required final String userId,
      required final String deviceId,
      required final FirebaseIdentityKey identityKey,
      required final FirebaseRegistrationId registrationId,
      required final FirebaseSignedPreKey signedPreKey,
      required final List<FirebasePreKey> preKeys,
      required final FirebaseUserMetadata metadata}) = _$FirebaseKeyBundleImpl;

  factory _FirebaseKeyBundle.fromJson(Map<String, dynamic> json) =
      _$FirebaseKeyBundleImpl.fromJson;

  @override
  String get userId;
  @override
  String get deviceId;
  @override
  FirebaseIdentityKey get identityKey;
  @override
  FirebaseRegistrationId get registrationId;
  @override
  FirebaseSignedPreKey get signedPreKey;
  @override
  List<FirebasePreKey> get preKeys;
  @override
  FirebaseUserMetadata get metadata;

  /// Create a copy of FirebaseKeyBundle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FirebaseKeyBundleImplCopyWith<_$FirebaseKeyBundleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FirebaseSyncEvent _$FirebaseSyncEventFromJson(Map<String, dynamic> json) {
  return _FirebaseSyncEvent.fromJson(json);
}

/// @nodoc
mixin _$FirebaseSyncEvent {
  String get eventType =>
      throw _privateConstructorUsedError; // 'key_updated', 'key_deleted', 'user_offline'
  String get userId => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  int get timestamp => throw _privateConstructorUsedError;
  String? get keyType =>
      throw _privateConstructorUsedError; // 'identity', 'prekey', 'signed_prekey', 'sender_key'
  String? get keyId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get data => throw _privateConstructorUsedError;

  /// Serializes this FirebaseSyncEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FirebaseSyncEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FirebaseSyncEventCopyWith<FirebaseSyncEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FirebaseSyncEventCopyWith<$Res> {
  factory $FirebaseSyncEventCopyWith(
          FirebaseSyncEvent value, $Res Function(FirebaseSyncEvent) then) =
      _$FirebaseSyncEventCopyWithImpl<$Res, FirebaseSyncEvent>;
  @useResult
  $Res call(
      {String eventType,
      String userId,
      String deviceId,
      int timestamp,
      String? keyType,
      String? keyId,
      Map<String, dynamic>? data});
}

/// @nodoc
class _$FirebaseSyncEventCopyWithImpl<$Res, $Val extends FirebaseSyncEvent>
    implements $FirebaseSyncEventCopyWith<$Res> {
  _$FirebaseSyncEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FirebaseSyncEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventType = null,
    Object? userId = null,
    Object? deviceId = null,
    Object? timestamp = null,
    Object? keyType = freezed,
    Object? keyId = freezed,
    Object? data = freezed,
  }) {
    return _then(_value.copyWith(
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      keyType: freezed == keyType
          ? _value.keyType
          : keyType // ignore: cast_nullable_to_non_nullable
              as String?,
      keyId: freezed == keyId
          ? _value.keyId
          : keyId // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FirebaseSyncEventImplCopyWith<$Res>
    implements $FirebaseSyncEventCopyWith<$Res> {
  factory _$$FirebaseSyncEventImplCopyWith(_$FirebaseSyncEventImpl value,
          $Res Function(_$FirebaseSyncEventImpl) then) =
      __$$FirebaseSyncEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String eventType,
      String userId,
      String deviceId,
      int timestamp,
      String? keyType,
      String? keyId,
      Map<String, dynamic>? data});
}

/// @nodoc
class __$$FirebaseSyncEventImplCopyWithImpl<$Res>
    extends _$FirebaseSyncEventCopyWithImpl<$Res, _$FirebaseSyncEventImpl>
    implements _$$FirebaseSyncEventImplCopyWith<$Res> {
  __$$FirebaseSyncEventImplCopyWithImpl(_$FirebaseSyncEventImpl _value,
      $Res Function(_$FirebaseSyncEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of FirebaseSyncEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventType = null,
    Object? userId = null,
    Object? deviceId = null,
    Object? timestamp = null,
    Object? keyType = freezed,
    Object? keyId = freezed,
    Object? data = freezed,
  }) {
    return _then(_$FirebaseSyncEventImpl(
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      keyType: freezed == keyType
          ? _value.keyType
          : keyType // ignore: cast_nullable_to_non_nullable
              as String?,
      keyId: freezed == keyId
          ? _value.keyId
          : keyId // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FirebaseSyncEventImpl implements _FirebaseSyncEvent {
  const _$FirebaseSyncEventImpl(
      {required this.eventType,
      required this.userId,
      required this.deviceId,
      required this.timestamp,
      this.keyType,
      this.keyId,
      final Map<String, dynamic>? data})
      : _data = data;

  factory _$FirebaseSyncEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$FirebaseSyncEventImplFromJson(json);

  @override
  final String eventType;
// 'key_updated', 'key_deleted', 'user_offline'
  @override
  final String userId;
  @override
  final String deviceId;
  @override
  final int timestamp;
  @override
  final String? keyType;
// 'identity', 'prekey', 'signed_prekey', 'sender_key'
  @override
  final String? keyId;
  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'FirebaseSyncEvent(eventType: $eventType, userId: $userId, deviceId: $deviceId, timestamp: $timestamp, keyType: $keyType, keyId: $keyId, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirebaseSyncEventImpl &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.keyType, keyType) || other.keyType == keyType) &&
            (identical(other.keyId, keyId) || other.keyId == keyId) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, eventType, userId, deviceId,
      timestamp, keyType, keyId, const DeepCollectionEquality().hash(_data));

  /// Create a copy of FirebaseSyncEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FirebaseSyncEventImplCopyWith<_$FirebaseSyncEventImpl> get copyWith =>
      __$$FirebaseSyncEventImplCopyWithImpl<_$FirebaseSyncEventImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FirebaseSyncEventImplToJson(
      this,
    );
  }
}

abstract class _FirebaseSyncEvent implements FirebaseSyncEvent {
  const factory _FirebaseSyncEvent(
      {required final String eventType,
      required final String userId,
      required final String deviceId,
      required final int timestamp,
      final String? keyType,
      final String? keyId,
      final Map<String, dynamic>? data}) = _$FirebaseSyncEventImpl;

  factory _FirebaseSyncEvent.fromJson(Map<String, dynamic> json) =
      _$FirebaseSyncEventImpl.fromJson;

  @override
  String get eventType; // 'key_updated', 'key_deleted', 'user_offline'
  @override
  String get userId;
  @override
  String get deviceId;
  @override
  int get timestamp;
  @override
  String? get keyType; // 'identity', 'prekey', 'signed_prekey', 'sender_key'
  @override
  String? get keyId;
  @override
  Map<String, dynamic>? get data;

  /// Create a copy of FirebaseSyncEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FirebaseSyncEventImplCopyWith<_$FirebaseSyncEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
