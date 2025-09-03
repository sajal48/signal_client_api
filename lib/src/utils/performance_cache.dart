/// Performance caching utilities for Signal Protocol operations
library;

import 'dart:collection';

import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

import 'logger.dart';

/// Cache manager for Signal Protocol keys and sessions
class SignalPerformanceCache {
  SignalPerformanceCache._();
  static SignalPerformanceCache? _instance;
  
  /// Get the singleton instance
  static SignalPerformanceCache get instance {
    _instance ??= SignalPerformanceCache._();
    return _instance!;
  }

  // LRU Cache for identity keys
  final _identityKeyCache = LRUCache<String, IdentityKey>(maxSize: 100);
  
  // LRU Cache for prekey bundles
  final _preKeyBundleCache = LRUCache<String, PreKeyBundle>(maxSize: 50);
  
  // LRU Cache for session records
  final _sessionCache = LRUCache<String, SessionRecord>(maxSize: 200);
  
  // LRU Cache for Firebase key bundles
  final _firebaseKeyCache = LRUCache<String, Map<String, dynamic>>(maxSize: 75);
  
  // Cache for computed crypto operations
  final _cryptoCache = LRUCache<String, List<int>>(maxSize: 150);

  /// Cache an identity key
  void cacheIdentityKey(String userId, IdentityKey identityKey) {
    try {
      _identityKeyCache.put(userId, identityKey);
      SignalLogger.debug('Cached identity key for user: $userId');
    } catch (e) {
      SignalLogger.warning('Failed to cache identity key: $e');
    }
  }

  /// Get cached identity key
  IdentityKey? getCachedIdentityKey(String userId) {
    try {
      final key = _identityKeyCache.get(userId);
      if (key != null) {
        SignalLogger.debug('Cache hit for identity key: $userId');
      }
      return key;
    } catch (e) {
      SignalLogger.warning('Failed to get cached identity key: $e');
      return null;
    }
  }

  /// Cache a prekey bundle
  void cachePreKeyBundle(String userId, int deviceId, PreKeyBundle bundle) {
    try {
      final key = '$userId:$deviceId';
      _preKeyBundleCache.put(key, bundle);
      SignalLogger.debug('Cached prekey bundle for: $key');
    } catch (e) {
      SignalLogger.warning('Failed to cache prekey bundle: $e');
    }
  }

  /// Get cached prekey bundle
  PreKeyBundle? getCachedPreKeyBundle(String userId, int deviceId) {
    try {
      final key = '$userId:$deviceId';
      final bundle = _preKeyBundleCache.get(key);
      if (bundle != null) {
        SignalLogger.debug('Cache hit for prekey bundle: $key');
      }
      return bundle;
    } catch (e) {
      SignalLogger.warning('Failed to get cached prekey bundle: $e');
      return null;
    }
  }

  /// Cache a session record
  void cacheSession(String userId, int deviceId, SessionRecord session) {
    try {
      final key = '$userId:$deviceId';
      _sessionCache.put(key, session);
      SignalLogger.debug('Cached session for: $key');
    } catch (e) {
      SignalLogger.warning('Failed to cache session: $e');
    }
  }

  /// Get cached session record
  SessionRecord? getCachedSession(String userId, int deviceId) {
    try {
      final key = '$userId:$deviceId';
      final session = _sessionCache.get(key);
      if (session != null) {
        SignalLogger.debug('Cache hit for session: $key');
      }
      return session;
    } catch (e) {
      SignalLogger.warning('Failed to get cached session: $e');
      return null;
    }
  }

  /// Cache Firebase key bundle
  void cacheFirebaseKeys(String userId, Map<String, dynamic> keyBundle) {
    try {
      _firebaseKeyCache.put(userId, keyBundle);
      SignalLogger.debug('Cached Firebase keys for user: $userId');
    } catch (e) {
      SignalLogger.warning('Failed to cache Firebase keys: $e');
    }
  }

  /// Get cached Firebase key bundle
  Map<String, dynamic>? getCachedFirebaseKeys(String userId) {
    try {
      final keys = _firebaseKeyCache.get(userId);
      if (keys != null) {
        SignalLogger.debug('Cache hit for Firebase keys: $userId');
      }
      return keys;
    } catch (e) {
      SignalLogger.warning('Failed to get cached Firebase keys: $e');
      return null;
    }
  }

  /// Cache crypto operation result
  void cacheCryptoOperation(String operationKey, List<int> result) {
    try {
      _cryptoCache.put(operationKey, result);
      SignalLogger.debug('Cached crypto operation: $operationKey');
    } catch (e) {
      SignalLogger.warning('Failed to cache crypto operation: $e');
    }
  }

  /// Get cached crypto operation result
  List<int>? getCachedCryptoOperation(String operationKey) {
    try {
      final result = _cryptoCache.get(operationKey);
      if (result != null) {
        SignalLogger.debug('Cache hit for crypto operation: $operationKey');
      }
      return result;
    } catch (e) {
      SignalLogger.warning('Failed to get cached crypto operation: $e');
      return null;
    }
  }

  /// Invalidate cache for a specific user
  void invalidateUser(String userId) {
    try {
      _identityKeyCache.remove(userId);
      _firebaseKeyCache.remove(userId);
      
      // Remove all prekey bundles and sessions for this user
      final keysToRemove = <String>[];
      
      _preKeyBundleCache.keys.where((key) => key.startsWith('$userId:')).forEach(keysToRemove.add);
      _sessionCache.keys.where((key) => key.startsWith('$userId:')).forEach(keysToRemove.add);
      
      for (final key in keysToRemove) {
        _preKeyBundleCache.remove(key);
        _sessionCache.remove(key);
      }
      
      SignalLogger.info('Invalidated cache for user: $userId');
    } catch (e) {
      SignalLogger.warning('Failed to invalidate cache for user: $e');
    }
  }

  /// Clear all caches
  void clearAll() {
    try {
      _identityKeyCache.clear();
      _preKeyBundleCache.clear();
      _sessionCache.clear();
      _firebaseKeyCache.clear();
      _cryptoCache.clear();
      SignalLogger.info('Cleared all performance caches');
    } catch (e) {
      SignalLogger.warning('Failed to clear caches: $e');
    }
  }

  /// Get cache statistics
  CacheStatistics getStatistics() {
    return CacheStatistics(
      identityKeyCacheSize: _identityKeyCache.length,
      identityKeyCacheHits: _identityKeyCache.hits,
      identityKeyCacheMisses: _identityKeyCache.misses,
      preKeyBundleCacheSize: _preKeyBundleCache.length,
      preKeyBundleCacheHits: _preKeyBundleCache.hits,
      preKeyBundleCacheMisses: _preKeyBundleCache.misses,
      sessionCacheSize: _sessionCache.length,
      sessionCacheHits: _sessionCache.hits,
      sessionCacheMisses: _sessionCache.misses,
      firebaseKeyCacheSize: _firebaseKeyCache.length,
      firebaseKeyCacheHits: _firebaseKeyCache.hits,
      firebaseKeyCacheMisses: _firebaseKeyCache.misses,
      cryptoCacheSize: _cryptoCache.length,
      cryptoCacheHits: _cryptoCache.hits,
      cryptoCacheMisses: _cryptoCache.misses,
    );
  }
}

/// LRU Cache implementation
class LRUCache<K, V> {
  LRUCache({required this.maxSize});

  final int maxSize;
  final _cache = <K, V>{};
  final _order = Queue<K>();
  
  int _hits = 0;
  int _misses = 0;

  /// Number of cache hits
  int get hits => _hits;
  
  /// Number of cache misses
  int get misses => _misses;
  
  /// Current cache size
  int get length => _cache.length;
  
  /// Get all keys
  Iterable<K> get keys => _cache.keys;

  /// Put a value in the cache
  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      // Move to end (most recently used)
      _order.remove(key);
      _order.addLast(key);
      _cache[key] = value;
    } else {
      // Add new entry
      if (_cache.length >= maxSize) {
        // Remove least recently used
        final lru = _order.removeFirst();
        _cache.remove(lru);
      }
      _cache[key] = value;
      _order.addLast(key);
    }
  }

  /// Get a value from the cache
  V? get(K key) {
    if (_cache.containsKey(key)) {
      // Move to end (most recently used)
      _order.remove(key);
      _order.addLast(key);
      _hits++;
      return _cache[key];
    } else {
      _misses++;
      return null;
    }
  }

  /// Remove a value from the cache
  void remove(K key) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
      _order.remove(key);
    }
  }

  /// Clear the cache
  void clear() {
    _cache.clear();
    _order.clear();
    _hits = 0;
    _misses = 0;
  }
}

/// Cache statistics
class CacheStatistics {
  const CacheStatistics({
    required this.identityKeyCacheSize,
    required this.identityKeyCacheHits,
    required this.identityKeyCacheMisses,
    required this.preKeyBundleCacheSize,
    required this.preKeyBundleCacheHits,
    required this.preKeyBundleCacheMisses,
    required this.sessionCacheSize,
    required this.sessionCacheHits,
    required this.sessionCacheMisses,
    required this.firebaseKeyCacheSize,
    required this.firebaseKeyCacheHits,
    required this.firebaseKeyCacheMisses,
    required this.cryptoCacheSize,
    required this.cryptoCacheHits,
    required this.cryptoCacheMisses,
  });

  final int identityKeyCacheSize;
  final int identityKeyCacheHits;
  final int identityKeyCacheMisses;
  final int preKeyBundleCacheSize;
  final int preKeyBundleCacheHits;
  final int preKeyBundleCacheMisses;
  final int sessionCacheSize;
  final int sessionCacheHits;
  final int sessionCacheMisses;
  final int firebaseKeyCacheSize;
  final int firebaseKeyCacheHits;
  final int firebaseKeyCacheMisses;
  final int cryptoCacheSize;
  final int cryptoCacheHits;
  final int cryptoCacheMisses;

  /// Calculate hit rate for identity keys
  double get identityKeyHitRate {
    final total = identityKeyCacheHits + identityKeyCacheMisses;
    return total > 0 ? identityKeyCacheHits / total : 0.0;
  }

  /// Calculate hit rate for prekey bundles
  double get preKeyBundleHitRate {
    final total = preKeyBundleCacheHits + preKeyBundleCacheMisses;
    return total > 0 ? preKeyBundleCacheHits / total : 0.0;
  }

  /// Calculate hit rate for sessions
  double get sessionHitRate {
    final total = sessionCacheHits + sessionCacheMisses;
    return total > 0 ? sessionCacheHits / total : 0.0;
  }

  /// Calculate hit rate for Firebase keys
  double get firebaseKeyHitRate {
    final total = firebaseKeyCacheHits + firebaseKeyCacheMisses;
    return total > 0 ? firebaseKeyCacheHits / total : 0.0;
  }

  /// Calculate hit rate for crypto operations
  double get cryptoHitRate {
    final total = cryptoCacheHits + cryptoCacheMisses;
    return total > 0 ? cryptoCacheHits / total : 0.0;
  }

  /// Calculate overall hit rate
  double get overallHitRate {
    final totalHits = identityKeyCacheHits + preKeyBundleCacheHits + sessionCacheHits + firebaseKeyCacheHits + cryptoCacheHits;
    final totalMisses = identityKeyCacheMisses + preKeyBundleCacheMisses + sessionCacheMisses + firebaseKeyCacheMisses + cryptoCacheMisses;
    final total = totalHits + totalMisses;
    return total > 0 ? totalHits / total : 0.0;
  }

  @override
  String toString() {
    return 'CacheStatistics{\n'
        '  identityKeys: $identityKeyCacheSize items, ${(identityKeyHitRate * 100).toStringAsFixed(1)}% hit rate\n'
        '  preKeyBundles: $preKeyBundleCacheSize items, ${(preKeyBundleHitRate * 100).toStringAsFixed(1)}% hit rate\n'
        '  sessions: $sessionCacheSize items, ${(sessionHitRate * 100).toStringAsFixed(1)}% hit rate\n'
        '  firebaseKeys: $firebaseKeyCacheSize items, ${(firebaseKeyHitRate * 100).toStringAsFixed(1)}% hit rate\n'
        '  cryptoOps: $cryptoCacheSize items, ${(cryptoHitRate * 100).toStringAsFixed(1)}% hit rate\n'
        '  overall: ${(overallHitRate * 100).toStringAsFixed(1)}% hit rate\n'
        '}';
  }
}
