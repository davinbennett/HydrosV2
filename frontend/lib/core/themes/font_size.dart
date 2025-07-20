import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'screen_size.dart'; // berisi enum ScreenSizeType { compact, medium, expanded }

class AppFontSize {
  static late ScreenSizeType screenSizeType;

  static void init(double width) {
    screenSizeType = getScreenSizeType(width);
  }

  static double get s => _byScreenType(12, 13, 14);
  static double get m => _byScreenType(14, 15, 16);
  static double get l => _byScreenType(16, 18, 20);
  static double get xl => _byScreenType(18, 20, 22);
  static double get x2l => _byScreenType(20, 22, 24);

  static double _byScreenType(double compact, double medium, double expanded) {
    switch (screenSizeType) {
      case ScreenSizeType.compact:
        return compact.sp;
      case ScreenSizeType.medium:
        return medium.sp;
      case ScreenSizeType.expanded:
        return expanded.sp;
    }
  }
}
