import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void resetOrientations() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}

void lanscapeOrientations() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}

class LandscapeWrapper extends StatefulWidget {
  const LandscapeWrapper({super.key, required this.child});
  final Widget child;
  @override
  State<LandscapeWrapper> createState() => _LandscapeWrapperState();
}

class _LandscapeWrapperState extends State<LandscapeWrapper> {
  @override
  void initState() {
    super.initState();
    lanscapeOrientations();
  }

  @override
  void dispose() {
    resetOrientations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
