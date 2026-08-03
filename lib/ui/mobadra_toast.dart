import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void mobadraToast(BuildContext context, String message, {bool error = false}) {
  final title = Text(message);
  if (error) {
    ShadToaster.of(context).show(ShadToast.destructive(title: title));
  } else {
    ShadToaster.of(context).show(ShadToast(title: title));
  }
}
