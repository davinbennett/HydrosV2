import 'package:flutter/material.dart';

class MediaQueryHelper {
  final BuildContext context;
  final MediaQueryData _mq;

  MediaQueryHelper(this.context) : _mq = MediaQuery.of(context);

  bool get isLandscape => _mq.orientation == Orientation.landscape;
  bool get isPortrait => _mq.orientation == Orientation.portrait;

  double get screenWidth => _mq.size.width;
  double get screenHeight => _mq.size.height;

  double get notchHeight => _mq.padding.top;
  double get bottomPadding => _mq.padding.bottom;

  double get statusBarHeight => _mq.padding.top;

  double get safeHeight => _mq.size.height - _mq.padding.vertical;
  double get safeWidth => _mq.size.width - _mq.padding.horizontal;

  EdgeInsets get viewPadding => _mq.viewPadding;
  EdgeInsets get viewInsets => _mq.viewInsets;

  static MediaQueryHelper of(BuildContext context) => MediaQueryHelper(context);
}
