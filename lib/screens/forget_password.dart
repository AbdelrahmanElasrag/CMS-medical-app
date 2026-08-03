import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../ui/mobadra_motion.dart';
import '../ui/mobadra_surface.dart';
import '../widgets/custom_scaffold.dart';

class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ShadTheme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return CustomScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset + 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: MobadraAuthSheet(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Reset password',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                      ).mobadraFadeSlide(),
                      const SizedBox(height: 16),
                      Text(
                        'Contact support or use the sign-in screen if your clinic enabled self-service recovery.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.mutedForeground,
                              height: 1.35,
                            ),
                      ).mobadraFadeSlide(delayMs: 40),
                      const SizedBox(height: 28),
                      ShadButton.outline(
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: const Text('Back'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
