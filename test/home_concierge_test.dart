import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:cms/screens/concierge_screen.dart';
import 'package:cms/screens/main_shell.dart';
import 'package:cms/services/auth_service.dart';
import 'package:cms/theme/app_theme.dart';
import 'package:cms/theme/shadcn_mobadra_theme.dart';
import 'package:cms/ui/concierge/concierge_nav_bar.dart';

void main() {
  testWidgets('guest home follows the editorial luxury layout', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthService>.value(
        value: AuthService.instance,
        child: MaterialApp(
          theme: AppTheme.light(),
          builder: (context, child) => ShadTheme(
            data: MobadraShadThemes.light(),
            child: child ?? const SizedBox.shrink(),
          ),
          home: const MainShell(username: 'Guest', points: 0),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('CMS'), findsOneWidget);
    expect(find.text('Exceptional care, beautifully simple.'), findsOneWidget);
    expect(find.text('Concierge healthcare for a healthier tomorrow.'), findsOneWidget);
    expect(find.text('Book a visit'), findsOneWidget);
    expect(find.text('Upcoming appointment'), findsOneWidget);
    expect(find.text('No upcoming visits'), findsOneWidget);
    expect(find.text('Your personal healthcare assistant'), findsOneWidget);
    expect(find.text('Check in faster'), findsNothing);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Appointments'), findsWidgets);
    expect(find.text('More'), findsOneWidget);
    expect(find.text('Offers'), findsNothing);
    expect(find.text('Book'), findsNothing);

    await tester.tap(
      find.descendant(
        of: find.byType(ConciergeNavBar),
        matching: find.text('Concierge'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Your rewards'), findsOneWidget);
    expect(find.text('0 of 1000 toward your next reward'), findsOneWidget);

    final conciergeScroll = find.descendant(
      of: find.byType(ConciergeScreen),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('Hydration'),
      280,
      scrollable: conciergeScroll,
    );
    expect(find.text('Transportation', skipOffstage: false), findsOneWidget);
    expect(find.text('On-site coordinators', skipOffstage: false), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
}
