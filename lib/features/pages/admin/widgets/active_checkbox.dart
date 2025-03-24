import 'package:flutter/material.dart';

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
    Text("Active", style: TextStyle(color: textColor)),
  ],
);
