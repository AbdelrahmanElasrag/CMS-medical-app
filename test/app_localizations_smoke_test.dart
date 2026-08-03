import 'package:cms/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Arabic locale resolves AppLocalizations', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Scaffold(body: Text(l10n.healthAssistantTitle, textDirection: TextDirection.rtl));
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('المساعد الصحي'), findsOneWidget);
  });

  testWidgets('English locale resolves AppLocalizations', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en', 'US'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Text(AppLocalizations.of(context)!.healthAssistantTitle),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Health assistant'), findsOneWidget);
  });
}
