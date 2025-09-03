/// Simple user model for the example app
class UserModel {
  final String userId;
  final String? displayName;
  final bool isInitialized;
  final int? deviceId;

  const UserModel({
    required this.userId,
    this.displayName,
    required this.isInitialized,
    this.deviceId,
  });

  /// Create a UserModel from a map (e.g., from instance info)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      displayName: map['displayName'],
      isInitialized: map['isInitialized'] ?? false,
      deviceId: map['deviceId'],
    );
  }

  /// Convert UserModel to a map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'isInitialized': isInitialized,
      'deviceId': deviceId,
    };
  }

  /// Create a copy with modified fields
  UserModel copyWith({
    String? userId,
    String? displayName,
    bool? isInitialized,
    int? deviceId,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      isInitialized: isInitialized ?? this.isInitialized,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  @override
  String toString() {
    return 'UserModel(userId: $userId, displayName: $displayName, isInitialized: $isInitialized, deviceId: $deviceId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserModel &&
      other.userId == userId &&
      other.displayName == displayName &&
      other.isInitialized == isInitialized &&
      other.deviceId == deviceId;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
      displayName.hashCode ^
      isInitialized.hashCode ^
      deviceId.hashCode;
  }
}
