import 'package:flutter/material.dart';

import '../extensions/build_content_extensions.dart';
import '../extensions/num_extension.dart';

Widget safeWrapContainer(
  BuildContext context,
  ScrollController scrollController,
  Widget child, {
  Border? border,
  bool hasBottomBar = true,
}) {
  return SingleChildScrollView(
    controller: scrollController,
    physics: AlwaysScrollableScrollPhysics(),
    child: Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 1000,
          minHeight: hasBottomBar ? context.homeSafeHeight + 5 : context.safeHeightNoBottom + 6,
        ),
        decoration: BoxDecoration(
          border: border,
          borderRadius: 8.radius,
          color: context.colorScheme.surfaceBright,
        ),
        padding: 10.eiAll,
        child: child,
      ),
    ),
  );
}
