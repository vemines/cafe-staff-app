import 'package:flutter/material.dart';

import '/core/extensions/num_extensions.dart';
import '/core/widgets/space.dart';

OutlinedButton selectButton({
  required VoidCallback onPressed,
  required String text,
  double minWidth = 150,
}) => OutlinedButton(
  onPressed: onPressed,
  style: TextButton.styleFrom(
    minimumSize: Size(minWidth, 50),
    shape: RoundedRectangleBorder(borderRadius: 8.borderRadius, side: BorderSide(width: 4)),
  ),
  child: Padding(padding: eiAll1, child: Text(text, textAlign: TextAlign.center)),
);
