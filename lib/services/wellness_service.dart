import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:cms/services/api_service.dart';
import 'package:cms/services/auth_service.dart';

const _kWaterPrefix = 'wellness_water_';
const _kWorkoutPrefix = 'wellness_workout_';
const _kMedsJson = 'wellness_meds_json';
const _kWaterGoal = 'wellness_water_goal';
const _kWorkoutGoal = 'wellness_workout_goal';

class MedReminder {
  final String id;
  final String name;
  final int hour;
  final int minute;
  /// Null = every day. 1..7 = Monday..Sunday.
  final int? weekday;

  MedReminder({
    required this.id,
    required this.name,
    required this.hour,
    required this.minute,
    this.weekday,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'hour': hour,
        'minute': minute,
        if (weekday != null) 'weekday': weekday,
      };

  factory MedReminder.fromJson(Map<String, dynamic> m) => MedReminder(
        id: m['id'] as String,
        name: m['name'] as String,
        hour: m['hour'] as int,
        minute: m['minute'] as int,
        weekday: (m['weekday'] as num?)?.toInt(),
      );
}

/// Local wellness tracking (not medical advice). Water/workout tallies + simple med reminders.
class WellnessService {
  WellnessService._();
  static final WellnessService instance = WellnessService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _inited = false;
  bool _remotePulledForScope = false;
  String _lastScope = '';
  bool _remoteAvailable = true;
  DateTime? _lastRemoteFailureAt;

  Future<void> init() async {
    if (kIsWeb) return;
    if (_inited) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    _inited = true;
  }

  String _dayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  String _scopeId() {
    final id = AuthService.instance.currentPatient?.id.trim();
    if (id != null && id.isNotEmpty) return id;
    return 'guest';
  }

  String _scoped(String base) => '${base}_${_scopeId()}';
  String _scopedDay(String prefix) => '${_scoped(prefix)}_${_dayKey()}';

  Future<void> _ensureRemotePulled() async {
    final scope = _scopeId();
    if (scope != _lastScope) {
      _lastScope = scope;
      _remotePulledForScope = false;
    }
    if (_remotePulledForScope) return;
    await _migrateLegacyLocalIfNeeded(scope);
    await _pullRemoteIntoLocal();
    _remotePulledForScope = true;
  }

  Future<void> _migrateLegacyLocalIfNeeded(String scope) async {
    final p = await SharedPreferences.getInstance();
    final marker = 'wellness_migrated_$scope';
    if (p.getBool(marker) == true) return;

    if (!p.containsKey(_scoped(_kWaterGoal)) && p.containsKey(_kWaterGoal)) {
      await p.setInt(_scoped(_kWaterGoal), p.getInt(_kWaterGoal) ?? 8);
    }
    if (!p.containsKey(_scoped(_kWorkoutGoal)) && p.containsKey(_kWorkoutGoal)) {
      await p.setInt(_scoped(_kWorkoutGoal), p.getInt(_kWorkoutGoal) ?? 30);
    }
    final legacyWaterTodayKey = '$_kWaterPrefix${_dayKey()}';
    if (!p.containsKey(_scopedDay(_kWaterPrefix)) && p.containsKey(legacyWaterTodayKey)) {
      await p.setInt(_scopedDay(_kWaterPrefix), p.getInt(legacyWaterTodayKey) ?? 0);
    }
    final legacyWorkoutTodayKey = '$_kWorkoutPrefix${_dayKey()}';
    if (!p.containsKey(_scopedDay(_kWorkoutPrefix)) && p.containsKey(legacyWorkoutTodayKey)) {
      await p.setInt(_scopedDay(_kWorkoutPrefix), p.getInt(legacyWorkoutTodayKey) ?? 0);
    }
    if (!p.containsKey(_scoped(_kMedsJson)) && p.containsKey(_kMedsJson)) {
      await p.setString(_scoped(_kMedsJson), p.getString(_kMedsJson) ?? '[]');
    }
    await p.setBool(marker, true);
  }

  bool get _canTryRemote {
    if (!_remoteAvailable) {
      final t = _lastRemoteFailureAt;
      if (t == null) return false;
      // Backoff after failure, then retry later.
      return DateTime.now().difference(t) > const Duration(minutes: 5);
    }
    return true;
  }

  Future<void> _pullRemoteIntoLocal() async {
    if (!_canTryRemote) return;
    try {
      final res = await ApiService.instance.getJson('/mobile/wellness');
      final data = (res['data'] as Map?) ?? res;
      await _applyRemoteSnapshot(Map<String, dynamic>.from(data));
      _remoteAvailable = true;
      _lastRemoteFailureAt = null;
    } catch (_) {
      _remoteAvailable = false;
      _lastRemoteFailureAt = DateTime.now();
    }
  }

  Future<void> _pushLocalToRemote() async {
    if (!_canTryRemote) return;
    try {
      final p = await SharedPreferences.getInstance();
      final waterGoal = p.getInt(_scoped(_kWaterGoal)) ?? 8;
      final workoutGoal = p.getInt(_scoped(_kWorkoutGoal)) ?? 30;
      final waterToday = p.getInt(_scopedDay(_kWaterPrefix)) ?? 0;
      final workoutToday = p.getInt(_scopedDay(_kWorkoutPrefix)) ?? 0;
      final medsRaw = p.getString(_scoped(_kMedsJson)) ?? '[]';
      final meds = (jsonDecode(medsRaw) as List<dynamic>).map((e) => Map<String, dynamic>.from(e as Map)).toList();

      final body = <String, dynamic>{
        'waterGoal': waterGoal,
        'workoutGoal': workoutGoal,
        'todayKey': _dayKey(),
        'waterToday': waterToday,
        'workoutToday': workoutToday,
        'meds': meds,
      };
      await ApiService.instance.postJson('/mobile/wellness', body);
      _remoteAvailable = true;
      _lastRemoteFailureAt = null;
    } catch (_) {
      _remoteAvailable = false;
      _lastRemoteFailureAt = DateTime.now();
    }
  }

  Future<void> _applyRemoteSnapshot(Map<String, dynamic> data) async {
    final p = await SharedPreferences.getInstance();

    final waterGoal = (data['waterGoal'] as num?)?.toInt();
    final workoutGoal = (data['workoutGoal'] as num?)?.toInt();
    if (waterGoal != null) {
      await p.setInt(_scoped(_kWaterGoal), waterGoal);
    }
    if (workoutGoal != null) {
      await p.setInt(_scoped(_kWorkoutGoal), workoutGoal);
    }

    final remoteDay = data['todayKey']?.toString();
    if (remoteDay != null && remoteDay == _dayKey()) {
      final waterToday = (data['waterToday'] as num?)?.toInt();
      final workoutToday = (data['workoutToday'] as num?)?.toInt();
      if (waterToday != null) {
        await p.setInt(_scopedDay(_kWaterPrefix), waterToday);
      }
      if (workoutToday != null) {
        await p.setInt(_scopedDay(_kWorkoutPrefix), workoutToday);
      }
    }

    if (data['meds'] is List) {
      final list = (data['meds'] as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      await p.setString(_scoped(_kMedsJson), jsonEncode(list));
    }
  }

  Future<int> getWaterGoal() async {
    await _ensureRemotePulled();
    final p = await SharedPreferences.getInstance();
    return p.getInt(_scoped(_kWaterGoal)) ?? 8;
  }

  Future<void> setWaterGoal(int g) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_scoped(_kWaterGoal), g);
    await _pushLocalToRemote();
  }

  Future<int> getWorkoutGoal() async {
    await _ensureRemotePulled();
    final p = await SharedPreferences.getInstance();
    return p.getInt(_scoped(_kWorkoutGoal)) ?? 30;
  }

  Future<void> setWorkoutGoal(int g) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_scoped(_kWorkoutGoal), g);
    await _pushLocalToRemote();
  }

  Future<int> todayWaterGlasses() async {
    await _ensureRemotePulled();
    final p = await SharedPreferences.getInstance();
    return p.getInt(_scopedDay(_kWaterPrefix)) ?? 0;
  }

  Future<void> addWaterGlass() async {
    final p = await SharedPreferences.getInstance();
    final k = _scopedDay(_kWaterPrefix);
    await p.setInt(k, (p.getInt(k) ?? 0) + 1);
    await _pushLocalToRemote();
  }

  Future<void> resetWaterToday() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_scopedDay(_kWaterPrefix));
    await _pushLocalToRemote();
  }

  Future<int> todayWorkoutMinutes() async {
    await _ensureRemotePulled();
    final p = await SharedPreferences.getInstance();
    return p.getInt(_scopedDay(_kWorkoutPrefix)) ?? 0;
  }

  Future<void> addWorkoutMinutes(int m) async {
    final p = await SharedPreferences.getInstance();
    final k = _scopedDay(_kWorkoutPrefix);
    await p.setInt(k, (p.getInt(k) ?? 0) + m);
    await _pushLocalToRemote();
  }

  Future<List<MedReminder>> loadMeds() async {
    await _ensureRemotePulled();
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_scoped(_kMedsJson));
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => MedReminder.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> saveMeds(List<MedReminder> meds) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_scoped(_kMedsJson), jsonEncode(meds.map((m) => m.toJson()).toList()));
    await _pushLocalToRemote();
  }

  Future<void> addMed(MedReminder m) async {
    final list = await loadMeds();
    list.add(m);
    await saveMeds(list);
    await init();
    await _scheduleMed(m);
  }

  Future<void> removeMed(String id) async {
    final list = await loadMeds();
    list.removeWhere((e) => e.id == id);
    await saveMeds(list);
    await _plugin.cancel(id.hashCode & 0x7fffffff);
  }

  Future<void> rescheduleAllMeds() async {
    await init();
    final list = await loadMeds();
    for (final m in list) {
      await _scheduleMed(m);
    }
  }

  Future<void> _scheduleMed(MedReminder m) async {
    if (kIsWeb) return;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'mobadra_meds',
        'Medicine reminders',
        channelDescription: 'User-configured medicine reminders',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    final now = tz.TZDateTime.now(tz.local);
    final scheduled = _nextSchedule(now, m);

    await _plugin.zonedSchedule(
      m.id.hashCode & 0x7fffffff,
      'Medicine reminder',
      m.name,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
          m.weekday == null ? DateTimeComponents.time : DateTimeComponents.dayOfWeekAndTime,
    );
  }

  tz.TZDateTime _nextSchedule(tz.TZDateTime now, MedReminder m) {
    if (m.weekday == null) {
      var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, m.hour, m.minute);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      return scheduled;
    }

    final targetWeekday = m.weekday!.clamp(DateTime.monday, DateTime.sunday);
    var daysUntil = targetWeekday - now.weekday;
    if (daysUntil < 0) daysUntil += 7;
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + daysUntil,
      m.hour,
      m.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }
    return scheduled;
  }
}
