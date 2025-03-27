import 'package:flutter/material.dart';

import '../../../../core/extensions/num_extensions.dart';

Widget headerRowWithCreateButton({
  required String title,
  required Function() onPressed,
  required String buttonText,
  bool belowTabbar = true,
}) {
  return Container(
    padding: EdgeInsets.fromLTRB(16, belowTabbar ? 8 : 0, 16, 8),
    decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Colors.grey))),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: 6.borderRadius),
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          ),
          child: Text(buttonText),
        ),
      ],
    ),
  );
}
