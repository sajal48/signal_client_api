/// Platform-specific optimizations for Signal Protocol operations
library;

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

import 'logger.dart';

/// Platform detection and optimization utilities
class SignalPlatformOptimizer {
  SignalPlatformOptimizer._();
  static SignalPlatformOptimizer? _instance;
  
  /// Get the singleton instance
  static SignalPlatformOptimizer get instance {
    _instance ??= SignalPlatformOptimizer._();
    return _instance!;
  }

  /// Current platform information
  PlatformInfo? _platformInfo;

  /// Initialize platform optimizer
  Future<void> initialize() async {
    try {
      await _detectPlatform();
      _applyPlatformOptimizations();
      SignalLogger.info('Platform optimizer initialized for ${_platformInfo?.platform}');
    } catch (e) {
      SignalLogger.warning('Failed to initialize platform optimizer: $e');
    }
  }

  /// Get current platform information
  PlatformInfo? get platformInfo => _platformInfo;

  /// Check if running on Android
  bool get isAndroid => _platformInfo?.platform == SignalPlatform.android;

  /// Check if running on iOS
  bool get isIOS => _platformInfo?.platform == SignalPlatform.ios;

  /// Check if running on desktop
  bool get isDesktop => _platformInfo?.platform == SignalPlatform.windows ||
                        _platformInfo?.platform == SignalPlatform.macos ||
                        _platformInfo?.platform == SignalPlatform.linux;

  /// Check if running on mobile
  bool get isMobile => isAndroid || isIOS;

  /// Check if device is low-end
  bool get isLowEndDevice => _platformInfo?.isLowEndDevice ?? false;

  /// Get recommended batch size for operations
  int getRecommendedBatchSize() {
    if (_platformInfo == null) return 10;

    if (isLowEndDevice) {
      return 5; // Smaller batches for low-end devices
    } else if (isMobile) {
      return 15; // Medium batches for mobile
    } else {
      return 25; // Larger batches for desktop
    }
  }

  /// Get recommended cache size
  int getRecommendedCacheSize() {
    if (_platformInfo == null) return 100;

    if (isLowEndDevice) {
      return 50; // Smaller cache for low-end devices
    } else if (isMobile) {
      return 150; // Medium cache for mobile
    } else {
      return 300; // Larger cache for desktop
    }
  }

  /// Get recommended concurrent operations limit
  int getRecommendedConcurrencyLimit() {
    if (_platformInfo == null) return 3;

    if (isLowEndDevice) {
      return 2; // Limited concurrency for low-end devices
    } else if (isMobile) {
      return 4; // Medium concurrency for mobile
    } else {
      return 8; // Higher concurrency for desktop
    }
  }

  /// Check if hardware crypto acceleration is available
  bool get hasHardwareCrypto {
    if (_platformInfo == null) return false;
    
    // Android devices generally have hardware crypto support
    if (isAndroid && (_platformInfo!.androidInfo?.version.sdkInt ?? 0) >= 23) {
      return true;
    }
    
    // iOS devices have hardware crypto support
    if (isIOS) {
      return true;
    }
    
    // Desktop platforms may have hardware crypto
    return isDesktop;
  }

  /// Get recommended crypto operation strategy
  CryptoStrategy getRecommendedCryptoStrategy() {
    if (hasHardwareCrypto) {
      return CryptoStrategy.hardware;
    } else if (isLowEndDevice) {
      return CryptoStrategy.optimizedSoftware;
    } else {
      return CryptoStrategy.standardSoftware;
    }
  }

  /// Get platform-specific storage path recommendations
  StorageRecommendations getStorageRecommendations() {
    if (isAndroid) {
      return const StorageRecommendations(
        useSecureStorage: true,
        preferInternalStorage: true,
        enableStorageEncryption: true,
        maxCacheSize: 50 * 1024 * 1024, // 50MB
      );
    } else if (isIOS) {
      return const StorageRecommendations(
        useSecureStorage: true,
        preferInternalStorage: true,
        enableStorageEncryption: true,
        maxCacheSize: 100 * 1024 * 1024, // 100MB
      );
    } else {
      return const StorageRecommendations(
        useSecureStorage: true,
        preferInternalStorage: false,
        enableStorageEncryption: true,
        maxCacheSize: 200 * 1024 * 1024, // 200MB
      );
    }
  }

  /// Get network optimization recommendations
  NetworkOptimizations getNetworkOptimizations() {
    if (isMobile) {
      return const NetworkOptimizations(
        enableCompression: true,
        maxConcurrentRequests: 3,
        requestTimeoutMs: 30000,
        retryAttempts: 3,
        useBackgroundMode: true,
      );
    } else {
      return const NetworkOptimizations(
        enableCompression: true,
        maxConcurrentRequests: 6,
        requestTimeoutMs: 15000,
        retryAttempts: 2,
        useBackgroundMode: false,
      );
    }
  }

  /// Apply platform-specific optimizations
  void _applyPlatformOptimizations() {
    if (_platformInfo == null) return;

    SignalLogger.info('Applying optimizations for ${_platformInfo!.platform.name}');

    // Apply memory optimizations for low-end devices
    if (isLowEndDevice) {
      SignalLogger.info('Applying low-end device optimizations');
      // Reduce cache sizes, limit concurrent operations, etc.
    }

    // Apply mobile-specific optimizations
    if (isMobile) {
      SignalLogger.info('Applying mobile optimizations');
      // Battery optimization, background processing limits, etc.
    }

    // Apply crypto optimizations
    final cryptoStrategy = getRecommendedCryptoStrategy();
    SignalLogger.info('Using crypto strategy: ${cryptoStrategy.name}');
  }

  /// Detect current platform and capabilities
  Future<void> _detectPlatform() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _platformInfo = PlatformInfo(
          platform: SignalPlatform.android,
          androidInfo: androidInfo,
          isLowEndDevice: _isLowEndAndroid(androidInfo),
        );
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _platformInfo = PlatformInfo(
          platform: SignalPlatform.ios,
          iosInfo: iosInfo,
          isLowEndDevice: _isLowEndIOS(iosInfo),
        );
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        _platformInfo = PlatformInfo(
          platform: SignalPlatform.windows,
          windowsInfo: windowsInfo,
          isLowEndDevice: false,
        );
      } else if (Platform.isMacOS) {
        final macOSInfo = await deviceInfo.macOsInfo;
        _platformInfo = PlatformInfo(
          platform: SignalPlatform.macos,
          macOSInfo: macOSInfo,
          isLowEndDevice: false,
        );
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        _platformInfo = PlatformInfo(
          platform: SignalPlatform.linux,
          linuxInfo: linuxInfo,
          isLowEndDevice: false,
        );
      } else {
        _platformInfo = const PlatformInfo(
          platform: SignalPlatform.unknown,
          isLowEndDevice: true,
        );
      }
    } catch (e) {
      SignalLogger.warning('Failed to detect platform: $e');
      _platformInfo = const PlatformInfo(
        platform: SignalPlatform.unknown,
        isLowEndDevice: true,
      );
    }
  }

  /// Determine if Android device is low-end
  bool _isLowEndAndroid(AndroidDeviceInfo androidInfo) {
    try {
      // Consider devices with API level < 26 as potentially low-end
      if (androidInfo.version.sdkInt < 26) {
        return true;
      }

      // Check for known low-end device indicators
      final model = androidInfo.model.toLowerCase();
      final manufacturer = androidInfo.manufacturer.toLowerCase();

      // Known low-end device patterns
      if (model.contains('go') || model.contains('lite') || model.contains('mini')) {
        return true;
      }

      // Some low-end manufacturers (this is a simplified check)
      if (manufacturer.contains('alcatel') || manufacturer.contains('zte')) {
        return true;
      }

      return false;
    } catch (e) {
      SignalLogger.warning('Failed to determine Android device capabilities: $e');
      return true; // Default to low-end for safety
    }
  }

  /// Determine if iOS device is low-end
  bool _isLowEndIOS(IosDeviceInfo iosInfo) {
    try {
      // Check iOS version - older versions might indicate older/slower devices
      final systemVersion = iosInfo.systemVersion;
      final versionParts = systemVersion.split('.');
      if (versionParts.isNotEmpty) {
        final majorVersion = int.tryParse(versionParts[0]) ?? 0;
        if (majorVersion < 14) {
          return true; // iOS < 14 might be on older devices
        }
      }

      // Check for older device models
      final model = iosInfo.model.toLowerCase();
      if (model.contains('iphone se') || model.contains('iphone 6')) {
        return true;
      }

      return false;
    } catch (e) {
      SignalLogger.warning('Failed to determine iOS device capabilities: $e');
      return false; // iOS devices are generally more uniform
    }
  }
}

/// Platform enumeration
enum SignalPlatform {
  android,
  ios,
  windows,
  macos,
  linux,
  unknown,
}

/// Crypto strategy options
enum CryptoStrategy {
  hardware,
  standardSoftware,
  optimizedSoftware,
}

/// Platform information
class PlatformInfo {
  const PlatformInfo({
    required this.platform,
    required this.isLowEndDevice,
    this.androidInfo,
    this.iosInfo,
    this.windowsInfo,
    this.macOSInfo,
    this.linuxInfo,
  });

  final SignalPlatform platform;
  final bool isLowEndDevice;
  final AndroidDeviceInfo? androidInfo;
  final IosDeviceInfo? iosInfo;
  final WindowsDeviceInfo? windowsInfo;
  final MacOsDeviceInfo? macOSInfo;
  final LinuxDeviceInfo? linuxInfo;
}

/// Storage recommendations
class StorageRecommendations {
  const StorageRecommendations({
    required this.useSecureStorage,
    required this.preferInternalStorage,
    required this.enableStorageEncryption,
    required this.maxCacheSize,
  });

  final bool useSecureStorage;
  final bool preferInternalStorage;
  final bool enableStorageEncryption;
  final int maxCacheSize;
}

/// Network optimization settings
class NetworkOptimizations {
  const NetworkOptimizations({
    required this.enableCompression,
    required this.maxConcurrentRequests,
    required this.requestTimeoutMs,
    required this.retryAttempts,
    required this.useBackgroundMode,
  });

  final bool enableCompression;
  final int maxConcurrentRequests;
  final int requestTimeoutMs;
  final int retryAttempts;
  final bool useBackgroundMode;
}
