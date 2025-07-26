enum ScreenSizeType { compact, medium, expanded }

class ScreenSizeUtil {
  static late double _screenWidth;

  static void init(double screenWidth) {
    _screenWidth = screenWidth;
  }

  static bool get isPhone => _screenWidth < 600;

  static bool get isTablet => _screenWidth >= 600;

  static ScreenSizeType get screenSizeType {
    if (_screenWidth < 600) return ScreenSizeType.compact;
    if (_screenWidth < 840) return ScreenSizeType.medium;
    return ScreenSizeType.expanded;
  }
}