import 'package:flutter/material.dart';

extension ScrollControllerExt on ScrollController {
  // usage: scrollController.isBottom
  bool get isBottom {
    if (!hasClients) return false;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = offset;
    return currentScroll >= maxScroll - 50;
  }
}
