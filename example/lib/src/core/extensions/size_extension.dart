import 'package:flutter/material.dart';

extension SizeExtension on Size {
  bool get isSmallMobile => width <= 320;
  bool get isMobile => width > 320 && width <= 480;
  bool get isTablet => width > 480 && width <= 1024;
  bool get isDesktop => width > 1024 && width <= 1440;
  bool get isLargeDesktop => width > 1440;
}
