import 'package:flutter/material.dart';
import 'package:frontend/core/themes/screen_size.dart';

class AppFontWeight {
  static late ScreenSizeType _screenSizeType;

  static void init(double screenWidth) {
    _screenSizeType = getScreenSizeType(screenWidth);
  }

  static late FontWeight bold;
  static late FontWeight semiBold;
  static late FontWeight medium;
  static late FontWeight normal;
  static late FontWeight light;

  static void setup() {
    bold = _byScreenType(FontWeight.w700, FontWeight.w800, FontWeight.w900);
    semiBold = _byScreenType(FontWeight.w600, FontWeight.w700, FontWeight.w800);
    medium = _byScreenType(FontWeight.w500, FontWeight.w600, FontWeight.w700);
    normal = FontWeight.normal;
    light = _byScreenType(FontWeight.w300, FontWeight.w200, FontWeight.w100);
  }

  static FontWeight _byScreenType(
    FontWeight compact,
    FontWeight medium,
    FontWeight expanded,
  ) {
    switch (_screenSizeType) {
      case ScreenSizeType.compact:
        return compact;
      case ScreenSizeType.medium:
        return medium;
      case ScreenSizeType.expanded:
        return expanded;
    }
  }
}
