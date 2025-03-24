import 'dart:math' as math show min;

import 'package:flutter/material.dart';

import '/core/extensions/build_content_extensions.dart';
import '/core/widgets/space.dart';

void showCustomizeDialog(
  BuildContext context, {
  required String title,
  required Widget content,
  String cancelText = "Cancel",
  EdgeInsets contentPadding = const EdgeInsets.all(16),
  EdgeInsets actionsPadding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
  double maxWidth = 400,
  String actionText = '',
  Function()? onAction,
  bool showAction = true,
}) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          contentPadding: contentPadding,
          actionsPadding: actionsPadding,
          title: Text(title),
          content: SizedBox(width: math.min(context.width * .9, maxWidth), child: content),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(cancelText)),
            if (showAction) ...[sbW1, FilledButton(onPressed: onAction, child: Text(actionText))],
          ],
        ),
  );
}
