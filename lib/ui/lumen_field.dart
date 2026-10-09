import 'package:flutter/material.dart';

import 'package:cms/theme/concierge_theme.dart';

/// Flat editorial canvas behind the member shell and splash.
class LumenField extends StatelessWidget {
  const LumenField({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(color: EditorialPalette.canvas);
  }
}
