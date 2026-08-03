import 'package:flutter/foundation.dart';
import 'api_service.dart';

class PatientProfile {
  final String id;
  final String nameEnglish;
  final String nameArabic;
  final String phoneNumber;
  final int points;
  final String? profileImageUrl;

  PatientProfile({
    required this.id,
    required this.nameEnglish,
    required this.nameArabic,
    required this.phoneNumber,
    required this.points,
    this.profileImageUrl,
  });

  String get displayName => nameEnglish.isNotEmpty ? nameEnglish : nameArabic;

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'] as String? ?? '',
      nameEnglish: json['nameEnglish'] as String? ?? '',
      nameArabic: json['nameArabic'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;

  AuthService._() {
    ApiService.instance.onUnauthorized = () {
      _currentPatient = null;
      notifyListeners();
    };
  }

  PatientProfile? _currentPatient;
  PatientProfile? get currentPatient => _currentPatient;
  bool get isLoggedIn => _currentPatient != null;

  Future<void> _loadMe() async {
    try {
      final res = await ApiService.instance.getJson('/mobile/patient/me');
      final data = res['data'];
      if (data != null && data['patient'] != null) {
        _currentPatient = PatientProfile.fromJson(Map<String, dynamic>.from(data['patient'] as Map));
        notifyListeners();
      }
    } catch (_) {
      _currentPatient = null;
      notifyListeners();
    }
  }

  /// Login with phone and password. On success stores token and loads profile.
  Future<void> login(String phone, String password) async {
    final res = await ApiService.instance.postJson(
      '/mobile/patient/login',
      {'phone': phone.trim(), 'password': password},
      requireAuth: false,
    );
    if (res['success'] != true) {
      throw ApiException(res['message'] as String? ?? 'Login failed');
    }
    final data = res['data'] as Map<String, dynamic>?;
    if (data == null) throw ApiException('Invalid response');
    final token = data['accessToken'] as String?;
    if (token == null || token.isEmpty) throw ApiException('No token received');
    await ApiService.instance.setToken(token);
    final patient = data['patient'] as Map<String, dynamic>?;
    if (patient != null) {
      _currentPatient = PatientProfile.fromJson(patient);
    } else {
      await _loadMe();
    }
    notifyListeners();
  }

  /// Signup. On success stores token and loads profile.
  Future<void> signup({
    required String name,
    required String phone,
    required String nationalId,
    required String password,
    String? dob,
    String? gender,
    String? nationality,
  }) async {
    final body = <String, dynamic>{
      'name': name.trim(),
      'nameEnglish': name.trim(),
      'nameArabic': name.trim(),
      'phone': phone.trim(),
      'nationalId': nationalId.trim(),
      'password': password,
    };
    if (dob != null && dob.isNotEmpty) body['dob'] = dob;
    if (gender != null && gender.isNotEmpty) body['gender'] = gender;
    if (nationality != null && nationality.isNotEmpty) body['nationality'] = nationality;

    final res = await ApiService.instance.postJson(
      '/mobile/patient/signup',
      body,
      requireAuth: false,
    );
    if (res['success'] != true) {
      throw ApiException(res['message'] as String? ?? 'Signup failed');
    }
    final data = res['data'] as Map<String, dynamic>?;
    if (data == null) throw ApiException('Invalid response');
    final token = data['accessToken'] as String?;
    if (token == null || token.isEmpty) throw ApiException('No token received');
    await ApiService.instance.setToken(token);
    final patient = data['patient'] as Map<String, dynamic>?;
    if (patient != null) {
      _currentPatient = PatientProfile.fromJson(patient);
    } else {
      await _loadMe();
    }
    notifyListeners();
  }

  /// Logout: clear token and profile.
  Future<void> logout() async {
    await ApiService.instance.clearToken();
    _currentPatient = null;
    notifyListeners();
  }

  /// Call after app start: if token exists, validate and load profile. Returns true if logged in.
  Future<bool> restoreSession() async {
    final token = await ApiService.instance.getToken();
    if (token == null || token.isEmpty) {
      _currentPatient = null;
      notifyListeners();
      return false;
    }
    await _loadMe();
    return _currentPatient != null;
  }
}
