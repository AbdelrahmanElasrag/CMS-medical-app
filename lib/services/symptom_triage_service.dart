import 'dart:convert';

import 'package:cms/services/api_service.dart';

/// Calls CMS backend `POST /health/symptom-triage` (Gemini + guardrails on server).
/// Returns `null` when the server is not configured (503 + GEMINI_NOT_CONFIGURED).
class SymptomTriageService {
  SymptomTriageService._();
  static final SymptomTriageService instance = SymptomTriageService._();

  /// Uses patient JWT when available (`requireAuth: true`).
  Future<Map<String, dynamic>?> requestTriage({
    required int age,
    required int genderValue,
    required Map<String, String> features,
    String? imageBase64,
    String? imageMimeType,
  }) async {
    final entries = features.entries
        .map((e) => <String, String>{'name': e.key, 'value': e.value})
        .toList();
    final body = <String, dynamic>{
      'age': age,
      'genderValue': genderValue,
      'symptomEntries': entries,
    };
    if (imageBase64 != null && imageBase64.isNotEmpty && imageMimeType != null && imageMimeType.isNotEmpty) {
      body['imageBase64'] = imageBase64;
      body['imageMimeType'] = imageMimeType;
    }

    final res = await ApiService.instance.request(
      'POST',
      '/health/symptom-triage',
      body: body,
      requireAuth: true,
    );

    if (res.statusCode == 503) {
      try {
        final m = jsonDecode(res.body);
        if (m is Map<String, dynamic> && m['code'] == 'GEMINI_NOT_CONFIGURED') {
          return null;
        }
      } catch (_) {}
      throw ApiException(
        'Symptom triage is temporarily unavailable',
        statusCode: 503,
        body: res.body,
      );
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      String msg = 'Triage request failed';
      try {
        final m = jsonDecode(res.body);
        if (m is Map && m['message'] != null) msg = m['message'].toString();
      } catch (_) {}
      throw ApiException(msg, statusCode: res.statusCode, body: res.body);
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException('Invalid triage response');
    }
    return decoded;
  }
}
