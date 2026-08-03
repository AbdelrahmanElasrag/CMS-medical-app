import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _employeeTokenKey = 'cms_employee_jwt';
const _employeeRoleKey = 'cms_employee_role';
const _employeeIdKey = 'cms_employee_id';
const _employeeNameKey = 'cms_employee_name';

/// Stores the CMS **employee** JWT, role, id and name separately from the patient token.
class EmployeeAuthService {
  EmployeeAuthService._();
  static final EmployeeAuthService instance = EmployeeAuthService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<String?> getToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final t = prefs.getString(_employeeTokenKey);
      if (t != null && t.isNotEmpty) return t;
      final legacy = await _storage.read(key: _employeeTokenKey);
      if (legacy != null && legacy.isNotEmpty) {
        await prefs.setString(_employeeTokenKey, legacy);
        await _storage.delete(key: _employeeTokenKey);
        return legacy;
      }
      return null;
    }
    return _storage.read(key: _employeeTokenKey);
  }

  Future<String?> getRole() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_employeeRoleKey);
    }
    return _storage.read(key: _employeeRoleKey);
  }

  Future<String?> getUserId() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_employeeIdKey);
    }
    return _storage.read(key: _employeeIdKey);
  }

  Future<String?> getName() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_employeeNameKey);
    }
    return _storage.read(key: _employeeNameKey);
  }

  /// Persists the JWT, staff role, employee id, and display name together.
  Future<void> setSession(String token, String role, String id, String name) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_employeeTokenKey, token);
      await prefs.setString(_employeeRoleKey, role);
      await prefs.setString(_employeeIdKey, id);
      await prefs.setString(_employeeNameKey, name);
      return;
    }
    await _storage.write(key: _employeeTokenKey, value: token);
    await _storage.write(key: _employeeRoleKey, value: role);
    await _storage.write(key: _employeeIdKey, value: id);
    await _storage.write(key: _employeeNameKey, value: name);
  }

  Future<void> setToken(String token) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_employeeTokenKey, token);
      return;
    }
    await _storage.write(key: _employeeTokenKey, value: token);
  }

  Future<void> clear() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_employeeTokenKey);
      await prefs.remove(_employeeRoleKey);
      await prefs.remove(_employeeIdKey);
      await prefs.remove(_employeeNameKey);
      await _storage.delete(key: _employeeTokenKey);
      await _storage.delete(key: _employeeRoleKey);
      await _storage.delete(key: _employeeIdKey);
      await _storage.delete(key: _employeeNameKey);
      return;
    }
    await _storage.delete(key: _employeeTokenKey);
    await _storage.delete(key: _employeeRoleKey);
    await _storage.delete(key: _employeeIdKey);
    await _storage.delete(key: _employeeNameKey);
  }
}
