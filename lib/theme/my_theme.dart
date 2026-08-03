import 'package:flutter/material.dart';

import 'app_theme.dart';

/// @deprecated Use [AppTheme] via MaterialApp theme.
class MyThemes {
  static ThemeData get lightTheme => AppTheme.light();
  static ThemeData get darkTheme => AppTheme.dark();
}
