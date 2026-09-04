import 'package:app/themes/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    
  ).copyWith(surface: Color(0xFFFDF6E3));
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: colorScheme,
    primaryTextTheme: textTheme,
    textTheme: textTheme,
    appBarTheme: appBarThemeData,
  );

  static AppBarThemeData appBarThemeData = AppBarThemeData(
    iconTheme: IconThemeData(color: AppColors.onPrimary),
  );

  static TextTheme textTheme = TextTheme(
    headlineSmall: TextStyle(fontFamily: 'Playfair Display', fontWeight: .bold),
    headlineMedium: TextStyle(fontFamily: 'Playfair Display'),
    headlineLarge: TextStyle(fontFamily: 'Playfair Display'),

    displaySmall: TextStyle(
      fontFamily: 'Playfair Display',
      color: AppColors.secondary,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Playfair Display',
      color: AppColors.secondary,
    ),
    displayLarge: TextStyle(
      fontFamily: 'Playfair Display',
      color: AppColors.secondary,
      fontWeight: .bold,
    ),


    titleSmall: TextStyle(fontFamily: 'Playfair Display', fontWeight: .bold),
    titleMedium: TextStyle(fontFamily: 'Playfair Display', fontWeight: .bold),
    titleLarge: TextStyle(fontFamily: 'Playfair Display', fontWeight: .bold),

    bodySmall: TextStyle(fontFamily: 'Lora'),
    bodyMedium: TextStyle(fontFamily: 'Lora'),
    bodyLarge: TextStyle(fontFamily: 'Lora'),

    labelSmall: TextStyle(fontFamily: 'Caveat'),
    labelMedium: TextStyle(fontFamily: 'Caveat'),
    labelLarge: TextStyle(fontFamily: 'Caveat'),

    
  );
}
