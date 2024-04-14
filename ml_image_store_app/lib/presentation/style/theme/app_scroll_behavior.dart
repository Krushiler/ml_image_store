import 'package:flutter/material.dart';

class AppScrollBehavior extends ScrollBehavior {
  const AppScrollBehavior();

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return getPlatform(context) == TargetPlatform.android
        ? StretchingOverscrollIndicator(axisDirection: details.direction, child: child)
        : child;
  }
}
