// lib/main.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'l10n/app_localizations.dart';
import 'screens/services/auth_gate.dart';
import 'screens/family_provider.dart';
import 'services/auth_service.dart';
import 'services/locale_controller.dart';
import 'services/wellness_service.dart';
import 'theme/app_theme.dart';
import 'theme/shadcn_mobadra_theme.dart';
import 'theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Dubai'));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
    await WellnessService.instance.init();
    await WellnessService.instance.rescheduleAllMeds();
  }

  final localeController = LocaleController();
  await localeController.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AuthService.instance),
        ChangeNotifierProvider(create: (_) => FamilyProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: localeController),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleController>(
      builder: (context, themeProvider, localeController, _) {
        return ShadApp.custom(
          themeMode: themeProvider.mode,
          theme: MobadraShadThemes.light(),
          darkTheme: MobadraShadThemes.dark(),
          appBuilder: (context) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Creative Mobadra',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.mode,
            locale: localeController.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) =>
                ShadAppBuilder(child: child ?? const SizedBox.shrink()),
            home: const AuthGate(),
          ),
        );
      },
    );
  }
}
