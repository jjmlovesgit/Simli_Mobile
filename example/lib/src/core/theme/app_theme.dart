import 'package:flutter/material.dart';
import 'package:example/src/core/theme/app_color_scheme.dart';
import 'package:example/src/core/theme/app_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFFFF4EA),
    colorScheme: AppColorScheme.lightScheme,
    fontFamily: AppFonts.satoshi,
  );
  static ThemeData darkTheme = ThemeData();
}
