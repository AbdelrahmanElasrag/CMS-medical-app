// Staff / coordinator entry point.
// Build command: flutter run --flavor staff --target lib/main_staff.dart
//                flutter build apk --flavor staff --target lib/main_staff.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'l10n/app_localizations.dart';
import 'screens/services/staff_auth_gate.dart';
import 'services/locale_controller.dart';
import 'theme/app_theme.dart';
import 'theme/shadcn_mobadra_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeController = LocaleController();
  await localeController.load();
  runApp(
    ChangeNotifierProvider.value(
      value: localeController,
      child: const StaffApp(),
    ),
  );
}

class StaffApp extends StatelessWidget {
  const StaffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleController>(
      builder: (context, localeController, _) {
        return ShadApp.custom(
          themeMode: ThemeMode.light,
          theme: MobadraShadThemes.light(),
          darkTheme: MobadraShadThemes.dark(),
          appBuilder: (context) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Mobadra Staff',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: ThemeMode.light,
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
            home: const StaffAuthGate(),
          ),
        );
      },
    );
  }
}
