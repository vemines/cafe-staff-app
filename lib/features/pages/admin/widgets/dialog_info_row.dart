import '../../../../core/extensions/build_content_extensions.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/space.dart';

Widget infoRow(BuildContext context, String title, dynamic text) => DefaultTextStyle(
  style: context.textTheme.bodyMedium!,
  child: Row(
    children: [
      Text(title),
      sbW2,
      Expanded(
        child: Text(
          text.toString(),
          style: TextStyle(fontWeight: FontWeight.w600),
          textAlign: TextAlign.end,
        ),
      ),
    ],
  ),
);
