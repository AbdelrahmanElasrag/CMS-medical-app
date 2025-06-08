// lib/main.dart (The final, correct version)

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Import your new AuthGate
import 'screens/services/auth_gate.dart';

// Import your providers
import 'screens/family_provider.dart';
import 'screens/services/auth_services.dart';
import 'theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => FamilyProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// MyApp is now a simple, stateless widget with no logic
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Your theme setup is correct
    const Color primaryColor = Color(0xFF00C896);
    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, brightness: Brightness.light),
    );
    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, brightness: Brightness.dark),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CMS Medical Services',
      theme: lightTheme,
      darkTheme: darkTheme,

      // The starting point of the app is ALWAYS the AuthGate.
      // It will handle showing the correct screen (SignIn or Home).
      home: const AuthGate(),
    );
  }
}