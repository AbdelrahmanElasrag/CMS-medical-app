import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocalePref = 'app_locale_language_code';

/// App-wide locale (English / Arabic) with persistence for RTL and copy selection.
class LocaleController extends ChangeNotifier {
  Locale _locale = const Locale('en', 'US');

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  /// Call from `main()` before `runApp` so first frame uses saved locale.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocalePref);
    if (code == 'ar') {
      _locale = const Locale('ar');
    } else {
      _locale = const Locale('en', 'US');
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    final next = locale.languageCode == 'ar' ? const Locale('ar') : const Locale('en', 'US');
    if (next == _locale) return;
    _locale = next;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocalePref, _locale.languageCode);
  }
}
