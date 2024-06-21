import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  // 기본 폰트를 GmarketSans로 설정
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontFamily: 'GmarketSans', fontWeight: FontWeight.w300),
    bodyMedium: TextStyle(fontFamily: 'GmarketSans', fontWeight: FontWeight.w500),
    displayLarge: TextStyle(fontFamily: 'GmarketSans', fontWeight: FontWeight.w700),
    displayMedium: TextStyle(fontFamily: 'GmarketSans', fontWeight: FontWeight.w700),
    displaySmall: TextStyle(fontFamily: 'GmarketSans', fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(fontFamily: 'GmarketSans', fontWeight: FontWeight.w700),
    headlineSmall: TextStyle(fontFamily: 'GmarketSans', fontWeight: FontWeight.w700),
    titleLarge: TextStyle(fontFamily: 'GmarketSans', fontWeight: FontWeight.w700),
    titleMedium: TextStyle(fontFamily: 'GmarketSans', fontWeight: FontWeight.w500),
    titleSmall: TextStyle(fontFamily: 'GmarketSans', fontWeight: FontWeight.w500),
    bodySmall: TextStyle(fontFamily: 'GmarketSans', fontWeight: FontWeight.w300),
    labelSmall: TextStyle(fontFamily: 'GmarketSans', fontWeight: FontWeight.w300),
    labelLarge: TextStyle(fontFamily: 'GmarketSans', fontWeight: FontWeight.w500),
  ),
);
