import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/core/themes/screen_size.dart';

enum ElementSizeType { s, m, l, xl, x2l }

class AppElementSize {
  static double get(BuildContext context, ElementSizeType type) {
    final width = MediaQuery.of(context).size.width;
    final screenType = getScreenSizeType(width);

    switch (type) {
      case ElementSizeType.s:
        return _byScreenType(screenType, 4, 6, 8);
      case ElementSizeType.m:
        return _byScreenType(screenType, 8, 10, 12);
      case ElementSizeType.l:
        return _byScreenType(screenType, 12, 16, 20);
      case ElementSizeType.xl:
        return _byScreenType(screenType, 16, 20, 24);
      case ElementSizeType.x2l:
        return _byScreenType(screenType, 20, 24, 32);
    }
  }

  static double _byScreenType(
    ScreenSizeType screenType,
    double compact,
    double medium,
    double expanded,
  ) {
    switch (screenType) {
      case ScreenSizeType.compact:
        return compact.w;
      case ScreenSizeType.medium:
        return medium.w;
      case ScreenSizeType.expanded:
        return expanded.w;
    }
  }
}
