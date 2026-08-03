import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// EndlessMedical REST client (v1/dx).
/// Public flow often works **without** an API key; if you have one, pass `--dart-define=ENDLESS_MEDICAL_API_KEY=...`
/// and it is sent as `Authorization: Bearer <key>` for direct (non-proxy) calls only.
class EndlessMedicalService {
  EndlessMedicalService({Dio? dio}) : _dio = dio ?? _createDio();

  static const String termsPassphrase =
      'I have read, understood and I accept and agree to comply with the Terms of Use of EndlessMedicalAPI and Endless Medical services. The Terms of Use are available on endlessmedical.com';

  static const String _apiKey = String.fromEnvironment('ENDLESS_MEDICAL_API_KEY', defaultValue: '');
  static const String _directBaseUrl = String.fromEnvironment(
    'ENDLESS_MEDICAL_BASE_URL',
    defaultValue: 'https://api-prod.endlessmedical.com/v1/dx/',
  );
  static const String _backendBaseUrl = String.fromEnvironment(
    'CMS_BACKEND_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  final Dio _dio;

  static String _cmsBackendOriginFromApiBaseUrl() {
    // ApiService uses `API_BASE_URL` like `http://HOST:8000/api/v1`.
    // We only need the origin (`http://HOST:8000`) to reach our backend proxy.
    const apiBase = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    final trimmed = apiBase.trim();
    if (trimmed.isEmpty) return '';
    try {
      final uri = Uri.parse(trimmed);
      if (!uri.hasScheme || uri.host.isEmpty) return '';
      return uri.origin;
    } catch (_) {
      return '';
    }
  }

  static Dio _createDio() {
    final baseUrl = kIsWeb
        ? '${_backendBaseUrl.replaceAll(RegExp(r'/+$'), '')}/api/v1/health/endlessmedical/'
        : () {
            // Android/iOS: prefer backend proxy to avoid device-side TLS interception issues.
            final fromApi = _cmsBackendOriginFromApiBaseUrl();
            if (fromApi.isNotEmpty) {
              return '$fromApi/api/v1/health/endlessmedical/';
            }
            final fromDefine = _backendBaseUrl.replaceAll(RegExp(r'/+$'), '');
            if (fromDefine.isNotEmpty) {
              return '$fromDefine/api/v1/health/endlessmedical/';
            }
            return _directBaseUrl;
          }();
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 25),
        receiveTimeout: const Duration(seconds: 45),
        headers: <String, dynamic>{
          'Accept': 'application/json',
        },
      ),
    );
    // API key should live on the backend proxy in dev; don't attach client-side keys when proxying.
    final isProxy = baseUrl.contains('/api/v1/health/endlessmedical/');
    if (!isProxy && _apiKey.isNotEmpty) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.headers['Authorization'] = 'Bearer $_apiKey';
            return handler.next(options);
          },
        ),
      );
    }
    return dio;
  }

  Future<String> initSession() async {
    final res = await _request(() => _dio.get<dynamic>('InitSession'));
    final data = _asMap(res.data);
    if (data['status']?.toString() != 'ok') {
      throw EndlessMedicalException('InitSession failed: ${data['status']}');
    }
    final id = data['SessionID']?.toString();
    if (id == null || id.isEmpty) {
      throw EndlessMedicalException('InitSession missing SessionID');
    }
    return id;
  }

  Future<void> acceptTermsOfUse(String sessionId) async {
    final res = await _request(
      () => _dio.post<dynamic>(
        'AcceptTermsOfUse',
        data: const <String, dynamic>{},
        queryParameters: <String, dynamic>{
          'SessionID': sessionId,
          'passphrase': termsPassphrase,
        },
      ),
    );
    final data = _asMap(res.data);
    if (data['status']?.toString() != 'ok') {
      throw EndlessMedicalException('AcceptTermsOfUse failed: ${data['status']}');
    }
  }

  Future<void> updateFeature(String sessionId, String name, String value) async {
    final res = await _request(
      () => _dio.post<dynamic>(
        'UpdateFeature',
        data: const <String, dynamic>{},
        queryParameters: <String, dynamic>{
          'SessionID': sessionId,
          'name': name,
          'value': value,
        },
      ),
    );
    final data = _asMap(res.data);
    if (data['status']?.toString() != 'ok') {
      throw EndlessMedicalException('UpdateFeature failed for $name: ${data['status']}');
    }
  }

  Future<void> deleteFeature(String sessionId, String name) async {
    final res = await _request(
      () => _dio.post<dynamic>(
        'DeleteFeature',
        data: const <String, dynamic>{},
        queryParameters: <String, dynamic>{
          'SessionID': sessionId,
          'name': name,
        },
      ),
    );
    final data = _asMap(res.data);
    if (data['status']?.toString() != 'ok') {
      throw EndlessMedicalException('DeleteFeature failed for $name: ${data['status']}');
    }
  }

  /// Full [Analyze] payload for flexible parsing (triage fields vary by API version).
  Future<Map<String, dynamic>> analyze(String sessionId, {int numberOfResults = 12}) async {
    final res = await _request(
      () => _dio.get<dynamic>(
        'Analyze',
        queryParameters: <String, dynamic>{
          'SessionID': sessionId,
          'NumberOfResults': numberOfResults,
        },
      ),
    );
    final data = _asMap(res.data);
    if (data['status']?.toString() != 'ok') {
      throw EndlessMedicalException('Analyze failed: ${data['status']}');
    }
    return Map<String, dynamic>.from(data);
  }

  Future<Response<dynamic>> _request(Future<Response<dynamic>> Function() call) async {
    try {
      return await call();
    } on DioException catch (e, st) {
      if (_isRetryable(e)) {
        await Future<void>.delayed(const Duration(milliseconds: 400));
        try {
          return await call();
        } on DioException catch (e2) {
          throw _mapError(e2, st);
        }
      }
      throw _mapError(e, st);
    }
  }

  static bool _isRetryable(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError;
  }

  Exception _mapError(DioException e, StackTrace st) {
    if (e.response?.statusCode == 401) {
      return EndlessMedicalException('Unauthorized (check API key)', cause: e, stackTrace: st);
    }

    final rawMsg = '${e.message ?? ''} ${e.error ?? ''}'.trim();
    final blob = rawMsg.toLowerCase();
    final looksLikeTls =
        e.type == DioExceptionType.badCertificate ||
        blob.contains('handshake') ||
        blob.contains('certificate') ||
        blob.contains('cert');

    if (kIsWeb && _isLikelyWebBrowserNetworkBlock(e)) {
      return EndlessMedicalException(
        'Symptom check cannot reach the medical service from a web browser. '
        'Browsers block many cross-site API calls for security. '
        'Use the Mobadra app on Android or iPhone, or ask your team to add a small backend proxy that calls EndlessMedical and allows your web origin (CORS).',
        cause: e,
        stackTrace: st,
      );
    }

    if (!kIsWeb && looksLikeTls) {
      return EndlessMedicalException(
        'Network security blocked the symptom check (TLS/certificate issue). '
        'Try switching networks (mobile data / hotspot) or disabling HTTPS inspection on your network.',
        cause: e,
        stackTrace: st,
      );
    }

    final msg = e.response?.data?.toString() ??
        (rawMsg.isNotEmpty ? rawMsg : null) ??
        'Network error';
    final extra = e.type == DioExceptionType.connectionError
        ? ' (connection error)'
        : e.type == DioExceptionType.connectionTimeout
            ? ' (timeout)'
            : e.type == DioExceptionType.receiveTimeout
                ? ' (receive timeout)'
                : '';
    return EndlessMedicalException('$msg$extra', cause: e, stackTrace: st);
  }

  /// True when the failure matches browser/XHR/CORS-style blocks (common on Flutter web).
  static bool _isLikelyWebBrowserNetworkBlock(DioException e) {
    if (e.type == DioExceptionType.connectionError) return true;
    if (e.type == DioExceptionType.badCertificate) return true;
    final blob = '${e.message} ${e.error}'.toLowerCase();
    return blob.contains('xmlhttprequest') ||
        blob.contains('xhr') ||
        blob.contains('cors') ||
        blob.contains('failed to fetch');
  }

  static Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      try {
        final decoded = json.decode(data);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return <String, dynamic>{};
  }
}

class EndlessMedicalException implements Exception {
  EndlessMedicalException(this.message, {this.cause, this.stackTrace});
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  /// Short text for UI (avoids prefixing with the exception type name).
  @override
  String toString() => message;
}
