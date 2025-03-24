import 'package:flutter/material.dart';

import '/core/extensions/build_content_extensions.dart';

Color colorByIconData(BuildContext context, IconData icon) {
  if (icon == Icons.edit) return Colors.blue;
  if (icon == Icons.delete) return Colors.red;
  return context.colorScheme.onSurface;
}

Widget actionIcon({
  required BuildContext context,
  required IconData icon,
  required String text,
  required Function() onPressed,
}) {
  final color = colorByIconData(context, icon);
  return context.isMobile
      ? IconButton(onPressed: onPressed, icon: Icon(icon, color: colorByIconData(context, icon)))
      : TextButton.icon(
        onPressed: onPressed,
        label: Text(text, style: TextStyle(color: color)),
        icon: Icon(icon, color: color),
      );
}
