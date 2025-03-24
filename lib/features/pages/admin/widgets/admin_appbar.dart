import 'package:flutter/material.dart';

AppBar adminAppBar(
  GlobalKey<ScaffoldState> scaffoldKey,
  String title, {
  PreferredSizeWidget? bottom,
}) => AppBar(
  forceMaterialTransparency: true,
  leading: IconButton(
    iconSize: 30,
    icon: const Icon(Icons.menu),
    onPressed: () => scaffoldKey.currentState!.openDrawer(),
  ),
  title: Text(title),
  bottom: bottom,
);
