import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cms/theme/concierge_theme.dart';

/// Flat editorial bar for interior screens. Home uses its own header.
class MobadraAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MobadraAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.toolbarHeight = kToolbarHeight,
  });

  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double toolbarHeight;

  static Color backgroundColorFor(BuildContext context) => EditorialPalette.canvas;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColorFor(context);
    final titleStyle = GoogleFonts.cormorantGaramond(
      color: EditorialPalette.headline,
      fontWeight: FontWeight.w500,
      fontSize: 26,
    );

    return Container(
      color: bg,
      child: AppBar(
        toolbarHeight: toolbarHeight,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: EditorialPalette.headline,
        iconTheme: const IconThemeData(color: EditorialPalette.headline),
        actionsIconTheme: const IconThemeData(color: EditorialPalette.headline),
        titleTextStyle: titleStyle,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        centerTitle: centerTitle,
        leading: leading,
        title: DefaultTextStyle.merge(
          style: titleStyle,
          child: IconTheme.merge(
            data: const IconThemeData(color: EditorialPalette.headline, size: 24),
            child: title,
          ),
        ),
        actions: actions,
      ),
    );
  }
}
