enum ScreenSizeType { compact, medium, expanded }

ScreenSizeType getScreenSizeType(double width) {
  if (width < 600) return ScreenSizeType.compact;
  if (width < 840) return ScreenSizeType.medium;
  return ScreenSizeType.expanded;
}
