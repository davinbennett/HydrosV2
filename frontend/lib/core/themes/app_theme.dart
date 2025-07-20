import 'package:flutter/material.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    fontFamily: GoogleFonts.poppins().fontFamily,
    scaffoldBackgroundColor: AppColors.secondary,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.secondary,
      centerTitle: true,
    )
  );
}
