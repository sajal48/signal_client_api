/// Firebase data migration utilities
library;

import '../exceptions/signal_exceptions.dart';
import '../utils/logger.dart';
import '../utils/validators.dart';
import 'firebase_config.dart';
import 'firebase_schema_validator.dart';

/// Handles Firebase data migrations and integrity checks
class FirebaseMigrationManager {
  
  /// Current schema version
  static const int currentSchemaVersion = 1;
  
  /// Schema version path in Firebase
  static const String schemaVersionPath = 'signal_protocol/schema_version';
  
  /// Get current schema version from Firebase
  static Future<int> getCurrentSchemaVersion() async {
    try {
      final ref = FirebaseConfig.database.ref(schemaVersionPath);
      final snapshot = await ref.get();
      
      if (!snapshot.exists) {
        SignalLogger.info('No schema version found, assuming version 0');
        return 0;
      }
      
      final version = snapshot.value as int? ?? 0;
      SignalLogger.info('Current Firebase schema version: $version');
      return version;
    } catch (e) {
      SignalLogger.error('Failed to get schema version: $e');
      throw FirebaseException(message: 'Failed to get schema version: $e');
    }
  }
  
  /// Set schema version in Firebase
  static Future<void> setSchemaVersion(int version) async {
    try {
      final ref = FirebaseConfig.database.ref(schemaVersionPath);
      await ref.set(version);
      
      SignalLogger.info('Schema version set to: $version');
    } catch (e) {
      SignalLogger.error('Failed to set schema version: $e');
      throw FirebaseException(message: 'Failed to set schema version: $e');
    }
  }
  
  /// Check if migration is needed
  static Future<bool> isMigrationNeeded() async {
    final currentVersion = await getCurrentSchemaVersion();
    final migrationNeeded = currentVersion < currentSchemaVersion;
    
    if (migrationNeeded) {
      SignalLogger.info('Migration needed: $currentVersion -> $currentSchemaVersion');
    } else {
      SignalLogger.info('No migration needed, schema is up to date');
    }
    
    return migrationNeeded;
  }
  
  /// Perform data migration if needed
  static Future<void> migrateIfNeeded() async {
    try {
      final isNeeded = await isMigrationNeeded();
      if (!isNeeded) {
        return;
      }
      
      final currentVersion = await getCurrentSchemaVersion();
      
      SignalLogger.info('Starting migration from version $currentVersion to $currentSchemaVersion');
      
      // Perform version-specific migrations
      for (int version = currentVersion + 1; version <= currentSchemaVersion; version++) {
        await _performMigration(version);
      }
      
      // Update schema version
      await setSchemaVersion(currentSchemaVersion);
      
      SignalLogger.info('Migration completed successfully');
    } catch (e) {
      SignalLogger.error('Migration failed: $e');
      throw FirebaseException(message: 'Migration failed: $e');
    }
  }
  
  /// Perform migration for a specific version
  static Future<void> _performMigration(int toVersion) async {
    SignalLogger.info('Migrating to version $toVersion');
    
    switch (toVersion) {
      case 1:
        await _migrateToVersion1();
        break;
      default:
        throw FirebaseException(
          message: 'Unknown migration version: $toVersion',
        );
    }
  }
  
  /// Migration to version 1 - initial schema setup
  static Future<void> _migrateToVersion1() async {
    SignalLogger.info('Performing migration to version 1 (initial schema)');
    
    // For initial migration, we just need to validate the structure
    // In a real migration, this might involve restructuring existing data
    
    // Create any necessary initial data structures
    final updates = <String, dynamic>{
      'signal_protocol/metadata/created_at': DateTime.now().millisecondsSinceEpoch,
      'signal_protocol/metadata/version': 1,
    };
    
    await FirebaseConfig.database.ref().update(updates);
    
    SignalLogger.info('Version 1 migration completed');
  }
  
  /// Validate data integrity across all user data
  static Future<bool> validateDataIntegrity({
    List<String>? userIds,
    bool fixErrors = false,
  }) async {
    try {
      SignalLogger.info('Starting data integrity validation');
      
      bool allValid = true;
      int validatedCount = 0;
      int errorCount = 0;
      final errors = <String>[];
      
      if (userIds != null && userIds.isNotEmpty) {
        // Validate specific users
        for (final userId in userIds) {
          final result = await _validateUserData(userId, fixErrors: fixErrors);
          if (!result) {
            allValid = false;
            errorCount++;
            errors.add('User $userId has invalid data');
          }
          validatedCount++;
        }
      } else {
        // Validate all users
        final usersRef = FirebaseConfig.database.ref('signal_protocol/users');
        final snapshot = await usersRef.get();
        
        if (snapshot.exists) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          
          for (final userId in data.keys) {
            final result = await _validateUserData(userId, fixErrors: fixErrors);
            if (!result) {
              allValid = false;
              errorCount++;
              errors.add('User $userId has invalid data');
            }
            validatedCount++;
          }
        }
      }
      
      SignalLogger.info(
        'Data integrity validation completed: '
        '$validatedCount users validated, '
        '$errorCount errors found'
      );
      
      if (errors.isNotEmpty) {
        SignalLogger.error('Validation errors: ${errors.join(', ')}');
      }
      
      return allValid;
    } catch (e) {
      SignalLogger.error('Data integrity validation failed: $e');
      throw FirebaseException(message: 'Data integrity validation failed: $e');
    }
  }
  
  /// Validate data for a specific user
  static Future<bool> _validateUserData(String userId, {bool fixErrors = false}) async {
    try {
      Validators.validateUserId(userId);
      
      final userRef = FirebaseConfig.database.ref(
        FirebaseConfig.userPath(userId)
      );
      final snapshot = await userRef.get();
      
      if (!snapshot.exists) {
        SignalLogger.info('No data found for user: $userId');
        return true; // No data is not an error
      }
      
      final userData = Map<String, dynamic>.from(snapshot.value as Map);
      bool isValid = true;
      
      // Validate identity key
      if (userData.containsKey('identity_key')) {
        try {
          FirebaseSchemaValidator.validateIdentityKey(
            Map<String, dynamic>.from(userData['identity_key'] as Map)
          );
        } catch (e) {
          SignalLogger.error('Invalid identity key for user $userId: $e');
          isValid = false;
          
          if (fixErrors) {
            await _fixIdentityKeyData(userId, userData['identity_key'] as Map);
          }
        }
      }
      
      // Validate registration ID
      if (userData.containsKey('registration_id')) {
        try {
          FirebaseSchemaValidator.validateRegistrationId(
            Map<String, dynamic>.from(userData['registration_id'] as Map)
          );
        } catch (e) {
          SignalLogger.error('Invalid registration ID for user $userId: $e');
          isValid = false;
          
          if (fixErrors) {
            await _fixRegistrationIdData(userId, userData['registration_id'] as Map);
          }
        }
      }
      
      // Validate signed prekey
      if (userData.containsKey('signed_prekey')) {
        try {
          FirebaseSchemaValidator.validateSignedPreKey(
            Map<String, dynamic>.from(userData['signed_prekey'] as Map)
          );
        } catch (e) {
          SignalLogger.error('Invalid signed prekey for user $userId: $e');
          isValid = false;
          
          if (fixErrors) {
            await _fixSignedPreKeyData(userId, userData['signed_prekey'] as Map);
          }
        }
      }
      
      // Validate prekeys
      if (userData.containsKey('prekeys')) {
        final prekeys = Map<String, dynamic>.from(userData['prekeys'] as Map);
        for (final entry in prekeys.entries) {
          try {
            FirebaseSchemaValidator.validatePreKey(
              Map<String, dynamic>.from(entry.value as Map)
            );
          } catch (e) {
            SignalLogger.error('Invalid prekey ${entry.key} for user $userId: $e');
            isValid = false;
            
            if (fixErrors) {
              await _fixPreKeyData(userId, entry.key, entry.value as Map);
            }
          }
        }
      }
      
      // Validate metadata
      if (userData.containsKey('metadata')) {
        try {
          FirebaseSchemaValidator.validateUserMetadata(
            Map<String, dynamic>.from(userData['metadata'] as Map)
          );
        } catch (e) {
          SignalLogger.error('Invalid metadata for user $userId: $e');
          isValid = false;
          
          if (fixErrors) {
            await _fixMetadataData(userId, userData['metadata'] as Map);
          }
        }
      }
      
      return isValid;
    } catch (e) {
      SignalLogger.error('Failed to validate user data for $userId: $e');
      return false;
    }
  }
  
  /// Fix invalid identity key data
  static Future<void> _fixIdentityKeyData(String userId, Map data) async {
    // Implementation would depend on specific corruption patterns
    SignalLogger.info('Attempting to fix identity key data for user: $userId');
    // For now, just log - in real implementation, you'd apply specific fixes
  }
  
  /// Fix invalid registration ID data
  static Future<void> _fixRegistrationIdData(String userId, Map data) async {
    SignalLogger.info('Attempting to fix registration ID data for user: $userId');
    // Implementation would depend on specific corruption patterns
  }
  
  /// Fix invalid signed prekey data
  static Future<void> _fixSignedPreKeyData(String userId, Map data) async {
    SignalLogger.info('Attempting to fix signed prekey data for user: $userId');
    // Implementation would depend on specific corruption patterns
  }
  
  /// Fix invalid prekey data
  static Future<void> _fixPreKeyData(String userId, String preKeyId, Map data) async {
    SignalLogger.info('Attempting to fix prekey $preKeyId data for user: $userId');
    // Implementation would depend on specific corruption patterns
  }
  
  /// Fix invalid metadata
  static Future<void> _fixMetadataData(String userId, Map data) async {
    SignalLogger.info('Attempting to fix metadata for user: $userId');
    // Implementation would depend on specific corruption patterns
  }
  
  /// Create backup before migration
  static Future<void> createBackup(String backupName) async {
    try {
      SignalLogger.info('Creating backup: $backupName');
      
      // Read all signal protocol data
      final ref = FirebaseConfig.database.ref('signal_protocol');
      final snapshot = await ref.get();
      
      if (snapshot.exists) {
        // Save to backup location
        final backupRef = FirebaseConfig.database.ref('backups/$backupName');
        await backupRef.set({
          'data': snapshot.value,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'schema_version': await getCurrentSchemaVersion(),
        });
        
        SignalLogger.info('Backup created successfully: $backupName');
      } else {
        SignalLogger.info('No data to backup');
      }
    } catch (e) {
      SignalLogger.error('Failed to create backup: $e');
      throw FirebaseException(message: 'Failed to create backup: $e');
    }
  }
  
  /// Restore from backup
  static Future<void> restoreFromBackup(String backupName) async {
    try {
      SignalLogger.info('Restoring from backup: $backupName');
      
      final backupRef = FirebaseConfig.database.ref('backups/$backupName');
      final snapshot = await backupRef.get();
      
      if (!snapshot.exists) {
        throw FirebaseException(message: 'Backup not found: $backupName');
      }
      
      final backupData = Map<String, dynamic>.from(snapshot.value as Map);
      final data = backupData['data'];
      
      if (data != null) {
        // Restore data
        final ref = FirebaseConfig.database.ref('signal_protocol');
        await ref.set(data);
        
        SignalLogger.info('Data restored successfully from backup: $backupName');
      } else {
        throw FirebaseException(message: 'Invalid backup data: $backupName');
      }
    } catch (e) {
      SignalLogger.error('Failed to restore from backup: $e');
      throw FirebaseException(message: 'Failed to restore from backup: $e');
    }
  }
}
