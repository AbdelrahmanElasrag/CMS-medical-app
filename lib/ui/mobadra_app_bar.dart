import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_tokens.dart';

/// App bar styling aligned with the home tab header (primary blue, white text, bottom hairline + shadow).
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

  static Color backgroundColorFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF003D7A)
        : AppColors.primary;
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColorFor(context);
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        );

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AppBar(
        toolbarHeight: toolbarHeight,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white.withValues(alpha: 0.95)),
        actionsIconTheme: IconThemeData(color: Colors.white.withValues(alpha: 0.95)),
        titleTextStyle: titleStyle,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: bg,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        centerTitle: centerTitle,
        leading: leading,
        title: DefaultTextStyle.merge(
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: titleStyle?.fontSize ?? 20),
          child: IconTheme.merge(
            data: IconThemeData(color: Colors.white.withValues(alpha: 0.95), size: 24),
            child: title,
          ),
        ),
        actions: actions,
      ),
    );
  }
}
