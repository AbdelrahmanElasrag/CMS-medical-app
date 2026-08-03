import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Base URL for the backend API (e.g. https://your-api.com/api/v1).
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000/api/v1',
);

const _storage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

const _tokenKey = 'cms_patient_token';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final String? body;

  ApiException(this.message, {this.statusCode, this.body});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class ApiService {
  static final ApiService _instance = ApiService._();
  static ApiService get instance => _instance;

  ApiService._();

  String get baseUrl => kApiBaseUrl;

  Future<String?> getToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final fromPrefs = prefs.getString(_tokenKey);
      if (fromPrefs != null && fromPrefs.isNotEmpty) return fromPrefs;
      // One-time migration from flutter_secure_storage_web (older builds).
      final legacy = await _storage.read(key: _tokenKey);
      if (legacy != null && legacy.isNotEmpty) {
        await prefs.setString(_tokenKey, legacy);
        await _storage.delete(key: _tokenKey);
        return legacy;
      }
      return null;
    }
    return _storage.read(key: _tokenKey);
  }

  Future<void> setToken(String token) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      return;
    }
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> clearToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await _storage.delete(key: _tokenKey);
      return;
    }
    await _storage.delete(key: _tokenKey);
  }

  /// Caller can set this to react to 401 (e.g. navigate to login).
  void Function()? onUnauthorized;

  Future<http.Response> request(
    String method,
    String path, {
    Map<String, String>? headers,
    Object? body,
    bool requireAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };
    if (requireAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        requestHeaders['Authorization'] = 'Bearer $token';
      }
    }
    http.Response response;
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: requestHeaders);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: requestHeaders,
            body: body != null ? (body is String ? body : jsonEncode(body)) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: requestHeaders,
            body: body != null ? (body is String ? body : jsonEncode(body)) : null,
          );
          break;
        case 'PATCH':
          response = await http.patch(
            uri,
            headers: requestHeaders,
            body: body != null ? (body is String ? body : jsonEncode(body)) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: requestHeaders);
          break;
        default:
          throw ApiException('Unsupported method: $method');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }

    if (response.statusCode == 401 && requireAuth) {
      await clearToken();
      onUnauthorized?.call();
    }

    return response;
  }

  Future<Map<String, dynamic>> getJson(String path, {bool requireAuth = true}) async {
    final res = await request('GET', path, requireAuth: requireAuth);
    return _parseJsonResponse(res, path);
  }

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic>? body, {bool requireAuth = true}) async {
    final res = await request('POST', path, body: body, requireAuth: requireAuth);
    return _parseJsonResponse(res, path);
  }

  /// POST with an explicit Bearer token (e.g. employee JWT for coordinator check-in).
  Future<Map<String, dynamic>> postJsonWithBearer(
    String path,
    Map<String, dynamic>? body,
    String bearerToken,
  ) async {
    final res = await request(
      'POST',
      path,
      body: body,
      requireAuth: false,
      headers: {'Authorization': 'Bearer $bearerToken'},
    );
    return _parseJsonResponse(res, path);
  }

  /// GET with an explicit Bearer token (e.g. employee JWT for admin endpoints).
  Future<Map<String, dynamic>> getJsonWithBearer(
    String path,
    String bearerToken,
  ) async {
    final res = await request(
      'GET',
      path,
      requireAuth: false,
      headers: {'Authorization': 'Bearer $bearerToken'},
    );
    return _parseJsonResponse(res, path);
  }

  /// DELETE with an explicit Bearer token (e.g. employee JWT for admin endpoints).
  Future<Map<String, dynamic>> deleteJsonWithBearer(
    String path,
    String bearerToken,
  ) async {
    final res = await request(
      'DELETE',
      path,
      requireAuth: false,
      headers: {'Authorization': 'Bearer $bearerToken'},
    );
    return _parseJsonResponse(res, path);
  }

  /// PUT with an explicit Bearer token.
  Future<Map<String, dynamic>> putJsonWithBearer(
    String path,
    Map<String, dynamic>? body,
    String bearerToken,
  ) async {
    final res = await request(
      'PUT',
      path,
      body: body,
      requireAuth: false,
      headers: {'Authorization': 'Bearer $bearerToken'},
    );
    return _parseJsonResponse(res, path);
  }

  /// PATCH with an explicit Bearer token.
  Future<Map<String, dynamic>> patchJsonWithBearer(
    String path,
    Map<String, dynamic>? body,
    String bearerToken,
  ) async {
    final res = await request(
      'PATCH',
      path,
      body: body,
      requireAuth: false,
      headers: {'Authorization': 'Bearer $bearerToken'},
    );
    return _parseJsonResponse(res, path);
  }

  static Map<String, dynamic> _parseJsonResponse(http.Response res, String path) {
    final body = res.body.trim().isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (body is Map<String, dynamic>) return body;
      return {'data': body};
    }
    final message = body is Map ? (body['message'] ?? body['error'] ?? res.body) : res.body;
    throw ApiException(
      message is String ? message : 'Request failed',
      statusCode: res.statusCode,
      body: res.body,
    );
  }
}
