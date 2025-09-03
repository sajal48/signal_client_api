/// Hive type registration utility for Signal Protocol package
library;

import 'package:hive/hive.dart';
import 'hive_models.dart';

/// Utility class to register all Hive type adapters
class HiveRegistry {
  static bool _isRegistered = false;
  
  /// Registers all Hive type adapters for Signal Protocol package
  /// This must be called before opening any Hive boxes
  static void registerAdapters() {
    if (_isRegistered) {
      return; // Already registered, skip
    }
    
    // Register all generated type adapters
    Hive.registerAdapter(HiveSessionRecordAdapter());        // TypeId: 0
    Hive.registerAdapter(HivePreKeyRecordAdapter());         // TypeId: 1
    Hive.registerAdapter(HiveSignedPreKeyRecordAdapter());   // TypeId: 2
    Hive.registerAdapter(HiveSenderKeyRecordAdapter());      // TypeId: 3
    Hive.registerAdapter(CachedUserKeysAdapter());           // TypeId: 4
    
    _isRegistered = true;
  }
  
  /// Checks if adapters are registered
  static bool get isRegistered => _isRegistered;
  
  /// Forces re-registration (useful for testing)
  static void forceReRegister() {
    _isRegistered = false;
    registerAdapters();
  }
  
  /// Gets list of all registered type IDs
  static List<int> get registeredTypeIds => [0, 1, 2, 3, 4];
}
