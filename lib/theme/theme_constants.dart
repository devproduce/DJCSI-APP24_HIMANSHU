import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  primaryColorLight: Colors.black,
  primaryColor: Colors.white,
  appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontSize: 36,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      )),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.grey.shade500),
        iconColor: WidgetStatePropertyAll(Colors.white),
        
        
        ),
        
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black26,
  primaryColorDark: Colors.white,
  primaryColor: Colors.black,
  appBarTheme:const AppBarTheme(
      backgroundColor: Colors.black,
      titleTextStyle: TextStyle(
        fontSize: 36,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      )),
  elevatedButtonTheme:const ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(Colors.white),
      iconColor: WidgetStatePropertyAll(Colors.black),
    ),
  ),
);
