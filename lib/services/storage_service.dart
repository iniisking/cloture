import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Unified storage service that uses:
/// - flutter_secure_storage for sensitive data
/// - shared_preferences for non-sensitive data
class StorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // ========== Secure Storage Methods (for sensitive data) ==========

  /// Save a string value securely
  Future<void> saveSecure(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      print('Error saving secure storage: $e');
    }
  }

  /// Read a string value securely
  Future<String?> readSecure(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      print('Error reading secure storage: $e');
      return null;
    }
  }

  /// Delete a secure value
  Future<void> deleteSecure(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      print('Error deleting secure storage: $e');
    }
  }

  /// Delete all secure values
  Future<void> deleteAllSecure() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      print('Error deleting all secure storage: $e');
    }
  }

  // ========== SharedPreferences Methods (for non-sensitive data) ==========

  /// Save a string value
  Future<bool> saveString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(key, value);
    } catch (e) {
      print('Error saving string: $e');
      return false;
    }
  }

  /// Read a string value
  Future<String?> readString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      print('Error reading string: $e');
      return null;
    }
  }

  /// Save a list of strings (for cart cache)
  Future<bool> saveStringList(String key, List<String> value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setStringList(key, value);
    } catch (e) {
      print('Error saving string list: $e');
      return false;
    }
  }

  /// Read a list of strings
  Future<List<String>?> readStringList(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(key);
    } catch (e) {
      print('Error reading string list: $e');
      return null;
    }
  }

  /// Save a boolean value
  Future<bool> saveBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(key, value);
    } catch (e) {
      print('Error saving bool: $e');
      return false;
    }
  }

  /// Read a boolean value
  Future<bool?> readBool(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key);
    } catch (e) {
      print('Error reading bool: $e');
      return null;
    }
  }

  /// Save a JSON-serializable object (as string)
  Future<bool> saveJson(String key, Map<String, dynamic> value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(value);
      return await prefs.setString(key, jsonString);
    } catch (e) {
      print('Error saving JSON: $e');
      return false;
    }
  }

  /// Read a JSON-serializable object
  Future<Map<String, dynamic>?> readJson(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error reading JSON: $e');
      return null;
    }
  }

  /// Save a list of JSON-serializable objects (for cart cache)
  Future<bool> saveJsonList(String key, List<Map<String, dynamic>> value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = value.map((item) => jsonEncode(item)).toList();
      return await prefs.setStringList(key, jsonList);
    } catch (e) {
      print('Error saving JSON list: $e');
      return false;
    }
  }

  /// Read a list of JSON-serializable objects
  Future<List<Map<String, dynamic>>?> readJsonList(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(key);
      if (jsonList == null) return null;
      return jsonList
          .map((jsonString) => jsonDecode(jsonString) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error reading JSON list: $e');
      return null;
    }
  }

  /// Delete a value
  Future<bool> delete(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(key);
    } catch (e) {
      print('Error deleting: $e');
      return false;
    }
  }

  /// Clear all values
  Future<bool> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.clear();
    } catch (e) {
      print('Error clearing: $e');
      return false;
    }
  }
}
