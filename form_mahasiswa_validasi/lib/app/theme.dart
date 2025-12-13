import 'package:flutter/material.dart';

ThemeData appTheme = ThemeData(
  primaryColor: Colors.indigo,
  scaffoldBackgroundColor: Colors.transparent,
  fontFamily: 'Poppins',
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withOpacity(0.9),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
  ),
);
