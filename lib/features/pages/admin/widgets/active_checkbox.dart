import 'package:flutter/material.dart';

import '/app/locale.dart';
import '/core/widgets/space.dart';

Row activeCheckbox({
  required bool isActive,
  required Function(bool) onChanged,
  required Color? textColor,
}) => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Checkbox(
      value: isActive,
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    ),
    sbW1,
    Builder(
      builder: (context) {
        return Text(context.tr(I18nKeys.active), style: TextStyle(color: textColor));
      },
    ),
  ],
);
