// lib/theme/my_themes.dart

import 'package:flutter/material.dart';

class MyThemes {
  static final Color _primaryColor = Color(0xFF00C896);
  static final Color _primaryColorDark = Color(0xFF00A37A);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    colorScheme: ColorScheme.light(
      primary: _primaryColor,
      secondary: _primaryColorDark,
    ),
    // You can define other properties like text themes, button themes, etc.
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1F1F1F),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    colorScheme: ColorScheme.dark(
      primary: _primaryColor,
      secondary: _primaryColorDark,
    ),
    // Define dark theme properties for text, buttons, etc.
  );
}